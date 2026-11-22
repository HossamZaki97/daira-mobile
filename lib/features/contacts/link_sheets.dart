import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/router.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/contacts.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../auth/phone_widgets.dart';
import '../state.dart';
import '../whatsapp.dart';

/// «ربط فلان بحساب»: by phone number (a confirmed Daira account is asked to
/// accept; someone not on Daira yet can be invited on WhatsApp), or by the
/// account ID they show on their «Account» page.
/// Returns the updated contact, or null when cancelled.
Future<Contact?> showLinkAccountSheet(
  BuildContext context, {
  required String contactId,
  required String name,
  String? phone,
}) => showAppSheet<Contact>(
  context,
  builder: (_) => _LinkAccountSheet(contactId: contactId, name: name, phone: phone),
);

enum _LinkBy { phone, code }

class _LinkAccountSheet extends ConsumerStatefulWidget {
  const _LinkAccountSheet({required this.contactId, required this.name, this.phone});
  final String contactId;
  final String name;
  final String? phone;

  @override
  ConsumerState<_LinkAccountSheet> createState() => _LinkAccountSheetState();
}

class _LinkAccountSheetState extends ConsumerState<_LinkAccountSheet> {
  final _code = TextEditingController();
  late final _phone = TextEditingController(text: widget.phone);
  late String _country;
  _LinkBy _by = _LinkBy.phone;
  bool _busy = false;
  String? _error;

  /// Set when the number is not on Daira: the WhatsApp invitation step.
  PhoneLink? _notOnDaira;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(preferencesProvider).getString('phone_country');
    final suggested = ref.read(clientInfoProvider).country;
    _country = saved ?? (suggested.isEmpty ? 'EG' : suggested);
  }

  @override
  void dispose() {
    _code.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scanned = await context.push<String>(Routes.scanCode);
    if (scanned != null && mounted) {
      setState(() {
        _code.text = scanned;
        _error = null;
      });
    }
  }

  Future<void> _send() async {
    final t = context.l10n;
    final code = _by == _LinkBy.code ? normalizeAccountCode(_code.text) : null;
    if (_by == _LinkBy.code && code == null) {
      setState(() => _error = t.accountCodeInvalid);
      return;
    }
    if (_by == _LinkBy.phone && _phone.text.trim().isEmpty) {
      setState(() => _error = t.requiredField);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(contactsRepositoryProvider);
      if (code != null) {
        final contact = await repo.link(widget.contactId, code);
        _sent(contact);
        return;
      }
      final answer = await repo.linkByPhone(widget.contactId, _phone.text, _country);
      refreshLists(ref.invalidate);
      if (answer.onDaira) {
        _sent(answer.contact);
      } else if (mounted) {
        setState(() => _notOnDaira = answer);
      }
    } catch (error) {
      if (mounted) setState(() => _error = t.error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _sent(Contact contact) {
    refreshLists(ref.invalidate);
    if (!mounted) return;
    showToast(context, context.l10n.linkRequestSent(widget.name), tone: Tone.success);
    Navigator.pop(context, contact);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final invite = _notOnDaira;
    if (invite != null) return _InviteStep(name: widget.name, answer: invite);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.linkTitle(widget.name), style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(
          _by == _LinkBy.phone ? t.linkByPhoneBody : t.linkBody,
          style: context.text.bodyMedium?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: Space.md),
        SegmentedTabs<_LinkBy>(
          items: [(_LinkBy.phone, t.phoneNumber, null), (_LinkBy.code, t.accountIdTab, null)],
          value: _by,
          onChanged: (v) => setState(() {
            _by = v;
            _error = null;
          }),
        ),
        const SizedBox(height: Space.md),
        if (_by == _LinkBy.phone) ...[
          PhoneInput(
            controller: _phone,
            country: _country,
            onCountry: (c) => setState(() => _country = c),
            enabled: !_busy,
            autofocus: widget.phone == null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text(_error!, style: context.text.bodySmall?.copyWith(color: colors.danger)),
            ),
        ] else ...[
          AppTextField(
            controller: _code,
            label: t.memberAccountCode,
            hint: 'DA-XXXXXX',
            icon: AppIcons.user,
            textDirection: TextDirection.ltr,
            autofocus: true,
            errorText: _error,
            inputFormatters: [UpperCaseFormatter()],
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: Space.sm),
          AppButton.secondary(label: t.scanCode, icon: AppIcons.scan, onPressed: _busy ? null : _scan),
        ],
        const SizedBox(height: Space.lg),
        AppButton(
          label: _by == _LinkBy.phone ? t.continueAction : t.sendLinkRequest,
          icon: _by == _LinkBy.phone ? null : AppIcons.send,
          loading: _busy,
          onPressed: _send,
        ),
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

/// «فلان مش على دايرة لسه»: invite them on WhatsApp with the app link.
/// Pops the sheet with the contact either way.
class _InviteStep extends ConsumerWidget {
  const _InviteStep({required this.name, required this.answer});
  final String name;
  final PhoneLink answer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.notOnDairaTitle(name), style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.notOnDairaBody(name), style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: Space.lg),
        AppButton(
          label: t.inviteOnWhatsApp,
          icon: AppIcons.message,
          onPressed: () async {
            final me = ref.read(sessionProvider)?.profile.name ?? '';
            final text = t.inviteOnWhatsAppText(name, me, answer.appUrl ?? '').trim();
            if (!await openWhatsAppChat(answer.contact.phone ?? '', text)) {
              if (context.mounted) showToast(context, t.phoneCannotOpen, tone: Tone.danger);
              return;
            }
            if (context.mounted) Navigator.pop(context, answer.contact);
          },
        ),
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.notNow, onPressed: () => Navigator.pop(context, answer.contact)),
      ],
    );
  }
}

