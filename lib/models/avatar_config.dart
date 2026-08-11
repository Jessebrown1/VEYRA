class AvatarConfig {
  final String? skinAssetId;
  final String? hairAssetId;
  final String? eyeAssetId;
  final String? outfitAssetId;
  final String? accessoryAssetId;

  const AvatarConfig({
    this.skinAssetId,
    this.hairAssetId,
    this.eyeAssetId,
    this.outfitAssetId,
    this.accessoryAssetId,
  });

  factory AvatarConfig.fromJson(Map<String, dynamic>? json) => AvatarConfig(
        skinAssetId: json?['skinAssetId'] as String?,
        hairAssetId: json?['hairAssetId'] as String?,
        eyeAssetId: json?['eyeAssetId'] as String?,
        outfitAssetId: json?['outfitAssetId'] as String?,
        accessoryAssetId: json?['accessoryAssetId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (skinAssetId != null) 'skinAssetId': skinAssetId,
        if (hairAssetId != null) 'hairAssetId': hairAssetId,
        if (eyeAssetId != null) 'eyeAssetId': eyeAssetId,
        if (outfitAssetId != null) 'outfitAssetId': outfitAssetId,
        if (accessoryAssetId != null) 'accessoryAssetId': accessoryAssetId,
      };

  AvatarConfig copyWith({
    String? skinAssetId,
    String? hairAssetId,
    String? eyeAssetId,
    String? outfitAssetId,
    String? accessoryAssetId,
    bool clearAccessory = false,
  }) {
    return AvatarConfig(
      skinAssetId: skinAssetId ?? this.skinAssetId,
      hairAssetId: hairAssetId ?? this.hairAssetId,
      eyeAssetId: eyeAssetId ?? this.eyeAssetId,
      outfitAssetId: outfitAssetId ?? this.outfitAssetId,
      accessoryAssetId: clearAccessory ? null : (accessoryAssetId ?? this.accessoryAssetId),
    );
  }
}
