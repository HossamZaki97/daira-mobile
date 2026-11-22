import 'json.dart';

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.lang = 'ar',
    this.accountCode,
    this.autoJoin = true,
    this.phone,
    this.phoneVerified = false,
    this.phoneRequired = false,
    this.isReview = false,
  });
  factory Profile.fromJson(Json json) => Profile(
    id: json.str('id'),
    name: json.str('name'),
    email: json.str('email'),
    lang: json.str('lang', 'ar'),
    accountCode: json.strOrNull('account_code'),
    autoJoin: json['auto_join'] != false,
    phone: json.strOrNull('phone'),
    phoneVerified: json['phone_verified'] == true,
    phoneRequired: json['phone_required'] == true,
    isReview: json['is_review'] == true,
  );

  final String id;
  final String name;
  final String email;
  final String lang;

  /// «رقم حسابك» (DA-XXXXXX): organizers use it to link a contact to this account.
  final String? accountCode;

  /// «إضافتي مباشرة»: organizers I am linked with add me to new circles without asking.
  final bool autoJoin;
  final String? phone;
  final bool phoneVerified;
  final bool phoneRequired;
  final bool isReview;

  Profile requiringPhone() => Profile(
    id: id,
    name: name,
    email: email,
    lang: lang,
    accountCode: accountCode,
    autoJoin: autoJoin,
    phone: phone,
    phoneVerified: phoneVerified,
    phoneRequired: true,
    isReview: isReview,
  );

  Json toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'lang': lang,
    if (accountCode != null) 'account_code': accountCode,
    'auto_join': autoJoin,
    'phone': phone,
    'phone_verified': phoneVerified,
    'phone_required': phoneRequired,
    'is_review': isReview,
  };
}

/// One signed-in phone, from GET /me/sessions.
class DeviceSession {
  const DeviceSession({
    required this.id,
    this.device,
    this.platform,
    this.appVersion,
    this.lastUsedAt,
    this.current = false,
  });

  factory DeviceSession.fromJson(Json json) => DeviceSession(
    id: json.str('id'),
    device: json.strOrNull('device'),
    platform: json.strOrNull('platform'),
    appVersion: json.strOrNull('app_version'),
    lastUsedAt: json.date('last_used_at'),
    current: json.flag('current'),
  );

  final String id;
  final String? device;
  final String? platform;
  final String? appVersion;
  final DateTime? lastUsedAt;
  final bool current;
}
