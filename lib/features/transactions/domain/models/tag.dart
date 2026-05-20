class Tag {
  final String id;
  final String userId;
  final String name;
  final String? color;

  Tag({required this.id, required this.userId, required this.name, this.color});

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    color: json['color'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'user_id': userId, 'name': name, 'color': color};
}
