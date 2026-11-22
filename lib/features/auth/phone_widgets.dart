import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/phone_auth.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';

/// 🇪🇬 from "EG": two regional-indicator letters.
String flagOf(String code) => code.length != 2
    ? ''
    : String.fromCharCodes(code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41));

/// The countries for the calling-code picker (loaded once per app run).
final phoneCountriesProvider = FutureProvider<List<PhoneCountry>>((ref) => ref.watch(phoneAuthRepositoryProvider).countries());

/// One field for a phone number: the country's flag and calling code sit at its
/// start (tap to change), the number is typed after them. Pasting "+966…" picks
/// the country by itself.
class PhoneInput extends ConsumerStatefulWidget {
  const PhoneInput({
    required this.controller,
    required this.country,
    required this.onCountry,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String country;
  final ValueChanged<String> onCountry;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  ConsumerState<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends ConsumerState<PhoneInput> {
  Future<void> _pick(List<PhoneCountry> countries) async {
    final picked = await showAppSheet<PhoneCountry>(context, builder: (_) => _CountrySheet(countries: countries));
    if (picked == null || !mounted) return;
    widget.onCountry(picked.code);
    await ref.read(preferencesProvider).setString('phone_country', picked.code);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final countries = ref.watch(phoneCountriesProvider).valueOrNull ?? const <PhoneCountry>[];
    final country = countries.where((c) => c.code == widget.country).firstOrNull;
    return Directionality(
      // A phone number always reads left to right, even in Arabic.
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.phone,
        textInputAction: widget.textInputAction,
        autofillHints: const [AutofillHints.telephoneNumberNational],
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹+\s\-()]'))],
        onFieldSubmitted: widget.onSubmitted,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: (value) {
          final suggested = countryForPastedPhone(value, widget.country, countries);
          if (suggested != null && suggested != widget.country) widget.onCountry(suggested);
        },
        style: context.text.bodyLarge?.copyWith(letterSpacing: 0.5),
        validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
        decoration: InputDecoration(
          labelText: t.phoneNumber,
          hintText: '10 1234 5678',
          counterText: '',
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: Space.xs, end: Space.xxs),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.sm),
              onTap: !widget.enabled || countries.isEmpty ? null : () => _pick(countries),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flagOf(widget.country), style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: Space.xxs),
                    Text(
                      country == null ? '+' : '+${country.dial}',
                      style: context.text.titleSmall?.copyWith(color: colors.text),
                    ),
                    Icon(AppIcons.expand, size: 16, color: colors.textMuted),
                    const SizedBox(width: Space.xxs),
                    Container(width: 1, height: 24, color: colors.line),
                  ],
                ),
              ),
            ),
          ),
          constraints: const BoxConstraints(minHeight: Sizes.input),
        ),
      ),
    );
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.countries});
  final List<PhoneCountry> countries;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final q = _query.toLowerCase();
    final visible = [
      for (final c in widget.countries)
        if ('${c.name} ${c.englishName} ${c.code} +${c.dial}'.toLowerCase().contains(q)) c,
    ];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.phoneCountry, style: context.text.titleLarge),
          const SizedBox(height: Space.sm),
          AppTextField(label: t.phoneCountrySearch, icon: AppIcons.language, onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: Space.sm),
          Expanded(
            child: ListView.builder(
              itemCount: visible.length,
              itemBuilder: (_, i) {
                final c = visible[i];
                return ListTile(
                  leading: Text(flagOf(c.code), style: const TextStyle(fontSize: 24)),
                  title: Text(c.name),
                  trailing: Text('+${c.dial}', textDirection: TextDirection.ltr, style: context.text.labelLarge),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Where the person is in a phone flow: three short numbered steps.
class AuthSteps extends StatelessWidget {
  const AuthSteps({required this.labels, required this.current, super.key});
  final List<String> labels;

  /// 0-based.
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(height: 2, color: i <= current ? colors.primary : colors.line),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: context.reduceMotion ? Duration.zero : Motion.standard,
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current ? colors.success : (i == current ? colors.primary : colors.surface),
                  border: Border.all(color: i <= current ? Colors.transparent : colors.lineStrong),
                ),
                child: i < current
                    ? Icon(AppIcons.check, size: 14, color: colors.surface)
                    : Text(
                        '${i + 1}',
                        style: context.text.labelMedium?.copyWith(
                          color: i == current ? colors.onPrimary : colors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: Space.xxs),
              Text(
                labels[i],
                style: context.text.labelSmall?.copyWith(
                  color: i == current ? colors.text : colors.textMuted,
                  fontWeight: i == current ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// «Send the ready message from WhatsApp»: one big button, then a calm wait
/// that moves on by itself as soon as the message arrives.
class WhatsAppWaitCard extends StatelessWidget {
  const WhatsAppWaitCard({
    required this.phone,
    required this.number,
    required this.text,
    required this.onOpen,
    required this.onCheck,
    required this.onChangeNumber,
    this.checking = false,
    super.key,
  });

  /// The person's own number (the message must come from it).
  final String phone;

  /// Daira's WhatsApp number and the ready text.
  final String number;
  final String text;
  final VoidCallback onOpen;
  final VoidCallback onCheck;
  final VoidCallback? onChangeNumber;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: colors.successContainer, shape: BoxShape.circle),
                    child: Icon(AppIcons.message, size: 22, color: colors.success),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.phoneSendFrom, style: context.text.bodySmall),
                        Text(phone, textDirection: TextDirection.ltr, style: context.text.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              AppButton(label: t.phoneOpenWhatsApp, icon: AppIcons.send, onPressed: onOpen),
              const SizedBox(height: Space.md),
              // The wait: it continues by itself; the link only checks right away.
              Row(
                children: [
                  const RingLoader(size: 20),
                  const SizedBox(width: Space.sm),
                  Expanded(child: Text(t.phoneWaiting, style: context.text.bodyMedium)),
                ],
              ),
              const SizedBox(height: Space.xxs),
              Center(child: AppButton.text(label: t.phoneCheckNow, onPressed: checking ? null : onCheck)),
            ],
          ),
        ),
        // If WhatsApp did not open: the same message by hand, folded away.
        _ManualSend(number: number, text: text),
        if (onChangeNumber != null) ...[
          const SizedBox(height: Space.xs),
          Center(child: AppButton.text(label: t.phoneEdit, onPressed: onChangeNumber)),
        ],
      ],
    );
  }
}

/// «واتساب لم يفتح؟»: one quiet line; opens to the text and number to send by hand.
class _ManualSend extends StatefulWidget {
  const _ManualSend({required this.number, required this.text});
  final String number;
  final String text;

  @override
  State<_ManualSend> createState() => _ManualSendState();
}

class _ManualSendState extends State<_ManualSend> {
  bool _open = false;

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) showToast(context, context.l10n.copied);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return AnimatedSize(
      duration: context.reduceMotion ? Duration.zero : Motion.standard,
      alignment: Alignment.topCenter,
      child: !_open
          ? Center(
              child: AppButton.text(label: t.phoneManualOpen, onPressed: () => setState(() => _open = true)),
            )
          : Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.phoneManualHint, style: context.text.bodySmall),
                  const SizedBox(height: Space.xxs),
                  for (final value in [widget.text, widget.number])
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            textDirection: TextDirection.ltr,
                            style: context.text.labelLarge?.copyWith(color: colors.text),
                          ),
                        ),
                        IconButton(
                          tooltip: t.copyCode,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(AppIcons.copy, size: 18, color: colors.textMuted),
                          onPressed: () => _copy(value),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
