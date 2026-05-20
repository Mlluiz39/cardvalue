class ReconciliationItem {
  final String id;
  final String reportId;
  final String invoiceDescription;
  final double invoiceAmount;
  final String matchStatus;
  final String? matchedPurchaseId;
  final double? registeredAmount;
  final double? difference;
  final String? userAction;
  final DateTime createdAt;

  ReconciliationItem({
    required this.id,
    required this.reportId,
    required this.invoiceDescription,
    required this.invoiceAmount,
    required this.matchStatus,
    this.matchedPurchaseId,
    this.registeredAmount,
    this.difference,
    this.userAction,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReconciliationItem.fromJson(Map<String, dynamic> json) => ReconciliationItem(
    id: json['id'] as String,
    reportId: json['report_id'] as String,
    invoiceDescription: json['invoice_description'] as String,
    invoiceAmount: (json['invoice_amount'] as num).toDouble(),
    matchStatus: json['match_status'] as String,
    matchedPurchaseId: json['matched_purchase_id'] as String?,
    registeredAmount: (json['registered_amount'] as num?)?.toDouble(),
    difference: (json['difference'] as num?)?.toDouble(),
    userAction: json['user_action'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'report_id': reportId,
    'invoice_description': invoiceDescription,
    'invoice_amount': invoiceAmount,
    'match_status': matchStatus,
    'matched_purchase_id': matchedPurchaseId,
    'registered_amount': registeredAmount,
    'difference': difference,
    'user_action': userAction,
  };
}
