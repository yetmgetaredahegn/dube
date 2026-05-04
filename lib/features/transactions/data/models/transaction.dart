import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dube/core/constants/firestore_paths.dart';

class Transaction {
  final String id;
  final String customerId;
  final String type; // 'CREDIT' or 'PAYMENT'
  final double amount;
  final String note;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  bool get isCredit  => type == TransactionType.credit;
  bool get isPayment => type == TransactionType.payment;

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Transaction(
      id:         doc.id,
      customerId: d['customerId'] as String? ?? '',
      type:       d['type']       as String? ?? TransactionType.credit,
      amount:     (d['amount']    as num?)?.toDouble() ?? 0.0,
      note:       d['note']       as String? ?? '',
      createdAt:  (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'customerId': customerId,
        'type':       type,
        'amount':     amount,
        'note':       note,
        'createdAt':  FieldValue.serverTimestamp(),
      };
}
