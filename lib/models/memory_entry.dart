class MemoryEntry {
  final String id;
  final String category;
  final String content;
  final double importance;
  final double confidence;
  final DateTime createdAt;

  const MemoryEntry({
    required this.id,
    required this.category,
    required this.content,
    required this.importance,
    required this.confidence,
    required this.createdAt,
  });

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
        id: json['id'] as String,
        category: json['category'] as String,
        content: json['content'] as String,
        importance: (json['importance'] as num).toDouble(),
        confidence: (json['confidence'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
