import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 8)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isUser;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? category; // fertility, pregnancy, nutrition, exercise, symptoms

  @HiveField(6)
  bool isLoading;

  ChatMessage({
    required this.id,
    required this.oderId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.category,
    this.isLoading = false,
  });

  // JSON serialization
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'],
      oderId: json['oderId'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? true,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      category: json['category'],
      isLoading: json['isLoading'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oderId': oderId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }
}

// Quick question presets for the AI chatbot
class QuickQuestions {
  static const List<Map<String, String>> fertilityQuestions = [
    {'q': 'When is my fertile window?', 'category': 'fertility'},
    {'q': 'How can I improve my chances of conceiving?', 'category': 'fertility'},
    {'q': 'What does egg white cervical mucus mean?', 'category': 'fertility'},
    {'q': 'When should I take a pregnancy test?', 'category': 'fertility'},
    {'q': 'What foods boost fertility?', 'category': 'nutrition'},
    {'q': 'Is it normal to have irregular cycles?', 'category': 'fertility'},
  ];

  static const List<Map<String, String>> pregnancyQuestions = [
    {'q': 'Is cramping normal in early pregnancy?', 'category': 'symptoms'},
    {'q': 'What foods should I avoid?', 'category': 'nutrition'},
    {'q': 'How much weight should I gain?', 'category': 'pregnancy'},
    {'q': 'When will I feel the baby move?', 'category': 'pregnancy'},
    {'q': 'What are signs of preeclampsia?', 'category': 'symptoms'},
    {'q': 'Safe exercises during pregnancy?', 'category': 'exercise'},
  ];
}
