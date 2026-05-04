class Customer {
  final int id;
  final String name;
  final String phone;
  final double creditLimit;
  final double balance;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.creditLimit,
    required this.balance,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        creditLimit: (json['credit_limit'] ?? 0).toDouble(),
        balance: (json['balance'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'credit_limit': creditLimit,
        'balance': balance,
      };
}
