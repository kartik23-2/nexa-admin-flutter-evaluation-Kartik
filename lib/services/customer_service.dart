import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/customer_model.dart';
import 'audit_service.dart';

class CustomerService {
  final FirebaseFirestore _firestore;
  final AuditService _auditService;

  CustomerService({
    FirebaseFirestore? firestore,
    AuditService? auditService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auditService = auditService ?? AuditService();

  CollectionReference<Map<String, dynamic>> get _customerRef =>
      _firestore.collection(FirestoreCollections.customers);

  Stream<List<CustomerModel>> streamCustomers() {
    return _customerRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CustomerModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<CustomerModel>> getCustomers() async {
    final snapshot = await _customerRef.orderBy('updatedAt', descending: true).get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final doc = await _customerRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return CustomerModel.fromMap(doc.data()!, docId: doc.id);
  }

  Future<String> addCustomer(CustomerModel customer) async {
    final docRef = _customerRef.doc();
    final newCustomer = customer.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(newCustomer.toMap());

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'CUSTOMER_CREATED',
      entityType: 'Customer',
      entityId: docRef.id,
      description: 'Added customer/lead "${customer.name}" with status "${customer.status}"',
      metadata: {
        'name': customer.name,
        'mobile': customer.mobile,
        'status': customer.status,
      },
    );

    return docRef.id;
  }

  Future<void> updateCustomer(
    CustomerModel customer, {
    String? previousStatus,
  }) async {
    final updated = customer.copyWith(updatedAt: DateTime.now());
    await _customerRef.doc(customer.id).update(updated.toMap());

    final bool statusChanged = previousStatus != null && previousStatus != customer.status;

    if (statusChanged) {
      await _auditService.logEvent(
        action: 'CUSTOMER_STATUS_TRANSITION',
        entityType: 'Customer',
        entityId: customer.id,
        description: 'Customer "${customer.name}" status transitioned from "$previousStatus" to "${customer.status}"',
        metadata: {
          'previousStatus': previousStatus,
          'newStatus': customer.status,
          'name': customer.name,
        },
      );
    } else {
      await _auditService.logEvent(
        action: 'CUSTOMER_UPDATED',
        entityType: 'Customer',
        entityId: customer.id,
        description: 'Updated customer profile for "${customer.name}"',
        metadata: customer.toMap(),
      );
    }
  }

  Future<void> deleteCustomer(String id, String name) async {
    await _customerRef.doc(id).delete();

    await _auditService.logEvent(
      action: 'CUSTOMER_DELETED',
      entityType: 'Customer',
      entityId: id,
      description: 'Deleted customer profile "$name"',
      metadata: {'id': id, 'name': name},
    );
  }
}
