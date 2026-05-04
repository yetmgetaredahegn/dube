import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String uid;
  final String name;
  final String phone;
  final double creditLimit;
  final String? note;
  final DateTime createdAt;

  // Computed — NEVER stored in Firestore
  final double? balance;

  const Customer({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    required this.creditLimit,
    this.note,
    required this.createdAt,
    this.balance,
  });

  double get utilizationRatio {
    if (creditLimit <= 0 || balance == null) return 0;
    return balance! / creditLimit;
  }

  bool get isOverLimit  => (balance ?? 0) > creditLimit;
  bool get isNearLimit  => utilizationRatio >= 0.8 && !isOverLimit;
  bool get hasBalance   => (balance ?? 0) > 0;

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Customer(
      id:          doc.id,
      uid:         d['uid']         as String? ?? '',
      name:        d['name']        as String? ?? '',
      phone:       d['phone']       as String? ?? '',
      creditLimit: (d['creditLimit'] as num?)?.toDouble() ?? 0.0,
      note:        d['note']        as String?,
      createdAt:   (d['createdAt']  as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid':         uid,
        'name':        name,
        'phone':       phone,
        'creditLimit': creditLimit,
        if (note != null) 'note': note,
        'createdAt':   FieldValue.serverTimestamp(),
      };

  Customer copyWith({
    String? name,
    String? phone,
    double? creditLimit,
    String? note,
    double? balance,
  }) =>
      Customer(
        id:          id,
        uid:         uid,
        name:        name        ?? this.name,
        phone:       phone       ?? this.phone,
        creditLimit: creditLimit ?? this.creditLimit,
        note:        note        ?? this.note,
        createdAt:   createdAt,
        balance:     balance     ?? this.balance,
      );

  Customer withBalance(double b) => Customer(
        id:          id,
        uid:         uid,
        name:        name,
        phone:       phone,
        creditLimit: creditLimit,
        note:        note,
        createdAt:   createdAt,
        balance:     b,
      );
}
