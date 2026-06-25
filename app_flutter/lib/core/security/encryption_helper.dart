import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "github_access_token";

  /// Save GitHub token securely on the device keychain/keystore
  static Future<void> saveGithubToken(String token) async {
    await _storage.write(key: _tokenKey, value: token.trim());
  }

  /// Read GitHub token securely
  static Future<String?> getGithubToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the token from secure storage (logout/reset cache)
  static Future<void> deleteGithubToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
