class CardModel {
  final String id;
  final String userId;
  final String bankName;
  final String cardName;
  final String brand;
  final String cardType;
  final double limitAmount;
  final int closingDay;
  final int dueDay;
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  final double usedAmount;

  CardModel({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.cardName,
    required this.brand,
    this.cardType = 'physical',
    required this.limitAmount,
    required this.closingDay,
    required this.dueDay,
    this.color,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.usedAmount = 0.0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    bankName: json['bank_name'] as String,
    cardName: json['card_name'] as String,
    brand: json['brand'] as String,
    cardType: json['card_type'] as String? ?? 'physical',
    limitAmount: (json['limit_amount'] as num).toDouble(),
    closingDay: json['closing_day'] as int,
    dueDay: json['due_day'] as int,
    color: json['color'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    usedAmount: (json['used_amount'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'bank_name': bankName,
    'card_name': cardName,
    'brand': brand,
    'card_type': cardType,
    'limit_amount': limitAmount,
    'closing_day': closingDay,
    'due_day': dueDay,
    'color': color,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'used_amount': usedAmount,
  };

  double get availableLimit => limitAmount - usedAmount;
}
