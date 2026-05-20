class RecurrenceRule {
  final String id;
  final String userId;
  final String frequency;
  final int interval;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final String endType;
  final int? endCount;
  final DateTime? endDate;
  final DateTime? nextOccurrence;
  final bool isActive;
  final DateTime createdAt;

  RecurrenceRule({
    required this.id,
    required this.userId,
    required this.frequency,
    this.interval = 1,
    this.dayOfMonth,
    this.dayOfWeek,
    this.endType = 'never',
    this.endCount,
    this.endDate,
    this.nextOccurrence,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => RecurrenceRule(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    frequency: json['frequency'] as String,
    interval: json['interval'] as int? ?? 1,
    dayOfMonth: json['day_of_month'] as int?,
    dayOfWeek: json['day_of_week'] as int?,
    endType: json['end_type'] as String? ?? 'never',
    endCount: json['end_count'] as int?,
    endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
    nextOccurrence: json['next_occurrence'] != null ? DateTime.parse(json['next_occurrence'] as String) : null,
    isActive: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'frequency': frequency,
    'interval': interval,
    'day_of_month': dayOfMonth,
    'day_of_week': dayOfWeek,
    'end_type': endType,
    'end_count': endCount,
    'end_date': endDate?.toIso8601String().substring(0, 10),
    'next_occurrence': nextOccurrence?.toIso8601String().substring(0, 10),
    'is_active': isActive,
  };
}
