class TransactionModel {
  final int id;
  final int customerId;
  final double amount;
  final String type; // 'CREDIT' or 'PAYMENT'
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as int,
        customerId: json['customer_id'] as int,
        amount: (json['amount'] ?? 0).toDouble(),
        type: json['type'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'amount': amount,
        'type': type,
        'date': date.toIso8601String(),
      };
}
