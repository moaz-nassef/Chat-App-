import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/ai_constants.dart';
import '../../../core/errors/failure.dart';
import 'ai_settings.dart';
import 'ai_settings_store.dart';

/// Result of a successful connection test.
class AiTestResult {
  const AiTestResult({required this.reply, required this.latencyMs});

  /// What the model actually answered to the ping.
  final String reply;

  /// Round-trip time in milliseconds.
  final int latencyMs;
}

/// AI assistant gateway.
///
/// Two modes:
/// - **Custom provider** (user-configured in AI settings): calls the
///   provider's HTTP API directly — OpenAI-compatible (OpenRouter, OpenAI,
///   DeepSeek, xAI, custom), Gemini native, or Anthropic native.
/// - **Built-in fallback** (default): Firebase AI Logic with the
///   [AiConstants.modelName] model, exactly as before.
///
/// Keeps one conversation history per chatId so the model remembers
/// context, in both modes.
class AiRepo {
  AiRepo(this._settingsStore);

  final AiSettingsStore _settingsStore;

  /// Max remembered messages per chat (12 user + 12 assistant).
  static const int _historyLimit = 24;

  static const Duration _timeout = Duration(seconds: 30);

  // ─── Built-in (Firebase AI Logic) ─────────────────────────────────
  GenerativeModel? _firebaseModel;
  final Map<String, ChatSession> _firebaseSessions = {};

  GenerativeModel get _model =>
      _firebaseModel ??= FirebaseAI.googleAI().generativeModel(
        model: AiConstants.modelName,
      );

  // ─── Custom providers: per-chat history ───────────────────────────
  /// chatId → [{role: user|assistant, content: ...}]
  final Map<String, List<Map<String, String>>> _histories = {};

  /// Sends [prompt] and returns the assistant's reply.
  Future<String> ask({required String chatId, required String prompt}) async {
    final settings = _settingsStore.current.activeSettings;
    if (settings == null) {
      return _askBuiltin(chatId: chatId, prompt: prompt);
    }
    return _askCustom(settings, chatId: chatId, prompt: prompt);
  }

  /// Pings the provider with these exact (unsaved) settings.
  /// Throws [AiFailure] with a precise reason on any problem.
  Future<AiTestResult> testConnection(AiSettings settings) async {
    final apiKey = settings.apiKey.trim();
    final baseUrl = settings.baseUrl.trim();
    final model = settings.model.trim();

    if (apiKey.isEmpty) throw const AiFailure('❌ أدخل مفتاح API أولاً');
    if (baseUrl.isEmpty) throw const AiFailure('❌ أدخل الـ Base URL أولاً');
    if (model.isEmpty) throw const AiFailure('❌ أدخل اسم الموديل أولاً');

    final stopwatch = Stopwatch()..start();
    final reply = await _send(
      settings: settings,
      history: const [],
      prompt: 'Reply with exactly: OK',
    );
    stopwatch.stop();
    return AiTestResult(reply: reply, latencyMs: stopwatch.elapsedMilliseconds);
  }

  // ─── Built-in mode ────────────────────────────────────────────────

  Future<String> _askBuiltin({
    required String chatId,
    required String prompt,
  }) async {
    try {
      final chat = _firebaseSessions.putIfAbsent(
        chatId,
        () => _model.startChat(),
      );
      final response = await chat.sendMessage(Content.text(prompt));

      final text = (response.text ?? '').trim();
      if (text.isEmpty) {
        throw const AiFailure('❌ لم أستطع توليد رد الآن، حاول مرة أخرى');
      }
      return text;
    } on AiFailure {
      rethrow;
    } catch (e) {
      throw AiFailure('❌ خطأ في المساعد الذكي: $e');
    }
  }

  // ─── Custom provider mode ─────────────────────────────────────────

  Future<String> _askCustom(
    AiSettings settings, {
    required String chatId,
    required String prompt,
  }) async {
    final history = _histories.putIfAbsent(chatId, () => []);
    try {
      final reply = await _send(
        settings: settings,
        history: history,
        prompt: prompt,
      );
      history
        ..add({'role': 'user', 'content': prompt})
        ..add({'role': 'assistant', 'content': reply});
      if (history.length > _historyLimit) {
        history.removeRange(0, history.length - _historyLimit);
      }
      return reply;
    } on AiFailure {
      rethrow;
    } catch (e) {
      // Unexpected errors (bad URL, parsing, …) must surface as a
      // readable AiFailure — never as a silent unhandled async error.
      throw AiFailure('❌ خطأ في المساعد الذكي: $e');
    }
  }

  /// Dispatches to the right wire protocol and returns the reply text.
  Future<String> _send({
    required AiSettings settings,
    required List<Map<String, String>> history,
    required String prompt,
  }) {
    switch (settings.preset.transport) {
      case AiTransport.openAiCompatible:
        return _sendOpenAi(settings, history, prompt);
      case AiTransport.geminiNative:
        return _sendGemini(settings, history, prompt);
      case AiTransport.anthropicNative:
        return _sendAnthropic(settings, history, prompt);
    }
  }

  // ─── OpenAI-compatible (OpenRouter / OpenAI / DeepSeek / xAI / …) ──

