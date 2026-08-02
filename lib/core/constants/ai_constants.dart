/// Constants for the built-in AI assistant.
abstract class AiConstants {
  static const String aiUserId = 'ai_agent';
  static const String aiDisplayName = 'AI Assistant';
  static const String aiEmail = 'ai@chat.app';
  static const String aiDefaultMessage = 'Start chatting with AI...';
  static const String modelName = 'gemini-2.5-flash-lite';

  /// Message type stored in Firestore for AI-generated messages.
  static const String messageTypeAi = 'ai';
}
