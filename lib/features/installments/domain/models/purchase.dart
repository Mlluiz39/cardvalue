class Purchase {
  final String id;
  final String cardId;
  final String userId;
  final String merchantName;
  final double totalAmount;
  final String categoryId;
  final DateTime purchaseDate;
  final int installmentCount;
  final String? notes;
  final bool isReconciled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Purchase({
    required this.id,
    required this.cardId,
    required this.userId,
    required this.merchantName,
    required this.totalAmount,
    required this.categoryId,
    required this.purchaseDate,
    required this.installmentCount,
    this.notes,
    this.isReconciled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    id: json['id'] as String,
    cardId: json['card_id'] as String,
    userId: json['user_id'] as String,
    merchantName: json['merchant_name'] as String,
    totalAmount: (json['total_amount'] as num).toDouble(),
    categoryId: json['category_id'] as String,
    purchaseDate: DateTime.parse(json['purchase_date'] as String),
    installmentCount: json['installment_count'] as int,
    notes: json['notes'] as String?,
    isReconciled: json['is_reconciled'] as bool? ?? false,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'card_id': cardId,
    'user_id': userId,
    'merchant_name': merchantName,
    'total_amount': totalAmount,
    'category_id': categoryId,
    'purchase_date': purchaseDate.toIso8601String().substring(0, 10),
    'installment_count': installmentCount,
    'notes': notes,
    'is_reconciled': isReconciled,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