  Future<String> _sendOpenAi(
    AiSettings settings,
    List<Map<String, String>> history,
    String prompt,
  ) async {
    final uri = _endpoint(settings.baseUrl, 'chat/completions');
    final body = {
      'model': settings.model,
      'messages': [
        ...history.map((m) => {'role': m['role'], 'content': m['content']}),
        {'role': 'user', 'content': prompt},
      ],
    };

    final json = await _post(
      uri,
      headers: {
        'Authorization': 'Bearer ${settings.apiKey}',
        'Content-Type': 'application/json',
        // OpenRouter ranking metadata — ignored elsewhere.
        'HTTP-Referer': 'https://chat.app',
        'X-Title': 'Chat App',
      },
      body: body,
    );

    final choices = json['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = choices.first['message'];
      final content = message is Map ? message['content'] : null;
      final text = _flattenContent(content);
      if (text.isNotEmpty) return text;
    }
    throw const AiFailure('❌ رد فارغ من المزود — تحقق من اسم الموديل');
  }

  // ─── Gemini native (generateContent) ──────────────────────────────

  Future<String> _sendGemini(
    AiSettings settings,
    List<Map<String, String>> history,
    String prompt,
  ) async {
    final base = settings.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/models/${settings.model}:generateContent');

    final contents = [
      ...history.map(
        (m) => {
          'role': m['role'] == 'assistant' ? 'model' : 'user',
          'parts': [
            {'text': m['content']},
          ],
        },
      ),
      {
        'role': 'user',
        'parts': [
          {'text': prompt},
        ],
      },
    ];

    final json = await _post(
      uri,
      headers: {
        'x-goog-api-key': settings.apiKey,
        'Content-Type': 'application/json',
      },
      body: {'contents': contents},
    );

    final blockReason =
        json['promptFeedback'] is Map
            ? json['promptFeedback']['blockReason']
            : null;
    if (blockReason != null) {
      throw AiFailure('❌ الطلب محظور من Gemini: $blockReason');
    }

    final candidates = json['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final parts = candidates.first['content']?['parts'];
      if (parts is List) {
        final text =
            parts
                .map((p) => p is Map ? (p['text'] ?? '') as String : '')
                .join()
                .trim();
        if (text.isNotEmpty) return text;
      }
    }
    throw const AiFailure('❌ رد فارغ من Gemini — تحقق من اسم الموديل');
  }

  // ─── Anthropic native (/messages) ─────────────────────────────────

  Future<String> _sendAnthropic(
    AiSettings settings,
    List<Map<String, String>> history,
    String prompt,
  ) async {
    final uri = _endpoint(settings.baseUrl, 'messages');
    final body = {
      'model': settings.model,
      // Required by the Anthropic API.
      'max_tokens': 1024,
      'messages': [
        ...history.map((m) => {'role': m['role'], 'content': m['content']}),
        {'role': 'user', 'content': prompt},
      ],
    };

    final json = await _post(
      uri,
      headers: {
        'x-api-key': settings.apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final content = json['content'];
    if (content is List) {
      final text =
          content
              .where((block) => block is Map && block['type'] == 'text')
              .map((block) => (block['text'] ?? '') as String)
              .join()
              .trim();
      if (text.isNotEmpty) return text;
    }
    throw const AiFailure('❌ رد فارغ من Claude — تحقق من اسم الموديل');
  }

  // ─── Shared HTTP plumbing ─────────────────────────────────────────

  Uri _endpoint(String baseUrl, String path) {
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/$path');
  }

  /// POSTs JSON, throws [AiFailure] with a precise Arabic reason on
  /// transport errors and non-2xx statuses, returns the decoded body.
  Future<Map<String, dynamic>> _post(
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async {
    final http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
    } on TimeoutException {
      throw const AiFailure('❌ انتهت مهلة الاتصال — الخادم لا يستجيب');
    } on SocketException {
      throw const AiFailure('❌ لا يوجد اتصال بالإنترنت');
    } on http.ClientException catch (e) {
      throw AiFailure('❌ فشل الاتصال: ${e.message}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw const AiFailure('❌ رد غير مفهوم من المزود (ليس JSON)');
      }
    }

    throw AiFailure(_describeHttpError(response));
  }

  /// Maps an HTTP failure to a clear, actionable Arabic message.
  String _describeHttpError(http.Response response) {
    final providerMessage = _extractProviderError(response.body);
    switch (response.statusCode) {
      case 400:
        return '❌ طلب غير صالح: $providerMessage';
      case 401:
      case 403:
        return '❌ مفتاح API غير صالح أو مرفوض';
      case 404:
        return '❌ الموديل غير موجود عند هذا المزود — تحقق من الاسم';
      case 429:
        return '❌ تم تجاوز الحد المسموح (الرصيد أو عدد الطلبات)';
      case 500:
      case 502:
      case 503:
        return '❌ خادم المزود معطل حالياً — حاول بعد قليل';
      default:
        return '❌ خطأ ${response.statusCode}: $providerMessage';
    }
  }

  /// Pulls `error.message` out of a provider error body, if present.
  String _extractProviderError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map && error['message'] is String) {
          return error['message'] as String;
        }
        if (decoded['message'] is String) return decoded['message'] as String;
      }
    } catch (_) {
      // Body wasn't JSON — fall through to the snippet.
    }
    final trimmed = body.trim();
    return trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed;
  }

  /// OpenAI content can be a plain string or a list of typed parts.
  String _flattenContent(Object? content) {
    if (content is String) return content.trim();
    if (content is List) {
      return content
          .map((part) => part is Map ? (part['text'] ?? '') as String : '')
          .join()
          .trim();
    }
    return '';
  }

  // ─── Session memory management ────────────────────────────────────

  /// Drops the conversation memory for one chat (e.g. chat deleted).
  void clearSession(String chatId) {
    _firebaseSessions.remove(chatId);
    _histories.remove(chatId);
  }

  /// Drops every conversation memory (e.g. the provider settings changed).
  void clearAllSessions() {
    _firebaseSessions.clear();
    _histories.clear();
  }
}
