import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/utils/claude_receipt.dart';
import '../../core/utils/report_brief.dart';

/// Haiku read Jack's real screenshots as well as Opus did, faster and at a
/// fortieth of the cost. It has no server-side refusal fallback; a refusal
/// falls back to the phone's reading instead.
const String kReceiptModel = 'claude-haiku-5-5';
const int _receiptMaxTokens = 4000;

/// A slower reading is dropped: the phone's own reading is used.
const Duration kReceiptTimeout = Duration(seconds: 15);

/// Reading a month's expenses for patterns needs more judgement than a
/// screenshot: Sonnet at medium got every figure right where low miscounted.
const String kReportModel = 'claude-sonnet-5-5';
const int _reportMaxTokens = 16000;

/// Medium took 8.2 s for 60 expenses; a year's take reads far more.
const Duration kReportTimeout = Duration(seconds: 60);

/// The API's limit for one picture, as sent (base64).
const int _maxImageChars = 5 * 1024 * 1024;

/// Retries a cyber or frontier-LLM refusal on Sonnet 5; other refusals stay
/// refused, and the report says Claude did not answer.
const String _fallbackBeta = 'server-side-fallback-2026-07-01';

const String _reportPrompt =
    "You read one person's expenses from their own expense app (amounts in "
    'Malaysian ringgit, RM) and say what is worth knowing about the '
    'period.\n\n'
    "Your words open the app's report. Right below them the report prints "
    "the period's total with its change against the period before, and the "
    "three biggest categories with theirs. Don't repeat those figures: say "
    'what is behind them, or what they hide.\n\n'
    'Go through the individual expenses and look for:\n'
    '- habits: a shop, a weekday or a kind of expense that keeps coming back, '
    'with how often and what it came to;\n'
    '- exceptions: one expense, one day or one trip that moved a category or '
    'the total, or something new;\n'
    '- what the change against the period before is really made of.\n\n'
    'Name the shop, the day, the count and the amount. Prefer what moved the '
    'money: a habit earns a point when it adds up to something. Every figure '
    'must follow exactly from the expenses given; work sums out rather than '
    'estimating. If the period is still running, say "so far" where it '
    'matters. Plain, friendly sentences; no advice or judgement unless it '
    'follows plainly from the figures.\n\n'
    'Give a headline of at most 14 words (the single most useful thing: what '
    'the money mostly went on or what changed it, not a small habit) and two '
    'or three points of at most 22 words each, each with the category it is '
    'mostly about, or none. A short or quiet period gets two.';

/// The take's shape, its categories limited to the period's [categories]
/// and `none`.
Map<String, Object> takeSchema(Iterable<String> categories) => {
  'type': 'object',
  'properties': {
    'headline': {
      'type': 'string',
      'description': 'One sentence of at most 14 words.',
    },
    'points': {
      'type': 'array',
      'description': 'Two or three findings, most useful first.',
      'items': {
        'type': 'object',
        'properties': {
          'text': {
            'type': 'string',
            'description': 'One sentence of at most 22 words.',
          },
          'category': {
            'type': 'string',
            'enum': [...categories.toSet(), kNoCategory],
          },
        },
        'required': ['text', 'category'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['headline', 'points'],
  'additionalProperties': false,
};

/// Calls the Claude Messages API over plain HTTP: there is no official Dart
/// SDK.
class ClaudeApi {
  ClaudeApi({
    http.Client? client,
    this.receiptTimeout = kReceiptTimeout,
    this.reportTimeout = kReportTimeout,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration receiptTimeout;
  final Duration reportTimeout;

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
      'model': kReceiptModel,
      'max_tokens': _receiptMaxTokens,
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
    }, timeout: receiptTimeout);
    return reply == null ? null : parseClaudeReply(reply);
  }

  /// Claude's take on [brief], the period's expenses as text; [categories]
  /// are the period's category names. Null on any failure, as
  /// [readReceipt].
  Future<ClaudeTake?> reviewReport({
    required String key,
    required String brief,
    required Set<String> categories,
  }) async {
    final reply = await _send(
      key,
      {
        'model': kReportModel,
        'max_tokens': _reportMaxTokens,
        'fallbacks': 'default',
        'output_config': {
          'effort': 'medium',
          'format': {'type': 'json_schema', 'schema': takeSchema(categories)},
        },
        'system': _reportPrompt,
        'messages': [
          {'role': 'user', 'content': brief},
        ],
      },
      timeout: reportTimeout,
      beta: _fallbackBeta,
    );
    return reply == null ? null : parseTake(reply, categories);
  }

  /// Posts [body]; the decoded reply, or null for an error status, no
  /// network, a reply slower than [timeout] or a body that is not JSON.
  Future<Map<String, dynamic>?> _send(
    String key,
    Map<String, Object> body, {
    required Duration timeout,
    String? beta,
  }) async {
    try {
      final response = await _client
          .post(
            _messages,
            headers: {
              'content-type': 'application/json',
              'x-api-key': key,
              'anthropic-version': '2026-10-21',
              if (beta != null) 'anthropic-beta': beta,
            },
            body: jsonEncode(body),
          )
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
}
