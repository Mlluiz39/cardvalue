class Installment {
  final String id;
  final String purchaseId;
  final String? invoiceCycleId;
  final String userId;
  final int sequenceNumber;
  final int totalInstallments;
  final double amount;
  final DateTime dueDate;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;

  Installment({
    required this.id,
    required this.purchaseId,
    this.invoiceCycleId,
    required this.userId,
    required this.sequenceNumber,
    required this.totalInstallments,
    required this.amount,
    required this.dueDate,
    this.status = 'pending',
    this.paidAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPaid => status == 'paid';

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
    id: json['id'] as String,
    purchaseId: json['purchase_id'] as String,
    invoiceCycleId: json['invoice_cycle_id'] as String?,
    userId: json['user_id'] as String,
    sequenceNumber: json['sequence_number'] as int,
    totalInstallments: json['total_installments'] as int,
    amount: (json['amount'] as num).toDouble(),
    dueDate: DateTime.parse(json['due_date'] as String),
    status: json['status'] as String? ?? 'pending',
    paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'purchase_id': purchaseId,
    'invoice_cycle_id': invoiceCycleId,
    'user_id': userId,
    'sequence_number': sequenceNumber,
    'total_installments': totalInstallments,
    'amount': amount,
    'due_date': dueDate.toIso8601String().substring(0, 10),
    'status': status,
    'paid_at': paidAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
