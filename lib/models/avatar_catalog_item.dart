class AvatarCatalogItem {
  final String id;
  final String category;
  final String name;
  final String assetPath;
  final bool isPremium;

  const AvatarCatalogItem({
    required this.id,
    required this.category,
    required this.name,
    required this.assetPath,
    required this.isPremium,
  });

  factory AvatarCatalogItem.fromJson(Map<String, dynamic> json) => AvatarCatalogItem(
        id: json['id'] as String,
        category: json['category'] as String,
        name: json['name'] as String,
        assetPath: json['assetPath'] as String,
        isPremium: json['isPremium'] as bool? ?? false,
      );
}
