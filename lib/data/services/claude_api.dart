import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/utils/claude_receipt.dart';

/// Haiku read Jack's real screenshots as well as Opus did, faster and at a
/// fortieth of the cost. It has no server-side refusal fallback; a refusal
/// falls back to the phone's reading instead.
const String kClaudeModel = 'claude-haiku-5-5';

/// A slower reply is dropped: the phone's own reading is used, or the
/// report says Claude did not answer.
const Duration kClaudeTimeout = Duration(seconds: 15);

/// The API's limit for one picture, as sent (base64).
const int _maxImageChars = 5 * 1024 * 1024;

const String _reviewPrompt =
    "You are looking at one person's spending report from their expense "
    'app, in Malaysian ringgit (RM). Write two to four short sentences in '
    'plain English on what stands out. Use only the figures given. No '
    'headings, lists or markdown.';

/// Calls the Claude Messages API over plain HTTP: there is no official Dart
/// SDK.
class ClaudeApi {
  ClaudeApi({http.Client? client, this.timeout = kClaudeTimeout})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static final Uri _messages = Uri.parse(
    'https://api.anthropic.com/v1/messages',
  );

  /// Reads a screenshot. Null for anything short of a clean answer (no
  /// network, a bad key, a refusal, a slow reply, a picture the API does
  /// not take), so the caller falls back to the phone's reading.
  Future<ClaudeReading?> readReceipt({
    required String key,
    required Uint8List image,
  }) async {
    final mediaType = imageMediaType(image);
    if (mediaType == null) return null;
    final data = base64Encode(image);
    if (data.length > _maxImageChars) return null;

    final reply = await _send(key, {
      'output_config': {
        // Reading a screenshot needs little thought; low keeps it quick.
        'effort': 'low',
        'format': {'type': 'json_schema', 'schema': kReceiptSchema},
      },
      'system': kReceiptPrompt,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mediaType,
                'data': data,
              },
            },
          ],
        },
      ],
    });
    return reply == null ? null : parseClaudeReply(reply);
  }

  /// A few sentences on [brief], the report's figures as text. Null on any
  /// failure, as [readReceipt].
  Future<String?> reviewReport({
    required String key,
    required String brief,
  }) async {
    final reply = await _send(key, {
      'output_config': {'effort': 'low'},
      'system': _reviewPrompt,
      'messages': [
        {'role': 'user', 'content': brief},
      ],
    });
    return reply == null ? null : replyText(reply);
  }

  /// Posts [request] with the model and its limits; the decoded reply, or
  /// null for an error status, no network, a slow reply or a body that is
  /// not JSON.
  Future<Map<String, dynamic>?> _send(
    String key,
    Map<String, Object> request,
  ) async {
    final body = <String, Object>{
      'model': kClaudeModel,
      'max_tokens': 4000,
      ...request,
    };
    try {
      final response = await _client
          .post(_messages, headers: _headers(key), body: jsonEncode(body))
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } on Exception {
      // TimeoutException, ClientException, SocketException, FormatException.
      return null;
    } on ArgumentError {
      // A pasted key with a character a header cannot carry.
      return null;
    }
  }

  Map<String, String> _headers(String key) => {
    'content-type': 'application/json',
    'x-api-key': key,
    'anthropic-version': '2026-10-21',
  };
}
