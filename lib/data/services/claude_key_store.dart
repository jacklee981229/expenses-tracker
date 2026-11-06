import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps Jack's Claude API key in the iOS Keychain / Android Keystore:
/// never in the database, so never in a backup file.
class ClaudeKeyStore {
  const ClaudeKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _name = 'claude_api_key';

  /// Null when none is set, or the store cannot be read (say after Android
  /// restores the app's data onto a new phone), which means no Claude.
  Future<String?> read() async {
    try {
      final key = await _storage.read(key: _name);
      return key == null || key.isEmpty ? null : key;
    } on PlatformException {
      return null;
    }
  }

  Future<void> write(String key) => _storage.write(key: _name, value: key);

  Future<void> delete() => _storage.delete(key: _name);
}
