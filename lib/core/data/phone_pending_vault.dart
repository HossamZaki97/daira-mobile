import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/json.dart';
import '../models/phone_auth.dart';

/// Temporary proof only, encrypted by the existing OS keystore. Never SQLite,
/// preferences, URLs back into the app, analytics or logs. Deleted on completion/logout.
class PhonePendingVault {
  const PhonePendingVault();
  static const _secure = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  String _key(String scope, String actor, PhonePurpose purpose) => 'daira.phone.$scope.$actor.${purpose.name}';
  Future<void> save(String scope, String actor, PhonePurpose purpose, PhoneChallenge value) =>
      _secure.write(key: _key(scope, actor, purpose), value: jsonEncode(value.toJson()));
  Future<PhoneChallenge?> read(String scope, String actor, PhonePurpose purpose) async {
    final key = _key(scope, actor, purpose);
    try {
      final raw = await _secure.read(key: key);
      if (raw == null) return null;
      final value = PhoneChallenge.fromJson(Json.from(jsonDecode(raw) as Map));
      if (value.expiresAt.isAfter(DateTime.now())) return value;
    } catch (_) {
      /* An unreadable old proof never signs anyone in. */
    }
    await _secure.delete(key: key);
    return null;
  }

  Future<void> clear(String scope, String actor, PhonePurpose purpose) =>
      _secure.delete(key: _key(scope, actor, purpose));
  Future<void> clearActor(String scope, String actor) async {
    for (final p in PhonePurpose.values) {
      await clear(scope, actor, p);
    }
  }
}
