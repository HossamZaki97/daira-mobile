import 'package:url_launcher/url_launcher.dart';

/// Opens a WhatsApp chat with [phone] (international form) and a ready [text].
/// False when WhatsApp (or a browser for wa.me) could not be opened.
Future<bool> openWhatsAppChat(String phone, String text) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return false;
  try {
    return await launchUrl(Uri.https('wa.me', '/$digits', {'text': text}), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
