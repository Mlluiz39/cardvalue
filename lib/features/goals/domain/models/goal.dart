class Goal {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? categoryId;
  final double? monthlyContribution;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.categoryId,
    this.monthlyContribution,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    targetAmount: (json['target_amount'] as num).toDouble(),
    currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
    categoryId: json['category_id'] as String?,
    monthlyContribution: (json['monthly_contribution'] as num?)?.toDouble(),
    status: json['status'] as String? ?? 'active',
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'deadline': deadline?.toIso8601String().substring(0, 10),
    'category_id': categoryId,
    'monthly_contribution': monthlyContribution,
    'status': status,
  };
}
