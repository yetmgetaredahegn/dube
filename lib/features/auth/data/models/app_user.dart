import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String shopName;
  final String phone;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.shopName,
    required this.phone,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid:       doc.id,
      email:     d['email']    as String? ?? '',
      shopName:  d['shopName'] as String? ?? '',
      phone:     d['phone']    as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email':     email,
        'shopName':  shopName,
        'phone':     phone,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
