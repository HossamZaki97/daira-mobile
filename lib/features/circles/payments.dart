import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/circle.dart';
import '../../core/models/money.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../state.dart';

/// Runs a circle command: shows the error, or a short confirmation.
Future<bool> runCircleAction(BuildContext context, Future<void> Function() action, {String? done}) async {
  try {
    await action();
    if (context.mounted && done != null) showToast(context, done, tone: Tone.success);
    return true;
  } catch (error) {
    if (context.mounted) showError(context, error);
    return false;
  }
}

String methodLabel(AppLocalizations t, PaymentMethod method) => switch (method) {
  PaymentMethod.cash => t.methodCash,
  PaymentMethod.transfer => t.methodTransfer,
  PaymentMethod.wallet => t.methodWallet,
};

IconData methodIcon(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => AppIcons.cash,
  PaymentMethod.transfer => AppIcons.bank,
  PaymentMethod.wallet => AppIcons.receive,
};

/// Organizer: the installments of one round, who still owes first.
/// Record one payment, several at once, confirm reported ones, remind, or undo.
class RoundPayments extends ConsumerStatefulWidget {
  const RoundPayments({required this.circle, required this.round, super.key});
  final Circle circle;
  final Round round;

  @override
  ConsumerState<RoundPayments> createState() => _RoundPaymentsState();
}

class _RoundPaymentsState extends ConsumerState<RoundPayments> {
  final _busy = <String>{};
  final _selected = <String>{};
  bool _selecting = false;
  bool _showPaid = false;

  CircleController get _controller => ref.read(circleProvider(widget.circle.id).notifier);

