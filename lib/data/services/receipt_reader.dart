import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/receipt_parser.dart';

/// Reads an expense from a screenshot: the text is recognised on the phone
/// (no internet) and [parseReceipt] picks out the amount, shop and date.
/// The picture is never kept.
class ReceiptReader {
  /// Lets Jack pick a screenshot from Photos and reads it; null when he
  /// cancels.
  Future<ReceiptReading?> pickAndRead() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return _read(picked.path);
  }

  /// Reads the picture on the clipboard (the Back Tap shortcut puts a
  /// screenshot there); null when the clipboard holds no picture.
  Future<ReceiptReading?> readClipboard() async {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return null;
    // Text recognition reads files, so the picture passes through a
    // temporary one that is deleted straight after.
    final directory = await getTemporaryDirectory();
    final file = File(
      p.join(
        directory.path,
        'clipboard-${DateTime.now().millisecondsSinceEpoch}.png',
      ),
    );
    await file.writeAsBytes(bytes);
    try {
      return await _read(file.path);
    } finally {
      await file.delete();
    }
  }

  Future<ReceiptReading> _read(String path) async {
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
Future<ReceiptReading?> readSafely(Future<ReceiptReading?> reading) async {
  try {
    return await reading;
  } on Exception {
    return (amountMinor: null, shop: null, date: null, delivery: false);
  }
}
