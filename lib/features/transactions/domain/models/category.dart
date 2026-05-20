class Category {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final String? colorHex;
  final String type;
  final bool isSystem;
  final int sortOrder;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.colorHex,
    required this.type,
    this.isSystem = false,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String?,
    colorHex: json['color'] as String?,
    type: json['type'] as String,
    isSystem: json['is_system'] as bool? ?? false,
    sortOrder: json['sort_order'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'icon': icon,
    'color': colorHex,
    'type': type,
    'is_system': isSystem,
    'sort_order': sortOrder,
  };
}
