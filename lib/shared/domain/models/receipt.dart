class Receipt {
  final String id;
  final String userId;
  final String? transactionId;
  final String? purchaseId;
  final String fileUrl;
  final String fileType;
  final String? extractedText;
  final Map<String, dynamic>? extractedData;
  final DateTime createdAt;

  Receipt({
    required this.id,
    required this.userId,
    this.transactionId,
    this.purchaseId,
    required this.fileUrl,
    required this.fileType,
    this.extractedText,
    this.extractedData,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    transactionId: json['transaction_id'] as String?,
    purchaseId: json['purchase_id'] as String?,
    fileUrl: json['file_url'] as String,
    fileType: json['file_type'] as String,
    extractedText: json['extracted_text'] as String?,
    extractedData: json['extracted_data'] as Map<String, dynamic>?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'transaction_id': transactionId,
    'purchase_id': purchaseId,
    'file_url': fileUrl,
    'file_type': fileType,
    'extracted_text': extractedText,
    'extracted_data': extractedData,
    'created_at': createdAt.toIso8601String(),
  };
}
