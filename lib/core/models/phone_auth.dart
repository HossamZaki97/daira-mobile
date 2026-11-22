import 'json.dart';

enum PhonePurpose { signup, reset, attach, change }

String phoneDigits(String value) {
  const from = '٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
  return value.split('').map((c) {
    final i = from.indexOf(c);
    return i < 0 ? c : '${i % 10}';
  }).join();
}

/// A calling-code suggestion only; Odoo validates the complete number with libphonenumber.
String? countryForPastedPhone(String input, String current, List<PhoneCountry> countries) {
  var raw = phoneDigits(input).replaceAll(RegExp(r'[\s().-]'), '');
  if (raw.startsWith('00')) raw = '+${raw.substring(2)}';
  if (!raw.startsWith('+')) return null;
  final matches = countries.where((c) => raw.startsWith('+${c.dial}')).toList()
    ..sort((a, b) => b.dial.length.compareTo(a.dial.length));
  if (matches.isEmpty) return null;
  final longest = matches.first.dial.length;
  final best = matches.where((c) => c.dial.length == longest).toList();
  if (best.any((c) => c.code == current)) return current;
  if (best.any((c) => c.code == 'US')) return 'US';
  return best.first.code;
}

class PhoneCountry {
  const PhoneCountry(this.code, this.name, this.dial, [this.englishName = '']);
  factory PhoneCountry.fromJson(Json j) => PhoneCountry(j.str('code'), j.str('name'), j.str('dial'), j.str('name_en'));
  final String code, name, dial, englishName;
}

class PhoneChallenge {
  const PhoneChallenge({
    required this.secret,
    required this.phone,
    required this.number,
    required this.text,
    required this.expiresAt,
    required this.commandId,
  });
  factory PhoneChallenge.fromJson(Json j) => PhoneChallenge(
    secret: j.str('challenge'),
    phone: j.str('phone'),
    number: j.str('number'),
    text: j.str('text'),
    expiresAt: DateTime.parse(j.str('expires_at')),
    commandId: j.str('command_id'),
  );
  final String secret, phone, number, text, commandId;
  final DateTime expiresAt;
  Json toJson() => {
    'challenge': secret,
    'phone': phone,
    'number': number,
    'text': text,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'command_id': commandId,
  };
}