  Future<void> _run(String id, Future<void> Function() action, {String? done}) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    await runCircleAction(context, action, done: done);
    if (mounted) setState(() => _busy.remove(id));
  }

  bool get _open => widget.round.state == RoundState.collecting || widget.round.state == RoundState.readyForPayout;

  Future<void> _record(List<Obligation> items) async {
    final t = context.l10n;
    final total = items.fold<Money>(items.first.amount.times(0), (sum, o) => sum + o.amount);
    final result = await showAppSheet<RecordChoice>(
      context,
      builder: (_) => RecordSheet(
        title: items.length == 1 ? t.recordTitle(items.first.member) : t.recordSelected(items.length),
        amount: total,
      ),
    );
    if (result == null || !mounted) return;
    await _run(
      'record',
      () => _controller.recordPayments(items, method: result.method, note: result.note),
      done: t.recordedDone,
    );
    if (mounted) setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<void> _approve(Obligation o) =>
      _run('approve:${o.id}', () => _controller.approve(o), done: context.l10n.approvedDone(o.member));

  Future<void> _reject(Obligation o) async {
    final reason = await showAppSheet<String>(context, builder: (_) => RejectSheet(member: o.member));
    if (reason == null || !mounted) return;
    await _run('reject:${o.id}', () => _controller.reject(o, reason), done: context.l10n.rejectedDone);
  }

  Future<void> _details(Obligation o) => showAppSheet<void>(
    context,
    builder: (_) => PaymentDetailsSheet(circleId: widget.circle.id, obligation: o, canUndo: _open),
  );

  Future<void> _remind(ReminderInfo info) async {
    final t = context.l10n;
    final ok = await confirmDialog(
      context,
      title: t.remindTitle,
      body: t.remindBody(info.limit - info.sent),
      confirm: t.remindAction,
    );
    if (ok) await _run('remind', () => _controller.remind(), done: t.remindDone);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final c = widget.circle;
    final round = widget.round;
    final all = round.obligations;
    final paid = [for (final o in all) if (o.state == ObligationState.approved) o];
    // Reported payments need an answer, so they come first.
    final unpaid = [
      for (final o in all) if (o.state == ObligationState.reported) o,
      for (final o in all) if (o.state == ObligationState.pending) o,
    ];
    final pending = [for (final o in unpaid) if (o.state == ObligationState.pending) o];
    final collecting = round.state == RoundState.collecting;
    final reminders = c.reminders;
    final remindable = pending.where((o) => (c.member(o.memberId)?.linked ?? false) && o.memberId != c.actorMemberId).length;
    final showPaid = _showPaid || unpaid.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          t.paymentsThisRound,
          trailing: StatusChip(
            t.paidOf(paid.length, all.length),
            tone: paid.length == all.length ? Tone.success : Tone.pending,
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, o) in unpaid.indexed) ...[
                if (i > 0) const Divider(indent: Space.md, endIndent: Space.md),
                _UnpaidRow(
                  obligation: o,
                  isMe: o.memberId == c.actorMemberId,
                  selecting: _selecting,
                  selected: _selected.contains(o.id),
                  busy: _busy,
                  onToggle: () => setState(() => _selected.contains(o.id) ? _selected.remove(o.id) : _selected.add(o.id)),
                  onRecord: () => _record([o]),
                  onApprove: () => _approve(o),
                  onReject: () => _reject(o),
                ),
              ],
              if (paid.isNotEmpty) ...[
                if (unpaid.isNotEmpty) ...[
                  const Divider(height: 1),
                  InkWell(
                    onTap: () => setState(() => _showPaid = !_showPaid),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                      child: Row(
                        children: [
                          Icon(AppIcons.success, size: 18, color: context.colors.success),
                          const SizedBox(width: Space.xs),
                          Expanded(child: Text(t.paidGroup(paid.length), style: context.text.labelLarge)),
                          AnimatedRotation(
                            turns: _showPaid ? 0.5 : 0,
                            duration: Motion.fast,
                            child: Icon(AppIcons.expand, size: 18, color: context.colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (showPaid)
                  for (final (i, o) in paid.indexed) ...[
                    if (i > 0 || unpaid.isNotEmpty) const Divider(indent: Space.md, endIndent: Space.md),
                    _PaidRow(obligation: o, isMe: o.memberId == c.actorMemberId, onTap: () => _details(o)),
                  ],
              ],
            ],
          ),
        ),
        if (collecting && pending.isNotEmpty) ...[
          const SizedBox(height: Space.sm),
          if (_selecting)
            ButtonPair(
              first: AppButton(
                label: t.recordSelected(_selected.length),
                icon: AppIcons.check,
                loading: _busy.contains('record'),
                onPressed: _selected.isEmpty ? null : () => _record([for (final o in pending) if (_selected.contains(o.id)) o]),
              ),
              second: AppButton.secondary(
                label: t.cancel,
                onPressed: () => setState(() {
                  _selecting = false;
                  _selected.clear();
                }),
              ),
            )
          else if (pending.length > 1)
            AppButton.text(
              label: t.recordSeveral,
              icon: AppIcons.tasks,
              onPressed: () => setState(() => _selecting = true),
            ),
        ],
        if (collecting && reminders != null && remindable > 0 && !_selecting) ...[
          const SizedBox(height: Space.xs),
          AppButton.secondary(
            label: t.remindUnpaid,
            icon: AppIcons.remind,
            loading: _busy.contains('remind'),
            onPressed: reminders.available ? () => _remind(reminders) : null,
          ),
          if (!reminders.available)
            Padding(
              padding: const EdgeInsets.only(top: Space.xxs),
              child: Text(
                reminders.nextAt != null
                    ? t.remindNextAt(DateFormat.MMMd(t.localeName).add_jm().format(reminders.nextAt!.toLocal()))
                    : t.remindLimitReached,
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
            ),
        ],
      ],
    );
  }
}

class _UnpaidRow extends StatelessWidget {
  const _UnpaidRow({
    required this.obligation,
    required this.isMe,
    required this.selecting,
    required this.selected,
    required this.busy,
    required this.onToggle,
    required this.onRecord,
    required this.onApprove,
    required this.onReject,
  });

  final Obligation obligation;
  final bool isMe;
  final bool selecting;
  final bool selected;
  final Set<String> busy;
  final VoidCallback onToggle;
  final VoidCallback onRecord;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final o = obligation;
    final pending = o.state == ObligationState.pending;
    final selectable = selecting && pending;
    return InkWell(
      onTap: selectable ? onToggle : null,
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (selectable) ...[
                  Icon(selected ? AppIcons.checkboxOn : AppIcons.checkbox, color: selected ? colors.primary : colors.textMuted),
                  const SizedBox(width: Space.sm),
                ],
                InitialsAvatar(o.member, highlight: isMe),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMe ? t.youName(o.member) : o.member, style: context.text.titleSmall),
                      AmountText(o.amount),
                      const SizedBox(height: Space.xxs),
                      ObligationChip(o.state, overdue: o.overdue),
                    ],
                  ),
                ),
                if (pending && !selecting)
                  AppButton.secondary(
                    label: t.recordPayment,
                    expand: false,
                    loading: busy.contains('record'),
                    onPressed: onRecord,
                  ),
              ],
            ),
            if (o.state == ObligationState.reported) ...[
              if (o.reportedAt != null) ...[
                const SizedBox(height: Space.xs),
                Text(t.reportedAt(relativeTime(t, o.reportedAt!)), style: context.text.bodySmall),
              ],
              const SizedBox(height: Space.sm),
              ButtonPair(
                first: AppButton(
                  label: t.actionReceived,
                  icon: AppIcons.check,
                  loading: busy.contains('approve:${o.id}'),
                  onPressed: busy.contains('reject:${o.id}') ? null : onApprove,
                ),
                second: AppButton(
                  kind: ButtonKind.danger,
                  label: t.actionNotReceived,
                  loading: busy.contains('reject:${o.id}'),
                  onPressed: busy.contains('approve:${o.id}') ? null : onReject,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaidRow extends StatelessWidget {
  const _PaidRow({required this.obligation, required this.isMe, required this.onTap});
  final Obligation obligation;
  final bool isMe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final o = obligation;
    final method = o.method;
    return InkWell(
      onTap: o.historical ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        child: Row(
          children: [
            InitialsAvatar(o.member, size: 32, highlight: isMe),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isMe ? t.youName(o.member) : o.member, style: context.text.titleSmall),
                  if (o.recordedByOrganizer) Text(t.recordedByOrganizer, style: context.text.bodySmall),
                ],
              ),
            ),
            if (method != null) ...[
              Icon(methodIcon(method), size: 18, color: context.colors.textMuted, semanticLabel: methodLabel(t, method)),
              const SizedBox(width: Space.xs),
            ],
            AmountText(o.amount),
          ],
        ),
      ),
    );
  }
}

