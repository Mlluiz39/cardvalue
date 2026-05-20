class Transaction {
  final String id;
  final String userId;
  final String type;
  final String? paymentMethod;
  final String categoryId;
  final String description;
  final double amount;
  final DateTime transactionDate;
  final String? notes;
  final String? recurrenceRuleId;
  final String? debtId;
  final String? goalId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    this.paymentMethod,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.transactionDate,
    this.notes,
    this.recurrenceRuleId,
    this.debtId,
    this.goalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isIncome => type == 'income';

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    type: json['type'] as String,
    paymentMethod: json['payment_method'] as String?,
    categoryId: json['category_id'] as String,
    description: json['description'] as String,
    amount: (json['amount'] as num).toDouble(),
    transactionDate: DateTime.parse(json['transaction_date'] as String),
    notes: json['notes'] as String?,
    recurrenceRuleId: json['recurrence_rule_id'] as String?,
    debtId: json['debt_id'] as String?,
    goalId: json['goal_id'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type,
    'payment_method': paymentMethod,
    'category_id': categoryId,
    'description': description,
    'amount': amount,
    'transaction_date': transactionDate.toIso8601String().substring(0, 10),
    'notes': notes,
    'recurrence_rule_id': recurrenceRuleId,
    'debt_id': debtId,
    'goal_id': goalId,
  };
}
