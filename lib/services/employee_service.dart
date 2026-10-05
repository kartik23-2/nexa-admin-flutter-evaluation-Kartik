import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/firestore_collections.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EmployeeService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _employeeRef =>
      _firestore.collection(FirestoreCollections.employees);

  Stream<List<EmployeeModel>> streamEmployees() {
    return _employeeRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmployeeModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<EmployeeModel>> getEmployees() async {
    final snapshot = await _employeeRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => EmployeeModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<EmployeeModel?> getEmployeeById(String id) async {
    final doc = await _employeeRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return EmployeeModel.fromMap(doc.data()!, docId: doc.id);
  }

  Future<String?> uploadProfilePhoto(String employeeId, XFile file) async {
    try {
      final ref = _storage.ref().child('employee_photos/$employeeId.jpg');
      UploadTask task;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        task = ref.putFile(File(file.path), SettableMetadata(contentType: 'image/jpeg'));
      }
      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('[EmployeeService] Upload photo error: $e');
      return null;
    }
  }

  Future<String> addEmployee(EmployeeModel employee, {XFile? photoFile}) async {
    final docRef = _employeeRef.doc();
    String? photoUrl = employee.photoUrl;

    if (photoFile != null) {
      photoUrl = await uploadProfilePhoto(docRef.id, photoFile);
    }

    final newEmployee = employee.copyWith(
      id: docRef.id,
      photoUrl: photoUrl,
    );

    await docRef.set(newEmployee.toMap());
    return docRef.id;
  }

  Future<void> updateEmployee(EmployeeModel employee, {XFile? photoFile}) async {
    String? photoUrl = employee.photoUrl;

    if (photoFile != null) {
      photoUrl = await uploadProfilePhoto(employee.id, photoFile);
    }

    final updated = employee.copyWith(photoUrl: photoUrl);
    await _employeeRef.doc(employee.id).update(updated.toMap());
  }

  Future<void> toggleEmployeeStatus(String id, bool active) async {
    await _employeeRef.doc(id).update({
      'status': active ? 'Active' : 'Inactive',
    });
  }

  Future<void> deleteEmployee(String id) async {
    await _employeeRef.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    try {
      final snapshot = await _firestore.collection(FirestoreCollections.branches).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? doc.id,
        };
      }).toList();
    } catch (e) {
      debugPrint('[EmployeeService] Fetch branches error: $e');
      return [];
    }
  }
}
