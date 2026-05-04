import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dube/core/utils/firestore_paths.dart';
import 'package:dube/features/customers/data/models/customer.dart';

class CustomerRepository {
  final FirebaseFirestore _db;

  CustomerRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Real-time stream ───────────────────────────────────────────────────────
  Stream<List<Customer>> watchCustomers(String uid) {
    return _db
        .collection(FirestorePaths.customers(uid))
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(Customer.fromFirestore).toList());
  }

  // ── Fetch once ─────────────────────────────────────────────────────────────
  Future<List<Customer>> fetchCustomers(String uid) async {
    final s = await _db
        .collection(FirestorePaths.customers(uid))
        .orderBy('name')
        .get();
    return s.docs.map(Customer.fromFirestore).toList();
  }

  Future<Customer> fetchCustomer(String uid, String customerId) async {
    final doc = await _db.doc(FirestorePaths.customer(uid, customerId)).get();
    if (!doc.exists) throw Exception('Customer not found');
    return Customer.fromFirestore(doc);
  }

  // ── Create (bug fixed — returns the doc after Firestore assigns ID) ────────
  Future<Customer> addCustomer({
    required String uid,
    required String name,
    required String phone,
    required double creditLimit,
    String? note,
  }) async {
    final data = {
      'uid':         uid,
      'name':        name,
      'phone':       phone,
      'creditLimit': creditLimit,
      if (note != null) 'note': note,
      'createdAt':   FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection(FirestorePaths.customers(uid)).add(data);
    final doc = await ref.get();
    return Customer.fromFirestore(doc);
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> updateCustomer({
    required String uid,
    required String customerId,
    String? name,
    String? phone,
    double? creditLimit,
    String? note,
  }) async {
    final updates = <String, dynamic>{};
    if (name        != null) updates['name']        = name;
    if (phone       != null) updates['phone']       = phone;
    if (creditLimit != null) updates['creditLimit'] = creditLimit;
    if (note        != null) updates['note']        = note;
    await _db.doc(FirestorePaths.customer(uid, customerId)).update(updates);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> deleteCustomer(String uid, String customerId) async {
    // Transactions are kept for audit trail — only the customer doc is deleted
    await _db.doc(FirestorePaths.customer(uid, customerId)).delete();
  }

  // ── Client-side search ─────────────────────────────────────────────────────
  Future<List<Customer>> searchCustomers(String uid, String query) async {
    final all = await fetchCustomers(uid);
    final q   = query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }
}
