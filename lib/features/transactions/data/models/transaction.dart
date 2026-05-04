import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { credit, payment }

class CreditTransaction {
  final String id;
  final String customerId;
  final String shopOwnerId;
  final TransactionType type;
  final double amount;
  final String? note;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.customerId,
    required this.shopOwnerId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory CreditTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreditTransaction(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      shopOwnerId: data['shopOwnerId'] ?? '',
      type: data['type'] == 'credit'
          ? TransactionType.credit
          : TransactionType.payment,
      amount: (data['amount'] as num).toDouble(),
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'shopOwnerId': shopOwnerId,
      'type': type == TransactionType.credit ? 'credit' : 'payment',
      'amount': amount,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isCredit => type == TransactionType.credit;
  bool get isPayment => type == TransactionType.payment;
}
