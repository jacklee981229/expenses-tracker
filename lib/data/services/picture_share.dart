import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Pixels per logical pixel in a shared picture: sharp on a phone screen
/// without making a long picture too big to send.
const double kSharePixelRatio = 3;

/// Whether a picture is on its way to the share sheet: a second tap then
/// does nothing.
bool _sharing = false;

/// Turns what [boundary] paints into a PNG named [fileName] and opens the
/// phone's share sheet with it; its Save Image puts it in Photos. A
/// boundary inside a scroll view still paints all of its child, so a long
/// picture comes out whole. Returns whether it was shared or saved.
Future<bool> sharePicture(
  RenderRepaintBoundary boundary, {
  required String fileName,
}) => _once(() async => _share(await _savePicture(boundary, fileName)));

/// Shares [picture], a widget that is not on screen, as [sharePicture]
/// does: it is laid out [width] wide in the app's overlay under [context]
/// (so it has the app's theme and providers), out of sight to the left,
/// and taken away again once painted. Anything in it that animates in
/// should start finished, or it is caught on its first frame.
Future<bool> shareOffscreen(
  BuildContext context,
  Widget picture, {
  required double width,
  required String fileName,
}) => _once(() async {
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -width * 2,
      top: 0,
      width: width,
      child: IgnorePointer(
        child: RepaintBoundary(
          key: key,
          // The overlay has no Material of its own, without which text is
          // drawn in Flutter's yellow-underlined warning style.
          child: Material(type: MaterialType.transparency, child: picture),
        ),
      ),
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  final File file;
  try {
    await WidgetsBinding.instance.endOfFrame;
    file = await _savePicture(
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary,
      fileName,
    );
  } finally {
    entry.remove();
  }
  return _share(file);
});

Future<bool> _once(Future<bool> Function() share) async {
  if (_sharing) return false;
  _sharing = true;
  try {
    return await share();
  } finally {
    _sharing = false;
  }
}

Future<File> _savePicture(
  RenderRepaintBoundary boundary,
  String fileName,
) async {
  final image = await boundary.toImage(pixelRatio: kSharePixelRatio);
  final ByteData? png;
  try {
    png = await image.toByteData(format: ui.ImageByteFormat.png);
  } finally {
    image.dispose();
  }
  final file = File('${(await getTemporaryDirectory()).path}/$fileName.png');
  await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
  return file;
}

Future<bool> _share(File file) async {
  final result = await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path, mimeType: 'image/png')]),
  );
  return result.status != ShareResultStatus.dismissed;
}
