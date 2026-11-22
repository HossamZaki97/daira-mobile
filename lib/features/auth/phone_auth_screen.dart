import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../core/api/api_exception.dart';
import '../../core/data/phone_auth_repository.dart';
import '../../core/models/json.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import 'auth_screens.dart';

/// One small flow for phone proof. Login itself only needs phone + password.
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({this.purpose, super.key});
  final PhonePurpose? purpose;
  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  late final PhoneAuthRepository _repo;
  late final String _actor;
  List<PhoneCountry> _countries = [];
  String _country = 'EG';
  PhoneChallenge? _challenge;
  Json? _finishBody;
  Timer? _poll;
  bool _busy = false, _checking = false, _verified = false, _expired = false, _restoring = true;
  bool _completed = false;
  Object? _error;
  bool get _login => widget.purpose == null;
  bool get _private => widget.purpose == PhonePurpose.attach || widget.purpose == PhonePurpose.change;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repo = ref.read(phoneAuthRepositoryProvider);
    _actor = _repo.actor;
    final saved = ref.read(preferencesProvider).getString('phone_country');
    final suggested = ref.read(clientInfoProvider).country;
    _country = saved ?? (suggested.isEmpty ? 'EG' : suggested);
    _restore();
  }

  Future<void> _restore() async {
    try {
      final countries = await _repo.countries();
      final pending = _login ? null : await _repo.vault.read(_repo.scope, _actor, widget.purpose!);
      if (!mounted) return;
      setState(() {
        _countries = countries;
        if (!countries.any((c) => c.code == _country)) _country = 'EG';
        _challenge = pending;
        if (pending != null) _phone.text = pending.phone;
      });
      if (pending != null) {
        _startPolling();
        await _check();
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    for (final c in [_phone, _password, _confirm, _name]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _poll?.cancel();
    if (state == AppLifecycleState.resumed && _challenge != null && !_verified && !_expired) {
      _check();
      _startPolling();
    }
  }

  void _startPolling() {
    _poll?.cancel();
    // Fits the server's per-route limit, pauses in the background, no overlapping calls.
    _poll = Timer.periodic(const Duration(seconds: 6), (_) => _check());
  }

  Future<void> _begin() async {
    if (_busy ||
        _challenge != null ||
        (_login && _repo.api.session.value != null) ||
        !(_form.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(sessionNoticeProvider.notifier).state = null;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_login) {
        await _repo.login(_phone.text, _country, _password.text);
      } else {
        final value = await _repo.start(
          _phone.text,
          _country,
          widget.purpose!,
          password: widget.purpose == PhonePurpose.change ? _password.text : null,
        );
        if (!mounted) return;
        // Keep only this short-lived proof in encrypted storage, never the password.
        await _repo.vault.save(_repo.scope, _actor, widget.purpose!, value);
        if (!mounted) return;
        setState(() {
          _challenge = value;
          _expired = false;
          _verified = false;
        });
        _password.clear();
        _startPolling();
      }
      await ref.read(preferencesProvider).setString('phone_country', _country);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openWhatsApp() async {
    final ch = _challenge;
    if (ch == null) return;
    try {
      final uri = Uri.https('wa.me', '/${ch.number.replaceAll('+', '')}', {'text': ch.text});
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
        setState(() => _error = const ApiException('whatsapp_open_failed'));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = const ApiException('whatsapp_open_failed'));
      }
    }
  }

  Future<void> _check() async {
    final ch = _challenge;
    if (ch == null || _checking || _busy || _verified || _expired) return;
    _checking = true;
    try {
      final result = await _repo.status(widget.purpose!, ch);
      if (!mounted || _challenge != ch) return;
      switch (result.str('state')) {
        case 'verified':
          _poll?.cancel();
          setState(() {
            _verified = true;
            _error = null;
          });
          if (_private) await _finish();
        case 'expired':
        case 'cancelled':
          _poll?.cancel();
          setState(() {
            _expired = true;
            _error = const ApiException('invalid_phone_challenge');
          });
        case 'completed':
          _poll?.cancel();
          if (_private) {
            await ref.read(accountRepositoryProvider).me();
            try {
              await _repo.vault.clear(_repo.scope, _actor, widget.purpose!);
            } catch (_) {
              /* Expiry is also enforced by Odoo. */
            }
            if (mounted) context.go(Routes.home);
          } else {
            setState(() {
              _expired = true;
              _error = const ApiException('phone_completed');
            });
          }
        default:
          setState(() {
            _error = result['phone_hidden'] == true
                ? const ApiException('phone_hidden')
                : result['other_number'] == true
                ? const ApiException('phone_other_number')
                : null;
          });
      }
    } catch (error) {
      if (mounted && _challenge == ch) setState(() => _error = error);
      if (DateTime.now().isAfter(ch.expiresAt)) {
        _poll?.cancel();
        if (mounted) setState(() => _expired = true);
      }
    } finally {
      _checking = false;
    }
  }

  Future<void> _finish() async {
    if (_busy || _completed || _challenge == null) return;
    if (!_private && _finishBody == null && !(_form.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ch = _challenge!;
    _finishBody ??= {
      'challenge': ch.secret,
      'command_id': ch.commandId,
      if (widget.purpose == PhonePurpose.signup) 'name': _name.text.trim(),
      if (!_private) 'password': _password.text,
    };
    try {
      // Clear the original actor's proof after success, even if a new session is issued.
      await _repo.finish(widget.purpose!, _finishBody!);
      _completed = true;
      try {
        await _repo.vault.clear(_repo.scope, _actor, widget.purpose!);
      } catch (_) {
        // The server acknowledged success; local cleanup must not present it as failure.
      }
      if (mounted && _private) context.go(Routes.home);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          if (error is ApiException && error.code != 'offline' && error.code != 'unavailable' && error.status < 500) {
            _finishBody = null;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restart() async {
    if (_busy) return;
    _poll?.cancel();
    if (widget.purpose != null) {
      await _repo.vault.clear(_repo.scope, _actor, widget.purpose!);
    }
    if (!mounted) return;
    setState(() {
      _challenge = null;
      _finishBody = null;
      _verified = false;
      _expired = false;
      _error = null;
      _password.clear();
      _confirm.clear();
      _name.clear();
    });
  }

  Future<void> _pickCountry() async {
    final t = context.l10n;
    if (_countries.isEmpty) {
      await _restore();
      if (!mounted || _countries.isEmpty) {
        return;
      }
    }
    var query = '';
    final selected = await showAppSheet<PhoneCountry>(
      context,
      builder: (sheet) => StatefulBuilder(
        builder: (context, update) {
          final visible = _countries
              .where(
                (c) => '${c.name} ${c.englishName} ${c.code} +${c.dial}'.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: Column(
              children: [
                Text(t.phoneCountry, style: context.text.titleLarge),
                const SizedBox(height: Space.sm),
                AppTextField(label: t.phoneCountrySearch, onChanged: (v) => update(() => query = v)),
                const SizedBox(height: Space.sm),
                Expanded(
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (_, i) {
                      final c = visible[i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.code}  +${c.dial}', textDirection: TextDirection.ltr),
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (selected != null && mounted) {
      setState(() => _country = selected.code);
      await ref.read(preferencesProvider).setString('phone_country', _country);
    }
  }

  Widget _passwordField(String label, TextEditingController c, {bool confirmation = false}) {
    final t = context.l10n;
    return AppTextField(
      label: label,
      controller: c,
      password: true,
      enabled: !_busy && _finishBody == null,
      textInputAction: confirmation || _login || widget.purpose == PhonePurpose.change
          ? TextInputAction.done
          : TextInputAction.next,
      onSubmitted: (_) {
        if (confirmation) {
          _finish();
        } else if (_login || (widget.purpose == PhonePurpose.change && !_verified)) {
          _begin();
        }
      },
      showPasswordLabel: t.showPassword,
      hidePasswordLabel: t.hidePassword,
      autofillHints: [confirmation || !_login ? AutofillHints.newPassword : AutofillHints.password],
      validator: (v) {
        if ((v ?? '').isEmpty) return t.requiredField;
        if (confirmation) {
          return v == _password.text ? null : t.phonePasswordMismatch;
        }
        if (!_login &&
            widget.purpose != PhonePurpose.change &&
            v!.length < (ref.read(settingsProvider)?.limits.minPassword ?? 8)) {
          return t.errorWeakPassword(ref.read(settingsProvider)?.limits.minPassword ?? 8);
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final ch = _challenge;
    final requestComplete = _error is ApiException && (_error as ApiException).code == 'phone_completed';
    final title = requestComplete
        ? t.phoneConfirmed
        : ch != null
        ? (_verified
              ? (widget.purpose == PhonePurpose.signup ? t.phoneFinishSignup : t.phoneConfirmed)
              : t.phoneWaitingTitle)
        : switch (widget.purpose) {
            PhonePurpose.signup => t.createAccount,
            PhonePurpose.reset => t.forgotPassword,
            PhonePurpose.attach => t.phoneAttachTitle,
            PhonePurpose.change => t.phoneChangeTitle,
            null => t.signInTitle,
          };
    final body = requestComplete
        ? t.phoneAlreadyFinished
        : ch != null
        ? (_verified ? t.phoneFinishBody : t.phoneWaitingBody)
        : switch (widget.purpose) {
            PhonePurpose.signup => t.phoneSignupBody,
            PhonePurpose.reset => t.phoneRecoverBody,
            PhonePurpose.attach => t.phoneAttachBody,
            PhonePurpose.change => t.phoneChangeBody,
            null => t.phoneSignInBody,
          };
    final country = _countries.where((c) => c.code == _country).firstOrNull;
    final notice = ref.watch(sessionNoticeProvider);
    final errorText = requestComplete
        ? null
        : _error is ApiException && (_error as ApiException).code == 'weak_password'
        ? t.errorWeakPassword(ref.read(settingsProvider)?.limits.minPassword ?? 8)
        : _error == null
        ? null
        : t.error(_error!);
    return Form(
      key: _form,
      child: AuthFrame(
        key: ValueKey(
          _challenge == null
              ? 'phone-input'
              : _verified
              ? 'phone-finish'
              : 'phone-waiting',
        ),
        title: title,
        body: body,
        children: [
          if (errorText != null) ...[
            InlineBanner(title: errorText, tone: Tone.danger),
            const SizedBox(height: Space.md),
          ],
          if (_login && errorText == null && notice != null) ...[
            InlineBanner(
              title: notice == ApiSignal.suspended ? t.errorSuspended : t.errorSessionEnded,
              tone: Tone.info,
            ),
            const SizedBox(height: Space.md),
          ],
          if (_restoring)
            const Center(child: CircularProgressIndicator())
          else if (ch == null) ...[
            OutlinedButton(
              onPressed: _busy ? null : _pickCountry,
              child: Row(
                children: [
                  Icon(AppIcons.language, size: 20, color: context.colors.primary),
                  const SizedBox(width: Space.sm),
                  Expanded(child: Text(country?.name ?? t.phoneCountry, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (country != null) ...[
                    const SizedBox(width: Space.sm),
                    Text('+${country.dial}', textDirection: TextDirection.ltr),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            AppTextField(
              label: t.phoneNumber,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: _login || widget.purpose == PhonePurpose.change
                  ? TextInputAction.next
                  : TextInputAction.done,
              onSubmitted: (_) {
                if (!_login && widget.purpose != PhonePurpose.change) _begin();
              },
              autofillHints: const [AutofillHints.telephoneNumber],
              textDirection: TextDirection.ltr,
              onChanged: (value) {
                final suggested = countryForPastedPhone(value, _country, _countries);
                if (suggested != null && suggested != _country) {
                  setState(() => _country = suggested);
                }
              },
              enabled: !_busy,
              validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
            ),
            if (_login || widget.purpose == PhonePurpose.change) ...[
              const SizedBox(height: Space.md),
              _passwordField(widget.purpose == PhonePurpose.change ? t.phoneCurrentPassword : t.password, _password),
            ],
            const SizedBox(height: Space.lg),
            AppButton(label: _login ? t.signIn : t.continueAction, loading: _busy, onPressed: _begin),
            if (_login) ...[
              AppButton.text(label: t.forgotPassword, onPressed: () => context.push(Routes.forgot)),
              AppButton.text(label: t.phoneEmailLogin, onPressed: () => context.push(Routes.emailSignIn)),
              AppButton.text(label: t.noAccountCreate, onPressed: () => context.go(Routes.signUp)),
            ],
            if (widget.purpose == PhonePurpose.signup) ...[
              AppButton.text(label: t.haveAccountSignIn, onPressed: () => context.go(Routes.signIn)),
              AppButton.text(label: t.phoneEmailLogin, onPressed: () => context.push(Routes.emailSignIn)),
            ],
            if (widget.purpose == PhonePurpose.reset)
              AppButton.text(label: t.phoneEmailRecovery, onPressed: () => context.push(Routes.emailForgot)),
            if (widget.purpose == PhonePurpose.reset)
              AppButton.text(label: t.backToSignIn, onPressed: () => context.go(Routes.signIn)),
          ] else ...[
            Text(ch.phone, textDirection: TextDirection.ltr, style: context.text.titleMedium),
            const SizedBox(height: Space.md),
            if (!_verified && !_expired) ...[
              Text(t.phoneWaiting, style: context.text.bodyLarge),
              const SizedBox(height: Space.lg),
              AppButton(label: t.phoneWhatsApp, onPressed: _openWhatsApp),
              AppButton.text(label: t.phoneCheckNow, onPressed: _check),
            ],
            if (_verified && !_private) ...[
              if (widget.purpose == PhonePurpose.signup) ...[
                AppTextField(
                  label: t.name,
                  controller: _name,
                  enabled: !_busy && _finishBody == null,
                  autofillHints: const [AutofillHints.name],
                  validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
                ),
                const SizedBox(height: Space.md),
              ],
              _passwordField(t.password, _password),
              const SizedBox(height: Space.md),
              _passwordField(t.phoneConfirmPassword, _confirm, confirmation: true),
              const SizedBox(height: Space.lg),
            ],
            if (_verified)
              AppButton(
                label: _finishBody == null ? t.continueAction : t.phoneRetryFinish,
                loading: _busy,
                onPressed: _finish,
              ),
            if (_expired && !requestComplete) AppButton.secondary(label: t.phoneRestart, onPressed: _restart),
            if (requestComplete)
              AppButton(
                label: t.signIn,
                onPressed: () async {
                  try {
                    await _repo.vault.clear(_repo.scope, _actor, widget.purpose!);
                  } catch (_) {
                    /* No session is granted by a return link. */
                  }
                  if (context.mounted) context.go(Routes.signIn);
                },
              ),
            if (_finishBody == null) AppButton.text(label: t.phoneEdit, onPressed: _busy ? null : _restart),
          ],
          if (_private) ...[
            if (ref.watch(settingsProvider)?.content.contains('help') == true)
              AppButton.text(label: t.phoneHelp, onPressed: () => context.push(Routes.content('help'))),
            AppButton.text(label: t.signOut, onPressed: _busy ? null : () => ref.read(authRepositoryProvider).logout()),
          ],
          if (_error is ApiException && (_error as ApiException).code == 'phone_in_use')
            AppButton.text(label: t.phoneLoginInstead, onPressed: _private ? null : () => context.go(Routes.signIn)),
          if (!_private && _error is ApiException && (_error as ApiException).code == 'phone_not_registered')
            AppButton.text(label: t.createAccount, onPressed: () => context.go(Routes.signUp)),
        ],
      ),
    );
  }
}
