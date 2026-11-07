import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Keeps the cloud backup token in the iOS Keychain / Android Keystore, as
/// `ClaudeKeyStore` keeps the Claude key: never in the database, so never in
/// a backup. On an iPhone it outlives deleting the app.
class CloudBackupTokenStore {
  const CloudBackupTokenStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _name = 'cloud_backup_token';

  /// Null when none is set or the store cannot be read.
  Future<String?> read() async {
    try {
      final token = await _storage.read(key: _name);
      return token == null || token.isEmpty ? null : token;
    } on PlatformException {
      return null;
    }
  }

  Future<void> write(String token) => _storage.write(key: _name, value: token);

  Future<void> delete() => _storage.delete(key: _name);
}

/// The token as typed: case, spaces and the dashes between its groups don't
/// count, as on the Worker.
String tidyToken(String typed) =>
    typed.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// Cloud backup on this phone: whether it was set up here (a token alone may
/// be left over from an earlier install), and the last try and good upload
/// (milliseconds since 1970).
class CloudBackupState {
  const CloudBackupState({this.setUp = false, this.lastTryAt, this.lastGoodAt});

  final bool setUp;
  final int? lastTryAt;
  final int? lastGoodAt;

  Map<String, Object?> toJson() => {
    'setUp': setUp,
    'lastTryAt': lastTryAt,
    'lastGoodAt': lastGoodAt,
  };

  static CloudBackupState fromJson(Object? json) => switch (json) {
    {'setUp': final bool setUp} => CloudBackupState(
      setUp: setUp,
      lastTryAt: json['lastTryAt'] is int ? json['lastTryAt'] as int : null,
      lastGoodAt: json['lastGoodAt'] is int ? json['lastGoodAt'] as int : null,
    ),
    _ => const CloudBackupState(),
  };
}

/// [CloudBackupState] in `cloud_backup.json` in the app's support folder,
/// which goes with the app when it is deleted: a reinstall starts not set
/// up.
class CloudBackupStateStore {
  CloudBackupStateStore({Future<File> Function()? file})
    : _file = file ?? _defaultFile;

  final Future<File> Function() _file;

  static Future<File> _defaultFile() async => File(
    p.join((await getApplicationSupportDirectory()).path, 'cloud_backup.json'),
  );

  /// Not set up when the file is missing or broken.
  Future<CloudBackupState> read() async {
    try {
      return CloudBackupState.fromJson(
        jsonDecode(await (await _file()).readAsString()),
      );
    } on FileSystemException {
      return const CloudBackupState();
    } on FormatException {
      return const CloudBackupState();
    }
  }

  Future<void> write(CloudBackupState state) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    // Written beside it, then moved over: a crash mid-write never leaves half
    // a file.
    final next = File('${file.path}.tmp');
    await next.writeAsString(jsonEncode(state.toJson()));
    await next.rename(file.path);
  }
}
