import 'package:firebase_ai/firebase_ai.dart';
import 'package:authentication_app/constants/ai_constants.dart';

class AiChatService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: AiConstants.modelName,
  );

  final Map<String, dynamic> _sessions = {};

  Future<String> ask({
    required String chatId,
    required String prompt,
  }) async {
    final chat = _sessions.putIfAbsent(chatId, () => _model.startChat());
    final promptContent = Content.text(prompt);
    dynamic response;

    try {
      // Most Firebase AI Logic docs use a list payload.
      response = await chat.sendMessage([promptContent]);
    } catch (_) {
      // Some SDK variants accept a single Content payload.
      response = await chat.sendMessage(promptContent);
    }

    final text = (response.text ?? '').trim();
    if (text.isEmpty) {
      return 'I could not generate a response right now. Please try again.';
    }
    return text;
  }
}
