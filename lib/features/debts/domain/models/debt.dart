class Debt {
  final String id;
  final String userId;
  final String title;
  final double totalAmount;
  final double remainingAmount;
  final double interestRate;
  final int totalInstallments;
  final int remainingInstallments;
  final DateTime dueDate;
  final String priority;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.userId,
    required this.title,
    required this.totalAmount,
    required this.remainingAmount,
    this.interestRate = 0,
    required this.totalInstallments,
    required this.remainingInstallments,
    required this.dueDate,
    this.priority = 'medium',
    this.status = 'active',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    totalAmount: (json['total_amount'] as num).toDouble(),
    remainingAmount: (json['remaining_amount'] as num).toDouble(),
    interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0,
    totalInstallments: json['total_installments'] as int,
    remainingInstallments: json['remaining_installments'] as int,
    dueDate: DateTime.parse(json['due_date'] as String),
    priority: json['priority'] as String? ?? 'medium',
    status: json['status'] as String? ?? 'active',
    notes: json['notes'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'total_amount': totalAmount,
    'remaining_amount': remainingAmount,
    'interest_rate': interestRate,
    'total_installments': totalInstallments,
    'remaining_installments': remainingInstallments,
    'due_date': dueDate.toIso8601String().substring(0, 10),
    'priority': priority,
    'status': status,
    'notes': notes,
  };
}
