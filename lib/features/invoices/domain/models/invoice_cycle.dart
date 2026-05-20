class InvoiceCycle {
  final String id;
  final String cardId;
  final String userId;
  final int month;
  final int year;
  final DateTime closingDate;
  final DateTime dueDate;
  final double totalAmount;
  final bool isPaid;
  final DateTime? paidAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceCycle({
    required this.id,
    required this.cardId,
    required this.userId,
    required this.month,
    required this.year,
    required this.closingDate,
    required this.dueDate,
    this.totalAmount = 0,
    this.isPaid = false,
    this.paidAt,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get label => '$month/$year';

  bool get isClosed => DateTime.now().isAfter(closingDate);

  factory InvoiceCycle.fromJson(Map<String, dynamic> json) => InvoiceCycle(
    id: json['id'] as String,
    cardId: json['card_id'] as String,
    userId: json['user_id'] as String,
    month: json['month'] as int,
    year: json['year'] as int,
    closingDate: DateTime.parse(json['closing_date'] as String),
    dueDate: DateTime.parse(json['due_date'] as String),
    totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    isPaid: json['is_paid'] as bool? ?? false,
    paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
    notes: json['notes'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'card_id': cardId,
    'user_id': userId,
    'month': month,
    'year': year,
    'closing_date': closingDate.toIso8601String().substring(0, 10),
    'due_date': dueDate.toIso8601String().substring(0, 10),
    'total_amount': totalAmount,
    'is_paid': isPaid,
    'paid_at': paidAt?.toIso8601String(),
    'notes': notes,
  };
}
