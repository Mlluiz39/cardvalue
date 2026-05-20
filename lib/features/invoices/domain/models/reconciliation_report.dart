class ReconciliationReport {
  final String id;
  final String invoiceCycleId;
  final String userId;
  final String status;
  final Map<String, dynamic> summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReconciliationReport({
    required this.id,
    required this.invoiceCycleId,
    required this.userId,
    this.status = 'draft',
    required this.summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ReconciliationReport.fromJson(Map<String, dynamic> json) => ReconciliationReport(
    id: json['id'] as String,
    invoiceCycleId: json['invoice_cycle_id'] as String,
    userId: json['user_id'] as String,
    status: json['status'] as String? ?? 'draft',
    summary: json['summary'] as Map<String, dynamic>? ?? {},
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_cycle_id': invoiceCycleId,
    'user_id': userId,
    'status': status,
    'summary': summary,
  };
}
