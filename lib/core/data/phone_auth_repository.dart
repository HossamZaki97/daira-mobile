import '../api/api_client.dart';
import '../config.dart' show appLinkScheme;
import '../models/account.dart';
import '../models/json.dart';
import '../models/phone_auth.dart';
import 'phone_pending_vault.dart';
export '../models/phone_auth.dart';
export 'phone_pending_vault.dart';

class PhoneAuthRepository {
  PhoneAuthRepository(this.api, {PhonePendingVault? vault}) : vault = vault ?? const PhonePendingVault();
  final ApiClient api;
  final PhonePendingVault vault;
  String get scope => api.config.scope;
  String get actor => api.session.value?.profile.id ?? 'guest';
  bool _private(PhonePurpose p) => p == PhonePurpose.attach || p == PhonePurpose.change;
  String _path(PhonePurpose p, String action) => '${_private(p) ? '/me' : '/auth'}/phone/$action';
  Future<List<PhoneCountry>> countries() async => [
    for (final c in (await api.get('/auth/phone/countries', auth: false)).list('countries')) PhoneCountry.fromJson(c),
  ];
  Future<void> login(String phone, String country, String password) async {
    final data = await api.post(
      '/auth/phone/login',
      auth: false,
      body: {'phone': phone, 'country': country, 'password': password},
    );
    await api.startSession(data);
  }

  Future<PhoneChallenge> start(String phone, String country, PhonePurpose purpose, {String? password}) async {
    final data = await api.post(
      _path(purpose, 'start'),
      auth: _private(purpose),
      body: {
        'phone': phone,
        'country': country,
        'purpose': purpose.name,
        'return_scheme': appLinkScheme,
        if (password != null) 'password': password,
      },
    );
    return PhoneChallenge.fromJson({...data, 'command_id': newCommandId()});
  }

  Future<Json> status(PhonePurpose purpose, PhoneChallenge challenge) =>
      api.post(_path(purpose, 'status'), auth: _private(purpose), body: {'challenge': challenge.secret});
  Future<void> finish(PhonePurpose purpose, Json body) async {
    final data = await api.post(_path(purpose, 'finish'), auth: _private(purpose), body: body);
    if (_private(purpose)) {
      await api.updateProfile(Profile.fromJson(data.obj('profile')));
    } else {
      await api.startSession(data);
    }
  }
}
