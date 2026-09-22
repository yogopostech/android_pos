import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shudhu deviceId secure storage-e save korar jonno.
/// v10-e kono option lage na — default-i sob theke secure.
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _kDeviceId = 'device_id';

  /// Frequently read korle prottek bar disk hit na kore memory theke debe.
  /// App start-e ekbar SecureStorage.init() call koro.
  static String? _deviceIdCache;

  static Future<void> init() async {
    try {
      _deviceIdCache = await _storage.read(key: _kDeviceId);
    } catch (e) {
      debugPrint('SecureStorage init error: $e');
    }
  }

  /// sync getter (init howar por)
  static String? get deviceId => _deviceIdCache;

  /// async, jodi init na korei sorasori porte chao
  static Future<String?> readDeviceId() => _storage.read(key: _kDeviceId);

  static Future<void> setDeviceId(String value) async {
    _deviceIdCache = value;
    await _storage.write(key: _kDeviceId, value: value);
  }

  static Future<void> clear() async {
    _deviceIdCache = null;
    await _storage.deleteAll();
  }
}