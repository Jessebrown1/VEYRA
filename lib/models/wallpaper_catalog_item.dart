class WallpaperCatalogItem {
  final String id;
  final String name;
  final String category;
  final String assetPath;
  final bool isPremium;

  const WallpaperCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.assetPath,
    required this.isPremium,
  });

  factory WallpaperCatalogItem.fromJson(Map<String, dynamic> json) => WallpaperCatalogItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        assetPath: json['assetPath'] as String,
        isPremium: json['isPremium'] as bool? ?? false,
      );
}
