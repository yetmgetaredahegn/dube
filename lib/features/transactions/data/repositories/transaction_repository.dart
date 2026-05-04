import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dube/core/utils/firestore_paths.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of all transactions for a customer
  Stream<List<CreditTransaction>> watchCustomerTransactions(
      String shopOwnerId, String customerId) {
    return _db
        .collection(FirestorePaths.transactions(shopOwnerId, customerId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map(CreditTransaction.fromFirestore).toList());
  }

  // Get all transactions for a customer (one-time fetch)
  Future<List<CreditTransaction>> getCustomerTransactions(
      String shopOwnerId, String customerId) async {
    final s = await _db
        .collection(FirestorePaths.transactions(shopOwnerId, customerId))
        .orderBy('createdAt', descending: true)
        .get();
    return s.docs.map(CreditTransaction.fromFirestore).toList();
  }

  // Get all transactions for the shop (for aging report)
  Future<List<CreditTransaction>> getAllTransactions(String shopOwnerId) async {
    final s = await _db
        .collectionGroup('transactions')
        .where('shopOwnerId', isEqualTo: shopOwnerId)
        .orderBy('createdAt', descending: true)
        .get();
    return s.docs.map(CreditTransaction.fromFirestore).toList();
  }

  // Add a new transaction
  Future<String> addTransaction(
      String shopOwnerId, CreditTransaction txn) async {
    final ref = await _db
        .collection(
            FirestorePaths.transactions(shopOwnerId, txn.customerId))
        .add(txn.toFirestore());
    return ref.id;
  }

  // Get single transaction by ID
  Future<CreditTransaction?> getTransaction(
      String shopOwnerId, String customerId, String txnId) async {
    final doc = await _db
        .collection(FirestorePaths.transactions(shopOwnerId, customerId))
        .doc(txnId)
        .get();
    if (!doc.exists) return null;
    return CreditTransaction.fromFirestore(doc);
  }
}
