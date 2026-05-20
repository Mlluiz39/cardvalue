class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String locale;
  final String currency;
  final String themePreference;
  final Map<String, dynamic> notificationSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.locale = 'pt-BR',
    this.currency = 'BRL',
    this.themePreference = 'system',
    this.notificationSettings = const {'push': true, 'insights': true, 'alerts': true},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatar_url'] as String?,
    locale: json['locale'] as String? ?? 'pt-BR',
    currency: json['currency'] as String? ?? 'BRL',
    themePreference: json['theme_preference'] as String? ?? 'system',
    notificationSettings: json['notification_settings'] as Map<String, dynamic>? ??
        {'push': true, 'insights': true, 'alerts': true},
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
    'locale': locale,
    'currency': currency,
    'theme_preference': themePreference,
    'notification_settings': notificationSettings,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? locale,
    String? currency,
    String? themePreference,
    Map<String, dynamic>? notificationSettings,
  }) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        locale: locale ?? this.locale,
        currency: currency ?? this.currency,
        themePreference: themePreference ?? this.themePreference,
        notificationSettings: notificationSettings ?? this.notificationSettings,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
