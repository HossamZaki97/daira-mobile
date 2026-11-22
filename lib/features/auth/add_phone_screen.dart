import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import 'auth_screens.dart';
import 'phone_widgets.dart';

/// Adds the sign-in phone while WhatsApp confirmation is not set up yet: one
/// field, one button. The number is confirmed later, once WhatsApp works.
class AddPhoneScreen extends ConsumerStatefulWidget {
  const AddPhoneScreen({this.forced = false, super.key});

  /// Opened by the "phone required" gate: no way back except signing out.
  final bool forced;

  @override
  ConsumerState<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends ConsumerState<AddPhoneScreen> {
  final _form = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: ref.read(sessionProvider)?.profile.phone);
  late String _country;
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(preferencesProvider).getString('phone_country');
    final suggested = ref.read(clientInfoProvider).country;
    _country = saved ?? (suggested.isEmpty ? 'EG' : suggested);
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(phoneAuthRepositoryProvider).setPhone(_phone.text, _country);
      await ref.read(preferencesProvider).setString('phone_country', _country);
      if (!mounted) return;
      showToast(context, context.l10n.phoneSaved, tone: Tone.success);
      // The gate lets go by itself; from the account page, go back.
      if (!widget.forced && context.canPop()) context.pop();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final errorText = _error == null ? null : t.error(_error!);
    return Form(
      key: _form,
      child: AuthFrame(
        title: widget.forced ? t.phoneAttachTitle : t.phoneLinkAction,
        body: t.phoneAddBody,
        icon: AppIcons.devices,
        children: [
          if (errorText != null) ...[
            InlineBanner(title: errorText, tone: Tone.danger),
            const SizedBox(height: Space.md),
          ],
          PhoneInput(
            controller: _phone,
            country: _country,
            onCountry: (c) => setState(() => _country = c),
            enabled: !_busy,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: Space.xs),
          Text(t.phoneAddHint, style: context.text.bodySmall?.copyWith(color: context.colors.textMuted)),
          const SizedBox(height: Space.lg),
          AppButton(label: t.save, loading: _busy, onPressed: _save),
          if (widget.forced) ...[
            const SizedBox(height: Space.xl),
            Center(
              child: AppButton.text(
                label: t.signOut,
                onPressed: _busy ? null : () => ref.read(authRepositoryProvider).logout(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
