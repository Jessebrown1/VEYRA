class ChatMessageEntry {
  final String id;
  final String sender;
  final String content;
  final DateTime createdAt;

  const ChatMessageEntry({
    required this.id,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  bool get isFromCompanion => sender == 'companion';

  factory ChatMessageEntry.fromJson(Map<String, dynamic> json) => ChatMessageEntry(
        id: json['id'] as String,
        sender: json['sender'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
