import 'avatar_config.dart';

class CompanionProfile {
  final String id;
  final String name;
  final String relationshipId;
  final Map<String, double> personalityTraits;
  final String preferredUserName;
  final String preferredTermId;
  final String? wallpaperId;
  final AvatarConfig avatarConfig;

  const CompanionProfile({
    required this.id,
    required this.name,
    required this.relationshipId,
    required this.personalityTraits,
    required this.preferredUserName,
    required this.preferredTermId,
    required this.avatarConfig,
    this.wallpaperId,
  });

  /// The single dominant personality trait — the onboarding flow lets free
  /// users pick one trait at a time (combos are a VEYRA+ feature).
  String get personalityId =>
      personalityTraits.isNotEmpty ? personalityTraits.entries.first.key : 'caring';

  factory CompanionProfile.fromJson(Map<String, dynamic> json) => CompanionProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        relationshipId: json['relationshipId'] as String,
        personalityTraits: (json['personalityTraits'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
        preferredUserName: json['preferredUserName'] as String,
        preferredTermId: json['preferredTermId'] as String,
        wallpaperId: json['wallpaperId'] as String?,
        avatarConfig: AvatarConfig.fromJson(json['avatarConfig'] as Map<String, dynamic>?),
      );

  CompanionProfile copyWith({
    String? wallpaperId,
    AvatarConfig? avatarConfig,
  }) {
    return CompanionProfile(
      id: id,
      name: name,
      relationshipId: relationshipId,
      personalityTraits: personalityTraits,
      preferredUserName: preferredUserName,
      preferredTermId: preferredTermId,
      wallpaperId: wallpaperId ?? this.wallpaperId,
      avatarConfig: avatarConfig ?? this.avatarConfig,
    );
  }
}
