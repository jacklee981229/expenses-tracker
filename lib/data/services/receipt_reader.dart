import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/claude_receipt.dart';
import '../../core/utils/receipt_parser.dart';
import 'claude_api.dart';
import 'claude_key_store.dart';

/// Reads an expense from a screenshot: the text is recognised on the phone
/// and [parseReceipt] picks out the amount, shop and date. With a Claude API
/// key set, Claude reads the picture at the same time and its figures win.
class ReceiptReader {
  const ReceiptReader({required ClaudeApi claude, required ClaudeKeyStore keys})
    : _claude = claude,
      _keys = keys;

  final ClaudeApi _claude;
  final ClaudeKeyStore _keys;

  /// Lets Jack pick a screenshot from Photos; once picked, its reading is
  /// running. Null when he cancels. The picture is never kept.
  Future<Future<ReceiptReading>?> pick() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return _readFile(picked.path);
  }

  /// Starts reading the picture on the clipboard (the Back Tap shortcut puts
  /// a screenshot there); null when the clipboard holds no picture.
  Future<Future<ReceiptReading>?> clipboard() async {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return null;
    return _readBytes(bytes);
  }

  // Text recognition reads files, so clipboard bytes pass through a
  // temporary one that is deleted straight after.
  Future<ReceiptReading> _readBytes(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      p.join(
        directory.path,
        'clipboard-${DateTime.now().millisecondsSinceEpoch}.png',
      ),
    );
    await file.writeAsBytes(bytes);
    try {
      return await _readFile(file.path, bytes);
    } finally {
      await file.delete();
    }
  }

  Future<ReceiptReading> _readFile(String path, [Uint8List? bytes]) async {
    final claude = _readWithClaude(path, bytes);
    ReceiptReading onPhone;
    try {
      onPhone = await _recognise(path);
    } on Exception {
      // The recogniser failing must not lose Claude's reading.
      onPhone = _nothing;
    }
    return mergeReadings(onPhone, await claude);
  }

  /// Null without a key or on any failure: the phone's reading stands.
  Future<ClaudeReading?> _readWithClaude(String path, Uint8List? bytes) async {
    final key = await _keys.read();
    if (key == null) return null;
    try {
      final image = bytes ?? await File(path).readAsBytes();
      return await _claude.readReceipt(key: key, image: image);
    } on Exception {
      return null;
    }
  }

  Future<ReceiptReading> _recognise(String path) async {
    final recognizer = TextRecognizer();
    try {
      final text = await recognizer.processImage(InputImage.fromFilePath(path));
      return parseReceipt([
        for (final block in text.blocks)
          for (final line in block.lines)
            (
              text: line.text,
              top: line.boundingBox.top,
              bottom: line.boundingBox.bottom,
              left: line.boundingBox.left,
            ),
      ]);
    } finally {
      await recognizer.close();
    }
  }
}

/// Turns a reading error (a picture that cannot be opened, the recogniser
/// failing) into "found nothing", which the sheet already explains.
Future<ReceiptReading> readSafely(Future<ReceiptReading> reading) async {
  try {
    return await reading;
  } on Exception {
    return _nothing;
  }
}

const ReceiptReading _nothing = (
  amountMinor: null,
  shop: null,
  date: null,
  delivery: false,
  labels: <String>{},
);
