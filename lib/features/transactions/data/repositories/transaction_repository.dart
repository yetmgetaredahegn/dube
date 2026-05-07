import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dube/core/utils/firestore_paths.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CreditTransaction>> watchCustomerTransactions(
      String uid, String customerId) {
    return _db
        .collection(FirestorePaths.transactions(uid))
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(CreditTransaction.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // One-time fetch for a specific customer
  Future<List<CreditTransaction>> getCustomerTransactions(
      String uid, String customerId) async {
    final s = await _db
        .collection(FirestorePaths.transactions(uid))
        .where('customerId', isEqualTo: customerId)
        .get();
    final list = s.docs.map(CreditTransaction.fromFirestore).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // All transactions for the shop (for aging/reports)
  Future<List<CreditTransaction>> getAllTransactions(String uid) async {
    final s = await _db
        .collection(FirestorePaths.transactions(uid))
        .orderBy('createdAt', descending: true)
        .get();
    return s.docs.map(CreditTransaction.fromFirestore).toList();
  }

  // Add a transaction
  Future<String> addTransaction(String uid, CreditTransaction txn) async {
    final ref = await _db
        .collection(FirestorePaths.transactions(uid))
        .add(txn.toFirestore());
    return ref.id;
  }

  // Get a single transaction
  Future<CreditTransaction?> getTransaction(
      String uid, String txnId) async {
    final doc = await _db
        .doc(FirestorePaths.transaction(uid, txnId))
        .get();
    if (!doc.exists) return null;
    return CreditTransaction.fromFirestore(doc);
  }
}
