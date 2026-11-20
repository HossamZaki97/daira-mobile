import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/router.dart';
import '../../core/models/contacts.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../state.dart';

/// «ربط فلان بحساب»: the organizer types or scans the person's account ID and
/// a request is sent; the link is made once the person accepts.
/// Returns the updated contact, or null when cancelled.
Future<Contact?> showLinkAccountSheet(BuildContext context, {required String contactId, required String name}) =>
    showAppSheet<Contact>(context, builder: (_) => _LinkAccountSheet(contactId: contactId, name: name));

class _LinkAccountSheet extends ConsumerStatefulWidget {
  const _LinkAccountSheet({required this.contactId, required this.name});
  final String contactId;
  final String name;

  @override
  ConsumerState<_LinkAccountSheet> createState() => _LinkAccountSheetState();
}

class _LinkAccountSheetState extends ConsumerState<_LinkAccountSheet> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
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
    final code = normalizeAccountCode(_code.text);
    if (code == null) {
      setState(() => _error = t.accountCodeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final contact = await ref.read(contactsRepositoryProvider).link(widget.contactId, code);
      refreshLists(ref.invalidate);
      if (!mounted) return;
      showToast(context, t.linkRequestSent(widget.name), tone: Tone.success);
      Navigator.pop(context, contact);
    } catch (error) {
      if (mounted) setState(() => _error = t.error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.linkTitle(widget.name), style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.linkBody, style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
        const SizedBox(height: Space.lg),
        AppTextField(
          controller: _code,
          label: t.accountCodeLabel,
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
        const SizedBox(height: Space.lg),
        AppButton(label: t.sendLinkRequest, icon: AppIcons.send, loading: _busy, onPressed: _send),
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
      ],
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
