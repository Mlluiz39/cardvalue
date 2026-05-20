class FinancialAlert {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String severity;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  FinancialAlert({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.isRead = false,
    this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FinancialAlert.fromJson(Map<String, dynamic> json) => FinancialAlert(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    type: json['type'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    severity: json['severity'] as String,
    isRead: json['is_read'] as bool? ?? false,
    data: json['data'] as Map<String, dynamic>?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type,
    'title': title,
    'message': message,
    'severity': severity,
    'is_read': isRead,
    'data': data,
  };
}
