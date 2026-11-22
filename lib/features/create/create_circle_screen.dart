import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/circle.dart';
import '../../core/models/contacts.dart';
import '../../core/models/json.dart';
import '../../core/models/money.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../contacts/link_sheets.dart';
import '../feed.dart';
import '../state.dart';
import 'wizard_parts.dart';

const _lastCurrencyKey = 'last_currency';

class _MemberDraft {
  _MemberDraft(this.id, {String name = '', this.shares = 1, this.contact}) : name = TextEditingController(text: name);
  final int id;
  final TextEditingController name;
  final FocusNode focus = FocusNode();
  int shares;

  /// Picked from the organizer's contacts (the same person across circles).
  Contact? contact;

  bool get filled => name.text.trim().isNotEmpty;

  void dispose() {
    name.dispose();
    focus.dispose();
  }
}

class _Turn {
  const _Turn(this.id, this.participant);
  final int id;

  /// 0 = organizer, 1.. = members in the order they were added.
  final int participant;
}

/// Four short steps: basics, members, turn order, review. Also edits a draft.
class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({this.draftId, super.key});
  final String? draftId;

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen> {
  static const _steps = 4;
  int _step = 0;
  int _nextId = 0;

  final _name = TextEditingController();
  final _amount = TextEditingController();
  String? _currency;
  Cadence _cadence = Cadence.month;
  int _interval = 1;
  DateTime _startDate = _today();

  /// «The circle already started»: the organizer gives the next due date and
  /// marks who already received; earlier dates are worked out from it.
  bool _started = false;
  DateTime _nextDue = _today();
  bool _shuffling = false;

  /// The current order came from «ترتيب عشوائي» (any manual move clears it).
  bool _shuffled = false;

  DateTime get _start => _started ? _dueFrom(_nextDue, -_imported) : _startDate;
  int _myShares = 1;
  final _members = <_MemberDraft>[];
  List<_Turn> _order = [];
  bool _orderTouched = false;
  int _imported = 0;

  Circle? _draft;
  bool _loadingDraft = false;
  Object? _loadError;
  bool _busy = false;
  Object? _error;
  String _commandId = newCommandId();
  final _basicsForm = GlobalKey<FormState>();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _editing => widget.draftId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _loadDraft();
    } else {
      _resetOrder();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _newName.dispose();
    _newFocus.dispose();
    for (final m in _members) {
      m.dispose();
    }
    super.dispose();
  }

  AppSettings? get _settings => ref.read(settingsProvider);
  Limits get _limits => _settings?.limits ?? const Limits();
  Features get _features => _settings?.features ?? const Features();
  int get _maxShares => _features.multiShares ? _limits.maxShares : 1;

  Currency get _currencyInfo {
    final settings = _settings;
    // The person's choice > last currency they used > server suggestion (phone country) > default.
    final last = ref.read(preferencesProvider).getString(_lastCurrencyKey);
    final remembered = last != null && settings?.currency(last) != null ? last : null;
    final code = _currency ?? remembered ?? settings?.suggestedCurrency ?? 'EGP';
    return settings?.currency(code) ?? Currency(code: code, decimals: 2);
  }

  int get _totalShares => _myShares + _members.fold(0, (sum, m) => sum + m.shares);

  int? get _amountMinor => Money.parseMinor(_amount.text, _currencyInfo.decimals);

  String _participantName(int index) {
    final t = context.l10n;
    if (index == 0) return t.youName(ref.read(sessionProvider)?.profile.name ?? '');
    final name = _members[index - 1].name.text.trim();
    return name.isEmpty ? t.memberNumber(index) : name;
  }

  // ------------------------------------------------------------ draft
  Future<void> _loadDraft() async {
    setState(() {
      _loadingDraft = true;
      _loadError = null;
    });
    try {
      final c = await ref.read(circlesRepositoryProvider).get(widget.draftId!);
      if (!mounted) return;
      final organizer = c.members.where((m) => m.organizer).firstOrNull;
      final others = c.members.where((m) => !m.organizer).toList();
      final index = <String, int>{if (organizer != null) organizer.id: 0};
      for (final (i, m) in others.indexed) {
        index[m.id] = i + 1;
      }
      setState(() {
        _draft = c;
        _name.text = c.name;
        _amount.text = c.installment.toDecimalString();
        _currency = c.installment.currency;
        _cadence = c.cadence;
        _interval = c.interval;
        _startDate = c.startDate ?? _today();
        _myShares = organizer?.shares ?? 1;
        _members
          ..clear()
          ..addAll([
            for (final m in others)
              _draftMember(
                name: m.name,
                shares: m.shares,
                contact: m.contactId == null ? null : Contact(id: m.contactId!, name: m.name, registered: m.linked),
              ),
          ]);
        _order = [for (final r in c.rounds) _Turn(_nextId++, index[r.recipientId] ?? 0)];
        _orderTouched = true;
        _imported = c.rounds.where((r) => r.legacy).length;
        _started = c.alreadyStarted || _imported > 0;
        _shuffled = c.randomOrder;
        _nextDue = _dueFrom(_startDate, _imported);
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
    } finally {
      if (mounted) setState(() => _loadingDraft = false);
    }
  }

  // ------------------------------------------------------------ order
  void _resetOrder() {
    _order = [
      for (var i = 0; i < _members.length; i++)
        for (var s = 0; s < _members[i].shares; s++) _Turn(_nextId++, i + 1),
      for (var s = 0; s < _myShares; s++) _Turn(_nextId++, 0),
    ];
    _orderTouched = false;
    _shuffled = false;
    if (_imported >= _totalShares) _imported = 0;
  }

  /// A fair draw, shown as a few smooth passes where the cards glide to their
  /// new places. Turns already received before Daira stay where they are.
  Future<void> _shuffle() async {
    if (_shuffling || _order.length - _imported < 2) return;
    final random = Random();
    final passes = context.reduceMotion ? 1 : 4;
    setState(() => _shuffling = true);
    // Let the cards appear in their places first, so the first pass glides too.
    await WidgetsBinding.instance.endOfFrame;
    for (var i = 0; i < passes; i++) {
      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _pass = i;
        final tail = _order.sublist(_imported)..shuffle(random);
        _order.replaceRange(_imported, _order.length, tail);
      });
      // Each pass lasts a little longer: fast at first, then it settles.
      await Future<void>.delayed(_shufflePass(i) + const Duration(milliseconds: 40));
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _shuffling = false;
      _shuffled = true;
      _orderTouched = true;
    });
  }

  Duration _shufflePass(int i) => context.reduceMotion ? Duration.zero : Duration(milliseconds: 300 + i * 90);
  int _pass = 0;

  /// How many turns were received before Daira: the first ones in the order.
  void _setImported(int value) => setState(() => _imported = value.clamp(0, _order.length - 1));

  /// Members or shares changed: the turn order must be rebuilt.
  void _membersChanged() => setState(_resetOrder);

  /// A member of the list being built.
  _MemberDraft _draftMember({String name = '', int shares = 1, Contact? contact}) =>
      _MemberDraft(_nextId++, name: name, shares: shares, contact: contact);

  /// The «add a member» field: type a name, or pick one of your contacts.
  final _newName = TextEditingController();
  final _newFocus = FocusNode();

  bool get _full => _members.length >= _limits.maxMembers;

  /// Contacts not yet in this circle, matching what is typed (recent first).
  List<Contact> _contactChoices(List<Contact> contacts) {
    final typed = _newName.text.trim().toLowerCase();
    final used = {for (final m in _members) if (m.contact != null) m.contact!.id};
    return [
      for (final c in contacts)
        if (!used.contains(c.id) && (typed.isEmpty || c.name.toLowerCase().contains(typed))) c,
    ].take(12).toList();
  }

  void _add({Contact? contact}) {
    final name = contact?.name ?? _newName.text.trim();
    if (name.isEmpty || _full) return;
    HapticFeedback.selectionClick();
    _members.add(_draftMember(name: name, contact: contact));
    _newName.clear();
    _membersChanged();
    // The keyboard stays open for the next name.
    if (contact == null) _newFocus.requestFocus();
  }

  void _remove(_MemberDraft m) {
    _members.remove(m);
    WidgetsBinding.instance.addPostFrameCallback((_) => m.dispose());
    _membersChanged();
  }

  /// One member: shares and name, in a sheet.
  Future<void> _editMember(_MemberDraft m) async {
    final t = context.l10n;
    final result = await showAppSheet<(String, int)>(
      context,
      builder: (_) => _MemberSheet(
        name: m.name.text,
        shares: m.shares,
        maxShares: _maxShares,
        installment: Money(_amountMinor ?? 0, currency: _currencyInfo.code, decimals: _currencyInfo.decimals),
        fromContacts: m.contact != null,
      ),
    );
    if (result == null || !mounted) return;
    final (name, shares) = result;
    setState(() {
      if (name.isNotEmpty && name != m.name.text) {
        m.name.text = name;
        m.contact = null; // a renamed person is no longer that contact
      }
      if (shares != m.shares) {
        m.shares = shares;
        _resetOrder();
      }
    });
    if (name.isEmpty) showToast(context, t.requiredField);
  }

  Future<void> _editMyShares() async {
    final shares = await showAppSheet<int>(
      context,
      builder: (_) => SharesSheet(
        name: _participantName(0),
        value: _myShares,
        max: _maxShares,
        installment: Money(_amountMinor ?? 0, currency: _currencyInfo.code, decimals: _currencyInfo.decimals),
      ),
    );
    if (shares == null || shares == _myShares || !mounted) return;
    _myShares = shares;
    _membersChanged();
  }

  // ------------------------------------------------------------ navigation
  bool _validateStep() {
    final t = context.l10n;
    switch (_step) {
      case 0:
        return _basicsForm.currentState?.validate() ?? false;
      case 1:
        // A name typed but not added yet counts too.
        if (_newName.text.trim().isNotEmpty) _add();
        if (_members.isEmpty) {
          showToast(context, t.addAtLeastOne, tone: Tone.danger);
          return false;
        }
        if (_totalShares < 2 || _totalShares > _limits.maxTotalShares) {
          showToast(context, t.sharesLimit(_limits.maxTotalShares), tone: Tone.danger);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _next() {
    if (!_validateStep()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      if (_step == 1 && _order.length != _totalShares) _resetOrder();
      _step = (_step + 1).clamp(0, _steps - 1);
      _error = null;
    });
  }

  void _back() {
    if (_step == 0) {
      _close();
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _close() async {
    final t = context.l10n;
    final dirty = _name.text.isNotEmpty || _amount.text.isNotEmpty || _members.any((m) => m.name.text.isNotEmpty);
    if (dirty && !_editing) {
      final ok = await confirmDialog(context, title: t.discardTitle, body: t.discardBody, confirm: t.discard, danger: true);
      if (!ok) return;
    }
    if (mounted) context.pop();
  }

  // ------------------------------------------------------------ save
  Json _plan({required bool activate}) => {
    'name': _name.text.trim(),
    'amount': Money(_amountMinor ?? 0, currency: _currencyInfo.code, decimals: _currencyInfo.decimals).toDecimalString(),
    'currency': _currencyInfo.code,
    'cadence': _cadence.name,
    'interval': _interval,
    'start_date': '${_start.year.toString().padLeft(4, '0')}-${_start.month.toString().padLeft(2, '0')}-${_start.day.toString().padLeft(2, '0')}',
    'organizer_shares': _myShares,
    'members': [
      for (final m in _members)
        {
          'name': m.name.text.trim(),
          'shares': m.shares,
          // A picked contact keeps the same person across circles (and their link).
          if (m.contact != null) 'contact_id': m.contact!.id,
        },
    ],
    if (_orderTouched && _features.turnOrder) 'order': [for (final turn in _order) turn.participant],
    if (_imported > 0) 'completed_rounds': _imported,
    if (_shuffled && _features.turnOrder) 'random_order': true,
    if (_started) 'already_started': true,
    'activate': activate,
  };

  Future<void> _save({required bool activate}) async {
    if (_busy) return;
    final t = context.l10n;
    if (activate) {
      final ok = await confirmDialog(context, title: t.startCircleTitle, body: t.startCircleBody, confirm: t.startCircle);
      if (!ok || !mounted) return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(circlesRepositoryProvider);
    try {
      Circle circle;
      final draft = _draft;
      if (draft != null) {
        circle = await repo.updateDraft(draft.id, {..._plan(activate: false), 'version': draft.version}, _commandId);
        _commandId = newCommandId();
        _draft = circle;
        if (activate) {
          circle = await repo.activate(circle.id, circle.version, _commandId);
          _commandId = newCommandId();
        }
      } else {
        circle = await repo.create(_plan(activate: activate), _commandId);
        _commandId = newCommandId();
      }
      refreshLists(ref.invalidate);
      ref.invalidate(circleProvider(circle.id));
      if (!mounted) return;
      ref.read(preferencesProvider).setString(_lastCurrencyKey, _currencyInfo.code);
      showToast(context, activate ? t.circleStarted : t.draftSaved, tone: Tone.success);
      // Editing returns to the draft's page (now refreshed); a new circle opens its page.
      if (_editing) {
        context.pop();
      } else {
        context.pushReplacement(Routes.circle(circle.id));
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        if (error.code == 'invalid_start_date' || error.field == 'name' || error.field == 'amount' || error.field == 'currency') {
          _step = 0;
        } else if (error.field == 'members') {
          _step = 1;
        } else if (error.field == 'order') {
          _step = 2;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _errorText(AppLocalizations t, Object error) {
    if (error is ApiException) {
      if (error.code == 'invalid_start_date') return t.startDatePast;
      if (error.code == 'feature_disabled') return t.featureDisabled;
      if (error.code == 'conflict') return t.draftChanged;
    }
    return t.error(error);
  }

  // ------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final titles = [t.stepBasics, t.stepMembers, t.stepOrder, t.stepReview];
    if (_loadingDraft) return Scaffold(appBar: AppBar(), body: const LoadingView());
    if (_loadError != null) {
      return Scaffold(appBar: AppBar(), body: LoadError(_loadError!, onRetry: _loadDraft));
    }
    final error = _error;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(AppIcons.close),
            onPressed: _close,
          ),
          title: Text(_editing ? t.editDraft : t.newCircle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(36),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.stepOf(_step + 1, _steps, titles[_step]), style: context.text.labelMedium),
                  const SizedBox(height: Space.xxs),
                  ProgressBar((_step + 1) / _steps),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.gutter, Space.sm, Space.gutter, 0),
                child: InlineBanner(title: _errorText(t, error), tone: Tone.danger),
              ),
            Expanded(
              child: switch (_step) {
                0 => _basics(context),
                1 => _membersStep(context),
                2 => _orderStep(context),
                _ => _review(context),
              },
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.sm, Space.gutter, Space.sm),
            child: _step < _steps - 1
                ? Row(
                    children: [
                      if (_step > 0) ...[
                        Expanded(child: AppButton.secondary(label: t.back, onPressed: _shuffling ? null : _back)),
                        const SizedBox(width: Space.sm),
                      ],
                      // Wait for the draw to finish before moving on.
                      Expanded(flex: 2, child: AppButton(label: t.next, onPressed: _shuffling ? null : _next)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(label: t.startCircle, loading: _busy, onPressed: () => _save(activate: true)),
                      const SizedBox(height: Space.xs),
                      AppButton.secondary(
                        label: t.saveDraft,
                        onPressed: _busy ? null : () => _save(activate: false),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ step 1
  Widget _basics(BuildContext context) {
    final t = context.l10n;
    final settings = ref.watch(settingsProvider);
    final currencies = settings?.currencies ?? const <Currency>[];
    final currency = _currencyInfo;
    return Form(
      key: _basicsForm,
      child: PageBody(
        children: [
          const SizedBox(height: Space.md),
          if (_features.importHistory) ...[
            _KindSelector(
              running: _started,
              onChanged: (running) => setState(() {
                _started = running;
                if (!running) _imported = 0;
              }),
            ),
            const SizedBox(height: Space.lg),
          ],
          AppTextField(
            controller: _name,
            label: t.circleName,
            hint: t.circleNameHint,
            icon: AppIcons.circles,
            maxLength: 100,
            textInputAction: TextInputAction.next,
            validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
          ),
          const SizedBox(height: Space.md),
          AppTextField(
            controller: _amount,
            label: t.installmentPerShare,
            icon: AppIcons.pay,
            keyboardType: TextInputType.numberWithOptions(decimal: currency.decimals > 0),
            textDirection: TextDirection.ltr,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹.,٫٬]'))],
            onChanged: (_) => setState(() {}),
            validator: (v) => Money.parseMinor(v ?? '', currency.decimals) == null ? t.amountInvalid : null,
          ),
          // The currency is picked for the person (last used, else their country);
          // changing it is rare, so it is one quiet line, not a field.
          _CurrencyLine(
            currency: currency,
            onChange: currencies.length < 2 || (_draft != null && _draft!.status != CircleStatus.draft)
                ? null
                : () async {
                    final picked = await showAppSheet<String>(
                      context,
                      builder: (_) => _CurrencySheet(currencies: currencies, selected: currency.code),
                    );
                    if (picked != null && mounted) setState(() => _currency = picked);
                  },
          ),
          SectionHeader(t.cadence),
          SegmentedButton<Cadence>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: Cadence.day, label: Text(t.cadenceDays)),
              ButtonSegment(value: Cadence.week, label: Text(t.cadenceWeeks)),
              ButtonSegment(value: Cadence.month, label: Text(t.cadenceMonths)),
            ],
            selected: {_cadence},
            onSelectionChanged: (s) => setState(() => _cadence = s.first),
          ),
          const SizedBox(height: Space.sm),
          _Stepper(
            label: cadenceLabel(t, _cadence, _interval),
            value: _interval,
            min: 1,
            max: 365,
            onChanged: (v) => setState(() => _interval = v),
          ),
          SectionHeader(_started ? t.currentDueDate : t.firstDueDate),
          DatePickerCard(
            value: _started ? _nextDue : _startDate,
            // A running circle's current installment may already be due.
            allowPast: _started,
            onChanged: (d) => setState(() {
              if (_started) {
                _nextDue = d;
              } else {
                _startDate = d;
              }
            }),
          ),
          const SizedBox(height: Space.xs),
          Text(_started ? t.nextDueHint : t.firstDueDateHint, style: context.text.bodySmall),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ step 2
  Widget _membersStep(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final contacts = ref.watch(contactsProvider).valueOrNull ?? const <Contact>[];
    final choices = _contactChoices(contacts);
    return PageBody(
      children: [
        const SizedBox(height: Space.md),
        Text(t.membersStepBody, style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
        const SizedBox(height: Space.md),
        // Add: type a name and press the button (or «next» on the keyboard)…
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _newName,
                focusNode: _newFocus,
                label: t.addMemberField,
                icon: AppIcons.invite,
                maxLength: 100,
                enabled: !_full,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                // Keeps the keyboard open between names.
                onEditingComplete: _add,
              ),
            ),
            const SizedBox(width: Space.xs),
            SizedBox(
              height: Sizes.input,
              width: Sizes.input,
              child: IconButton.filled(
                tooltip: t.addMember,
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                ),
                onPressed: _newName.text.trim().isEmpty || _full ? null : _add,
                icon: const Icon(AppIcons.add),
              ),
            ),
          ],
        ),
        // …or by phone number: someone on Daira is asked to join, others invited on WhatsApp.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton.text(
            label: t.addByPhone,
            icon: AppIcons.devices,
            onPressed: _full
                ? null
                : () async {
                    final contact = await showAddByPhoneSheet(context);
                    if (contact != null && mounted) _add(contact: contact);
                  },
          ),
        ),
        // …or tap one of your contacts.
        if (choices.isNotEmpty) ...[
          const SizedBox(height: Space.sm),
          Text(t.fromYourContacts, style: context.text.labelMedium?.copyWith(color: colors.textMuted)),
          const SizedBox(height: Space.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in choices) ...[
                  _ContactChip(contact: c, onTap: _full ? null : () => _add(contact: c)),
                  const SizedBox(width: Space.xs),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: Space.lg),
        Row(
          children: [
            Expanded(child: Text(t.membersCount(_members.length + 1), style: context.text.titleSmall)),
            if (_maxShares > 1) Text(t.tapToSetShares, style: context.text.bodySmall),
          ],
        ),
        const SizedBox(height: Space.xs),
        FeedGroup(
          children: [
            _MemberRow(
              name: _participantName(0),
              shares: _myShares,
              me: true,
              onTap: _maxShares > 1 ? _editMyShares : null,
            ),
            for (final m in _members)
              _MemberRow(
                key: ValueKey(m.id),
                name: m.name.text,
                shares: m.shares,
                contact: m.contact,
                onTap: () => _editMember(m),
                onRemove: () => _remove(m),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        InlineBanner(
          title: t.totalShares(_totalShares),
          body: t.payoutPerRound(
            Money((_amountMinor ?? 0) * _totalShares, currency: _currencyInfo.code, decimals: _currencyInfo.decimals)
                .format(context.localeName),
          ),
          icon: AppIcons.info,
        ),
      ],
    );
  }

  // ------------------------------------------------------------ step 3
  static const _slot = 68.0; // card 60 + gap 8
  static const _rail = 30.0 + Space.sm; // number badge + gap

  Widget _orderStep(BuildContext context) {
    final t = context.l10n;
    final canReorder = _features.turnOrder;
    final colors = context.colors;
    const padding = EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.md, Space.gutter, Space.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_started) ...[
                CurrentRoundPicker(
                  names: [for (final turn in _order) _participantName(turn.participant)],
                  current: _imported + 1,
                  enabled: !_shuffling,
                  onChanged: (round) => _setImported(round - 1),
                ),
                const SizedBox(height: Space.sm),
              ],
              Text(
                !canReorder ? t.orderFixedBody : (_started ? t.orderStepHintRunning : t.orderStepHint),
                style: context.text.bodySmall?.copyWith(color: colors.textMuted),
              ),
              if (canReorder) ...[
                const SizedBox(height: Space.sm),
                Wrap(
                  spacing: Space.xs,
                  runSpacing: Space.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ShuffleButton(running: _shuffling, onPressed: _order.length - _imported < 2 ? null : _shuffle),
                    if (_shuffled && !_shuffling)
                      StatusChip(t.randomOrderChip, tone: Tone.success, icon: AppIcons.check)
                    else if (_orderTouched && !_editing && !_shuffling)
                      AppButton.text(label: t.resetOrder, icon: AppIcons.undo, onPressed: () => setState(_resetOrder)),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _shuffling
              // While drawing: the round numbers stay, the people glide between them.
              ? SingleChildScrollView(
                  padding: padding,
                  child: SizedBox(
                    height: _order.length * _slot,
                    child: Stack(
                      children: [
                        for (var i = 0; i < _order.length; i++)
                          PositionedDirectional(
                            top: i * _slot,
                            start: 0,
                            width: 30,
                            height: 60,
                            child: Center(child: _TurnBadge(number: i + 1, received: i < _imported, current: _started && i == _imported)),
                          ),
                        for (final (i, turn) in _order.indexed)
                          AnimatedPositionedDirectional(
                            key: ValueKey(turn.id),
                            duration: _shufflePass(_pass),
                            curve: Curves.easeInOutCubic,
                            top: i * _slot,
                            start: _rail,
                            end: 0,
                            height: 60,
                            child: _turnCard(context, turn, i, moving: true),
                          ),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: padding,
                  buildDefaultDragHandles: false,
                  itemCount: _order.length,
                  proxyDecorator: (child, _, animation) => AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Material(
                      color: Colors.transparent,
                      elevation: 6 * Curves.easeOut.transform(animation.value),
                      shadowColor: colors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(Radii.lg),
                      child: child,
                    ),
                    child: child,
                  ),
                  onReorderStart: (_) => HapticFeedback.mediumImpact(),
                  onReorderItem: (from, to) {
                    if (!canReorder) return;
                    setState(() {
                      _order.insert(to, _order.removeAt(from));
                      _orderTouched = true;
                      _shuffled = false;
                    });
                  },
                  itemBuilder: (context, i) {
                    final turn = _order[i];
                    final row = SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          _TurnBadge(number: i + 1, received: i < _imported, current: _started && i == _imported),
                          const SizedBox(width: Space.sm),
                          Expanded(child: _turnCard(context, turn, i, handle: canReorder)),
                        ],
                      ),
                    );
                    // Long-press anywhere on the card to drag it; the handle drags at once.
                    return Padding(
                      key: ValueKey(turn.id),
                      padding: const EdgeInsets.only(bottom: _slot - 60),
                      child: canReorder ? ReorderableDelayedDragStartListener(index: i, child: row) : row,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _turnCard(BuildContext context, _Turn turn, int i, {bool handle = false, bool moving = false}) {
    final t = context.l10n;
    final colors = context.colors;
    final done = i < _imported;
    final me = turn.participant == 0;
    return Container(
      decoration: BoxDecoration(
        color: done && !moving ? colors.surfaceSunken : colors.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.line),
      ),
      padding: EdgeInsetsDirectional.only(start: Space.sm, end: handle ? Space.xxs : Space.sm),
      child: Row(
        children: [
          InitialsAvatar(me ? ref.read(sessionProvider)?.profile.name ?? '' : _participantName(turn.participant), size: 32, highlight: me),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_participantName(turn.participant), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                // The date belongs to the place, not the person: hidden while people move.
                if (!moving) Text(t.date(_dueDate(i)), style: context.text.bodySmall),
              ],
            ),
          ),
          if (done && !moving) ...[
            const SizedBox(width: Space.xs),
            StatusChip(t.receivedLabel, tone: Tone.success, icon: AppIcons.received),
          ] else if (_started && i == _imported && !moving) ...[
            const SizedBox(width: Space.xs),
            StatusChip(t.currentRoundTag, tone: Tone.info, icon: AppIcons.dueDate),
          ],
          if (handle)
            ReorderableDragStartListener(
              index: i,
              child: SizedBox(
                width: 40,
                height: 44,
                child: Icon(AppIcons.reorder, size: 20, color: colors.textMuted, semanticLabel: t.dragToReorder),
              ),
            ),
        ],
      ),
    );
  }

  DateTime _dueDate(int index) => _dueFrom(_start, index);

  /// Same rule as the server: months keep the start day (capped at month end).
  /// [index] may be negative (dates before [base]).
  DateTime _dueFrom(DateTime base, int index) {
    switch (_cadence) {
      case Cadence.day:
        return base.add(Duration(days: index * _interval));
      case Cadence.week:
        return base.add(Duration(days: index * _interval * 7));
      case Cadence.month:
        final total = base.year * 12 + base.month - 1 + index * _interval;
        final year = total ~/ 12;
        final month = total % 12 + 1;
        final last = DateTime(year, month + 1, 0).day;
        return DateTime(year, month, base.day > last ? last : base.day);
    }
  }

  // ------------------------------------------------------------ step 4
  Widget _review(BuildContext context) {
    final t = context.l10n;
    final currency = _currencyInfo;
    final perShare = Money(_amountMinor ?? 0, currency: currency.code, decimals: currency.decimals);
    final payout = perShare.times(_totalShares);
    final rows = <(String, String)>[
      (t.installmentPerShare, perShare.format(context.localeName)),
      (t.cadence, cadenceLabel(t, _cadence, _interval)),
      (t.membersLabel, '${_members.length + 1}'),
      (t.roundsLabel, '$_totalShares'),
      (t.firstDueDate, t.date(_start)),
      (t.lastDueDate, t.date(_dueDate(_totalShares - 1))),
      if (_started) (t.currentRoundTag, t.roundOf(_imported + 1, _totalShares)),
      if (_features.turnOrder) (t.turnOrder, _shuffled ? t.orderRandom : t.orderArranged),
    ];
    return PageBody(
      children: [
        const SizedBox(height: Space.md),
        HeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_name.text.trim(), style: context.text.titleLarge?.copyWith(color: context.colors.onHero)),
              const SizedBox(height: Space.xs),
              Text(t.eachRoundCollects, style: context.text.bodySmall?.copyWith(color: context.colors.onHeroMuted)),
              AmountText(payout, large: true, color: context.colors.onHero),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        AppCard(
          child: Column(
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.xs),
                  child: Row(
                    children: [
                      Expanded(child: Text(label, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted))),
                      Text(value, style: context.text.titleSmall),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        InlineBanner(title: t.reviewNoteTitle, body: t.reviewNoteBody, icon: AppIcons.info),
      ],
    );
  }
}

/// − value + control for counts (interval, imported rounds).
class _Stepper extends StatelessWidget {
  const _Stepper({required this.label, required this.value, required this.min, required this.max, required this.onChanged});
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xxs),
    child: Row(
      children: [
        Expanded(child: Text(label, style: context.text.bodyLarge)),
        _SharesControl(value: value, min: min, max: max, onChanged: onChanged),
      ],
    ),
  );
}

class _SharesControl extends StatelessWidget {
  const _SharesControl({required this.value, required this.max, required this.onChanged, this.min = 1});
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: t.decrease,
          visualDensity: VisualDensity.compact,
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(AppIcons.remove, size: 18),
        ),
        SizedBox(
          width: 28,
          child: Text('$value', textAlign: TextAlign.center, style: context.text.titleSmall),
        ),
        IconButton(
          tooltip: t.increase,
          visualDensity: VisualDensity.compact,
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(AppIcons.add, size: 18),
        ),
      ],
    );
  }
}

/// Round number on the rail at the start of each turn; a green check once received.
class _TurnBadge extends StatelessWidget {
  const _TurnBadge({required this.number, required this.received, this.current = false});
  final int number;
  final bool received;

  /// The round a running circle is at now (amber).
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: context.reduceMotion ? Duration.zero : Motion.standard,
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: received ? colors.success : (current ? colors.accent : colors.primaryContainer),
        shape: BoxShape.circle,
      ),
      child: received
          ? Icon(AppIcons.check, size: 16, color: colors.surface)
          : Text(
              '$number',
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: DairaType.numeric.fontFeatures,
                color: current ? colors.onAccent : colors.onPrimaryContainer,
              ),
            ),
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  const _ShuffleButton({required this.running, required this.onPressed});
  final bool running;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppButton.secondary(
      label: running ? t.shufflingNow : t.shuffleOrder,
      icon: AppIcons.shuffle,
      expand: false,
      onPressed: running ? null : onPressed,
    );
  }
}