/// «أضف برقم الموبايل» (new circle, members step): name and number. Someone on
/// Daira is asked to accept at once; someone else can be invited on WhatsApp.
/// Returns the new contact to put in the circle, or null when cancelled.
Future<Contact?> showAddByPhoneSheet(BuildContext context) =>
    showAppSheet<Contact>(context, builder: (_) => const _AddByPhoneSheet());

class _AddByPhoneSheet extends ConsumerStatefulWidget {
  const _AddByPhoneSheet();

  @override
  ConsumerState<_AddByPhoneSheet> createState() => _AddByPhoneSheetState();
}

class _AddByPhoneSheetState extends ConsumerState<_AddByPhoneSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  late String _country;
  bool _busy = false;
  String? _error;
  PhoneLink? _notOnDaira;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(preferencesProvider).getString('phone_country');
    final suggested = ref.read(clientInfoProvider).country;
    _country = saved ?? (suggested.isEmpty ? 'EG' : suggested);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    final t = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(contactsRepositoryProvider);
    try {
      // The number is checked first, so a typo never leaves a half-made contact.
      final contact = await repo.create(_name.text.trim(), phone: _phone.text, country: _country);
      PhoneLink answer;
      try {
        answer = await repo.linkByPhone(contact.id, _phone.text, _country);
      } on ApiException catch (error) {
        // Already linked to me under another contact, or my own number: keep the contact as is.
        if (error.code == 'own_account' || error.code == 'already_linked') {
          refreshLists(ref.invalidate);
          if (mounted) Navigator.pop(context, contact);
          return;
        }
        rethrow;
      }
      refreshLists(ref.invalidate);
      if (!mounted) return;
      if (answer.onDaira) {
        showToast(context, t.linkRequestSent(contact.name), tone: Tone.success);
        Navigator.pop(context, answer.contact);
      } else {
        setState(() => _notOnDaira = answer);
      }
    } catch (error) {
      if (mounted) setState(() => _error = t.error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final invite = _notOnDaira;
    if (invite != null) return _InviteStep(name: invite.contact.name, answer: invite);
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.addByPhoneTitle, style: context.text.titleLarge),
          const SizedBox(height: Space.xs),
          Text(t.addByPhoneBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
          const SizedBox(height: Space.lg),
          if (_error != null) ...[
            InlineBanner(title: _error!, tone: Tone.danger),
            const SizedBox(height: Space.md),
          ],
          AppTextField(
            controller: _name,
            label: t.name,
            icon: AppIcons.user,
            maxLength: 100,
            autofocus: true,
            enabled: !_busy,
            textInputAction: TextInputAction.next,
            validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
          ),
          const SizedBox(height: Space.md),
          PhoneInput(
            controller: _phone,
            country: _country,
            onCountry: (c) => setState(() => _country = c),
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _add(),
          ),
          const SizedBox(height: Space.lg),
          AppButton(label: t.addMember, icon: AppIcons.add, loading: _busy, onPressed: _add),
          const SizedBox(height: Space.xs),
          AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

/// «رقم حسابك»: shown on the account page; organizers use it to link you.
class AccountIdCard extends ConsumerWidget {
  const AccountIdCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final colors = context.colors;
    final code = ref.watch(sessionProvider)?.profile.accountCode;
    if (code == null) return const SizedBox.shrink();
    return AppCard(
      onTap: () => showAppSheet<void>(context, builder: (_) => _AccountIdSheet(code: code)),
      padding: const EdgeInsetsDirectional.fromSTEB(Space.md, Space.sm, Space.xs, Space.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: colors.accentContainer, shape: BoxShape.circle),
            child: Icon(AppIcons.qr, size: 22, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.accountCodeLabel, style: context.text.labelSmall),
                Text(
                  code,
                  textDirection: TextDirection.ltr,
                  style: DairaType.amountM.copyWith(color: colors.text, letterSpacing: 1),
                ),
                Text(t.accountCodeHint, style: context.text.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: t.copyCode,
            icon: Icon(AppIcons.copy, color: colors.textMuted),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) showToast(context, t.copied);
            },
          ),
        ],
      ),
    );
  }
}

class _AccountIdSheet extends StatelessWidget {
  const _AccountIdSheet({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.accountCodeLabel, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.accountCodeSheetBody, style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
        const SizedBox(height: Space.lg),
        Center(
          child: Container(
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              // Always dark on white so any camera reads it, in both themes.
              color: Colors.white,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: colors.line),
            ),
            child: QrImageView(
              data: code,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF1E2A4A)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF1E2A4A)),
              semanticsLabel: code,
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Text(
          code,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: DairaType.amountL.copyWith(color: colors.text, letterSpacing: 2),
        ),
        const SizedBox(height: Space.lg),
        AppButton(
          label: t.share,
          icon: AppIcons.share,
          onPressed: () => Share.share(t.accountCodeShare(code)),
        ),
        const SizedBox(height: Space.xs),
        AppButton.secondary(
          label: t.copyCode,
          icon: AppIcons.copy,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (context.mounted) showToast(context, t.copied);
          },
        ),
      ],
    );
  }
}