/// What the organizer chose when recording a payment.
class RecordChoice {
  const RecordChoice({this.method, this.note});
  final PaymentMethod? method;
  final String? note;
}

class RecordSheet extends StatefulWidget {
  const RecordSheet({required this.title, required this.amount, super.key});
  final String title;
  final Money amount;

  @override
  State<RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<RecordSheet> {
  final _note = TextEditingController();
  PaymentMethod? _method;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.recordBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: Space.md),
        AmountText(widget.amount, large: true),
        const SizedBox(height: Space.lg),
        Text(t.paymentMethodOptional, style: context.text.labelLarge),
        const SizedBox(height: Space.xs),
        Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: [
            for (final m in PaymentMethod.values)
              ChoiceChip(
                avatar: Icon(methodIcon(m), size: 18),
                label: Text(methodLabel(t, m)),
                selected: _method == m,
                showCheckmark: false,
                onSelected: (on) => setState(() => _method = on ? m : null),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        AppTextField(controller: _note, label: t.noteOptional, icon: AppIcons.note, maxLength: 200),
        const SizedBox(height: Space.lg),
        AppButton(
          label: t.recordPayment,
          icon: AppIcons.check,
          onPressed: () => Navigator.pop(context, RecordChoice(method: _method, note: _note.text.trim())),
        ),
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

/// A confirmed installment: who, how, when — and undo while the round is open.
class PaymentDetailsSheet extends ConsumerStatefulWidget {
  const PaymentDetailsSheet({required this.circleId, required this.obligation, required this.canUndo, super.key});
  final String circleId;
  final Obligation obligation;
  final bool canUndo;

  @override
  ConsumerState<PaymentDetailsSheet> createState() => _PaymentDetailsSheetState();
}

class _PaymentDetailsSheetState extends ConsumerState<PaymentDetailsSheet> {
  bool _busy = false;

  Future<void> _undo() async {
    final t = context.l10n;
    final o = widget.obligation;
    final ok = await confirmDialog(
      context,
      title: t.undoPaymentTitle(o.member),
      body: t.undoPaymentBody,
      confirm: t.undoPayment,
      danger: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final done = await runCircleAction(
      context,
      () => ref.read(circleProvider(widget.circleId).notifier).undoPayment(o),
      done: t.undoneDone,
    );
    if (!mounted) return;
    if (done) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final o = widget.obligation;
    final method = o.method;
    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.textMuted),
          const SizedBox(width: Space.sm),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.paymentDetails, style: context.text.titleLarge),
        const SizedBox(height: Space.md),
        Row(
          children: [
            InitialsAvatar(o.member),
            const SizedBox(width: Space.sm),
            Expanded(child: Text(o.member, style: context.text.titleMedium)),
            AmountText(o.amount, large: true),
          ],
        ),
        const SizedBox(height: Space.md),
        line(AppIcons.confirmed, o.recordedByOrganizer ? t.recordedByOrganizer : t.reportedAndConfirmed),
        if (o.approvedAt != null) line(AppIcons.clock, t.confirmedAt(relativeTime(t, o.approvedAt!))),
        if (method != null) line(methodIcon(method), methodLabel(t, method)),
        if (o.note != null) line(AppIcons.note, o.note!),
        if (widget.canUndo) ...[
          const SizedBox(height: Space.sm),
          AppButton(
            kind: ButtonKind.danger,
            label: t.undoPayment,
            icon: AppIcons.undo,
            loading: _busy,
            onPressed: _undo,
          ),
        ],
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.close, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

/// Asks the organizer why the payment did not arrive (required, shown to the member).
class RejectSheet extends StatefulWidget {
  const RejectSheet({required this.member, super.key});
  final String member;

  @override
  State<RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<RejectSheet> {
  final _reason = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.rejectTitle(widget.member), style: context.text.titleLarge),
          const SizedBox(height: Space.xs),
          Text(t.rejectBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
          const SizedBox(height: Space.lg),
          AppTextField(
            controller: _reason,
            label: t.reason,
            hint: t.reasonHint,
            maxLength: 200,
            autofocus: true,
            validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
          ),
          const SizedBox(height: Space.lg),
          AppButton(
            kind: ButtonKind.danger,
            label: t.actionNotReceived,
            onPressed: () {
              if (_form.currentState?.validate() ?? false) Navigator.pop(context, _reason.text.trim());
            },
          ),
          const SizedBox(height: Space.xs),
          AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

/// Organizer: automatic reminders for this circle, among fixed choices.
class ReminderSettingsSheet extends ConsumerStatefulWidget {
  const ReminderSettingsSheet({required this.circle, super.key});
  final Circle circle;

  @override
  ConsumerState<ReminderSettingsSheet> createState() => _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends ConsumerState<ReminderSettingsSheet> {
  late int _before = widget.circle.reminders?.before ?? 2;
  late bool _onDue = widget.circle.reminders?.onDue ?? false;
  late bool _overdue = widget.circle.reminders?.overdue ?? true;
  bool _busy = false;

  Future<void> _save() async {
    final t = context.l10n;
    setState(() => _busy = true);
    final done = await runCircleAction(
      context,
      () => ref
          .read(circleProvider(widget.circle.id).notifier)
          .reminderSettings(before: _before, onDue: _onDue, overdue: _overdue),
      done: t.reminderSaved,
    );
    if (!mounted) return;
    if (done) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.reminderSettings, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.reminderSettingsBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: Space.lg),
        Text(t.remindBefore, style: context.text.labelLarge),
        const SizedBox(height: Space.xs),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 0, label: Text(t.remindOff)),
            for (final d in const [1, 2, 3]) ButtonSegment(value: d, label: Text(t.remindDays(d))),
          ],
          selected: {_before},
          onSelectionChanged: (v) => setState(() => _before = v.first),
        ),
        const SizedBox(height: Space.md),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.remindOnDue),
          value: _onDue,
          onChanged: (v) => setState(() => _onDue = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.remindOverdue),
          value: _overdue,
          onChanged: (v) => setState(() => _overdue = v),
        ),
        const SizedBox(height: Space.md),
        AppButton(label: t.save, loading: _busy, onPressed: _save),
      ],
    );
  }
}