/// First question of the wizard: a new circle, or one that is already running.
class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.running, required this.onChanged});
  final bool running;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.circleKindTitle, style: context.text.titleMedium),
        const SizedBox(height: Space.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _KindCard(
                  icon: AppIcons.add,
                  title: t.kindNew,
                  body: t.kindNewHint,
                  selected: !running,
                  onTap: () => onChanged(false),
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: _KindCard(
                  icon: AppIcons.turn,
                  title: t.kindRunning,
                  body: t.kindRunningHint,
                  selected: running,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KindCard extends StatelessWidget {
  const _KindCard({required this.icon, required this.title, required this.body, required this.selected, required this.onTap});
  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.reduceMotion ? Duration.zero : Motion.standard;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: selected
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          child: AnimatedContainer(
            duration: duration,
            curve: Motion.easing,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: selected ? colors.primaryContainer.withValues(alpha: 0.6) : colors.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: selected ? colors.primary : colors.line, width: selected ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: duration,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: selected ? colors.primary : colors.surfaceSunken, shape: BoxShape.circle),
                      child: Icon(icon, size: 18, color: selected ? colors.onPrimary : colors.textMuted),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: duration,
                      child: Icon(AppIcons.success, size: 20, color: colors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: Space.sm),
                Text(title, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: context.text.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One person in the list: name, shares and where they come from. Tap to
/// change their shares or name; the bin removes them.
class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.name, required this.shares, this.contact, this.me = false, this.onTap, this.onRemove, super.key});
  final String name;
  final int shares;
  final Contact? contact;
  final bool me;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final sub = [
      if (me) t.organizer,
      if (contact != null) contact!.registered ? t.registered : t.fromContacts,
      t.sharesCount(shares),
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(Space.md, Space.sm, onRemove == null ? Space.md : Space.xxs, Space.sm),
        child: Row(
          children: [
            InitialsAvatar(name, size: 40, highlight: me),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MemberName(name, shares: shares),
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: t.removeMember,
                onPressed: onRemove,
                icon: Icon(AppIcons.delete, size: 20, color: colors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

/// A contact to add with one tap.
class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.contact, required this.onTap});
  final Contact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ActionChip(
      onPressed: onTap,
      avatar: contact.registered ? Icon(AppIcons.link, size: 16, color: colors.success) : Icon(AppIcons.add, size: 16, color: colors.primary),
      label: Text(contact.name),
    );
  }
}

/// A member's name and shares, edited together.
class _MemberSheet extends StatefulWidget {
  const _MemberSheet({
    required this.name,
    required this.shares,
    required this.maxShares,
    required this.installment,
    required this.fromContacts,
  });
  final String name;
  final int shares;
  final int maxShares;
  final Money installment;
  final bool fromContacts;

  @override
  State<_MemberSheet> createState() => _MemberSheetState();
}

class _MemberSheetState extends State<_MemberSheet> {
  late final _name = TextEditingController(text: widget.name);
  late int _shares = widget.shares;
  bool _editingName = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name: shown as text; the pencil makes it editable.
        if (_editingName)
          AppTextField(controller: _name, label: t.name, icon: AppIcons.user, maxLength: 100, autofocus: true)
        else
          Row(
            children: [
              InitialsAvatar(_name.text, size: 44),
              const SizedBox(width: Space.sm),
              Expanded(child: Text(_name.text, style: context.text.titleLarge)),
              IconButton(
                tooltip: t.renameContact,
                icon: Icon(AppIcons.edit, size: 20, color: colors.primary),
                onPressed: () => setState(() => _editingName = true),
              ),
            ],
          ),
        if (widget.fromContacts && _editingName) ...[
          const SizedBox(height: Space.xxs),
          Text(t.renameLeavesContact, style: context.text.bodySmall),
        ],
        if (widget.maxShares > 1) ...[
          const SizedBox(height: Space.lg),
          Text(t.sharesTitle, style: context.text.labelLarge),
          const SizedBox(height: Space.xxs),
          Text(t.sharesExplain, style: context.text.bodySmall),
          const SizedBox(height: Space.md),
          SharesChoice(value: _shares, max: widget.maxShares, onChanged: (v) => setState(() => _shares = v)),
          const SizedBox(height: Space.sm),
          Text(
            t.sharesMeaning(_shares, widget.installment.times(_shares).format(t.localeName)),
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
        ],
        const SizedBox(height: Space.lg),
        AppButton(label: t.done, onPressed: () => Navigator.pop(context, (_name.text.trim(), _shares))),
      ],
    );
  }
}

class _CurrencyLine extends StatelessWidget {
  const _CurrencyLine({required this.currency, required this.onChange});
  final Currency currency;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final label = currency.symbol.isEmpty || currency.symbol == currency.code
        ? currency.code
        : '${currency.code} (${currency.symbol})';
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Space.xs, top: Space.xxs),
      child: Row(
        children: [
          Flexible(
            child: Text(
              t.currencyLine(label),
              style: context.text.bodySmall?.copyWith(color: context.colors.textMuted),
            ),
          ),
          if (onChange != null) AppButton.text(label: t.change, onPressed: onChange),
        ],
      ),
    );
  }
}

class _CurrencySheet extends StatelessWidget {
  const _CurrencySheet({required this.currencies, required this.selected});
  final List<Currency> currencies;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.currency, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.currencyRare, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: Space.sm),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final c in currencies)
                ListTile(
                  title: Text(c.code, textDirection: TextDirection.ltr),
                  subtitle: c.symbol.isEmpty ? null : Text(c.symbol, textDirection: TextDirection.ltr),
                  trailing: c.code == selected ? Icon(AppIcons.check, color: context.colors.primary) : null,
                  onTap: () => Navigator.pop(context, c.code),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
