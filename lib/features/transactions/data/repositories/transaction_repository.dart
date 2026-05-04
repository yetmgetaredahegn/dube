import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dube/core/constants/firestore_paths.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';

class TransactionRepository {
  final FirebaseFirestore _db;

  TransactionRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Real-time stream for one customer ──────────────────────────────────────
  Stream<List<Transaction>> watchCustomerTransactions(
      String uid, String customerId) {
    return _db
        .collection(FirestorePaths.transactions(uid))
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Transaction.fromFirestore).toList());
  }

  // ── Fetch for balance calculation ──────────────────────────────────────────
  Future<List<Transaction>> fetchCustomerTransactions(
      String uid, String customerId) async {
    final s = await _db
        .collection(FirestorePaths.transactions(uid))
        .where('customerId', isEqualTo: customerId)
        .get();
    return s.docs.map(Transaction.fromFirestore).toList();
  }

  // ── Fetch all (used for reports + dashboard) ───────────────────────────────
  Future<List<Transaction>> fetchAllTransactions(String uid) async {
    final s = await _db
        .collection(FirestorePaths.transactions(uid))
        .orderBy('createdAt', descending: true)
        .get();
    return s.docs.map(Transaction.fromFirestore).toList();
  }

  // ── Write ──────────────────────────────────────────────────────────────────
  // NOTE: balance is NEVER written here — it is always derived.
  Future<Transaction> addTransaction({
    required String uid,
    required String customerId,
    required String type,
    required double amount,
    String note = '',
  }) async {
    final ref = await _db.collection(FirestorePaths.transactions(uid)).add({
      'customerId': customerId,
      'type':       type,
      'amount':     amount,
      'note':       note,
      'createdAt':  FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return Transaction.fromFirestore(doc);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> deleteTransaction(String uid, String txId) async {
    await _db.doc(FirestorePaths.transaction(uid, txId)).delete();
  }
}
