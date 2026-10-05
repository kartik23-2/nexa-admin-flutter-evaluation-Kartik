import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/firestore_collections.dart';
import '../models/document_model.dart';
import 'audit_service.dart';

class DocumentService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final AuditService _auditService;

  DocumentService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    AuditService? auditService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _auditService = auditService ?? AuditService();

  CollectionReference<Map<String, dynamic>> get _docsRef =>
      _firestore.collection(FirestoreCollections.documents);

  Stream<List<DocumentModel>> streamDocuments({String? entityId}) {
    Query<Map<String, dynamic>> query = _docsRef.orderBy('uploadedAt', descending: true);
    if (entityId != null && entityId.isNotEmpty) {
      query = query.where('entityId', isEqualTo: entityId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DocumentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<DocumentModel>> getDocuments({String? entityId}) async {
    Query<Map<String, dynamic>> query = _docsRef.orderBy('uploadedAt', descending: true);
    if (entityId != null && entityId.isNotEmpty) {
      query = query.where('entityId', isEqualTo: entityId);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DocumentModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<DocumentModel> uploadDocument({
    required String entityId,
    required String entityType,
    required String entityName,
    required String docType,
    required XFile file,
    Function(double progress)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = 'documents/${entityId}_${timestamp}_$sanitizedFileName';
    final ref = _storage.ref().child(storagePath);

    UploadTask uploadTask;
    final metadata = SettableMetadata(
      contentType: file.mimeType ?? 'image/jpeg',
      customMetadata: {
        'entityId': entityId,
        'entityType': entityType,
        'docType': docType,
      },
    );

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      uploadTask = ref.putData(bytes, metadata);
    } else {
      uploadTask = ref.putFile(File(file.path), metadata);
    }

    // Listen to progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.totalBytes > 0) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      }
    });

    final taskSnapshot = await uploadTask;
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();

    final docRef = _docsRef.doc();
    final document = DocumentModel(
      id: docRef.id,
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      type: docType,
      fileUrl: downloadUrl,
      fileName: file.name,
      uploadedAt: DateTime.now(),
      uploadedBy: _auth.currentUser?.email ?? 'Administrator',
    );

    await docRef.set(document.toMap());

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'DOCUMENT_UPLOADED',
      entityType: 'Document',
      entityId: docRef.id,
      description: 'Uploaded $docType ("${file.name}") for $entityType "$entityName"',
      metadata: {
        'docType': docType,
        'fileName': file.name,
        'entityId': entityId,
        'entityType': entityType,
        'fileUrl': downloadUrl,
      },
    );

    return document;
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    try {
      final ref = _storage.refFromURL(doc.fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('[DocumentService] Storage file delete notice: $e');
    }

    await _docsRef.doc(doc.id).delete();

    await _auditService.logEvent(
      action: 'DOCUMENT_DELETED',
      entityType: 'Document',
      entityId: doc.id,
      description: 'Deleted ${doc.type} ("${doc.fileName}") for ${doc.entityName}',
      metadata: {'id': doc.id, 'fileName': doc.fileName},
    );
  }
}
