import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/circle.dart';
import '../../core/models/money.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../auth/phone_widgets.dart';
import '../common.dart';
import '../state.dart';
import '../whatsapp.dart';

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

/// The installments of one round, who still owes first.
///
/// Organizer: tap unpaid members to select them (the screen shows the record
/// bar), answer reported payments, remind, open a paid one to see or undo it.
/// Members: the same list, read only.
class RoundPayments extends ConsumerStatefulWidget {
  const RoundPayments({
    required this.circle,
    required this.round,
    required this.selected,
    required this.onToggle,
    required this.onSelectAll,
    super.key,
  });
  final Circle circle;
  final Round round;
  final Set<String> selected;
  final ValueChanged<Obligation> onToggle;

  /// true: select every unpaid installment; false: clear.
  final ValueChanged<bool> onSelectAll;

  @override
  ConsumerState<RoundPayments> createState() => _RoundPaymentsState();
}

class _RoundPaymentsState extends ConsumerState<RoundPayments> {
  final _busy = <String>{};
  bool _showPaid = false;

  CircleController get _controller => ref.read(circleProvider(widget.circle.id).notifier);

  Future<void> _run(String id, Future<void> Function() action, {String? done}) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    await runCircleAction(context, action, done: done);
    if (mounted) setState(() => _busy.remove(id));
  }

  bool get _open => widget.round.state == RoundState.collecting || widget.round.state == RoundState.readyForPayout;

  Future<void> _approve(Obligation o) =>
      _run('approve:${o.id}', () => _controller.approve(o), done: context.l10n.approvedDone(o.member));

  Future<void> _reject(Obligation o) async {
    final reason = await showAppSheet<String>(context, builder: (_) => RejectSheet(member: o.member));
    if (reason == null || !mounted) return;
    await _run('reject:${o.id}', () => _controller.reject(o, reason), done: context.l10n.rejectedDone);
  }

  Future<void> _details(Obligation o) => showAppSheet<void>(
    context,
    builder: (_) => PaymentDetailsSheet(
      circleId: widget.circle.id,
      obligation: o,
      canUndo: widget.circle.isOrganizer && widget.circle.status == CircleStatus.active && _open,
    ),
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
    final colors = context.colors;
    final c = widget.circle;
    final round = widget.round;
    final all = round.obligations;
    final paid = [for (final o in all) if (o.state == ObligationState.approved) o];
    final reported = [for (final o in all) if (o.state == ObligationState.reported) o];
    final pending = [for (final o in all) if (o.state == ObligationState.pending) o];
    final organizer = c.isOrganizer && c.status == CircleStatus.active;
    final selecting = organizer && round.state == RoundState.collecting;
    final reminders = c.reminders;
    final remindable = pending.where((o) => (c.member(o.memberId)?.linked ?? false) && o.memberId != c.actorMemberId).length;
    // People not on Daira get no app reminder: the organizer can send one on WhatsApp.
    final offApp = [
      for (final o in pending)
        if (!(c.member(o.memberId)?.linked ?? true) && o.memberId != c.actorMemberId) o,
    ];
    final showPaid = _showPaid || (pending.isEmpty && reported.isEmpty);
    final allPicked = pending.isNotEmpty && pending.every((o) => widget.selected.contains(o.id));

    final rows = <Widget>[
      for (final o in reported)
        organizer
            ? _ReportedRow(
                obligation: o,
                isMe: o.memberId == c.actorMemberId,
                shares: c.member(o.memberId)?.shares ?? 1,
                busy: _busy,
                onApprove: () => _approve(o),
                onReject: () => _reject(o),
              )
            : _StateRow(obligation: o, isMe: o.memberId == c.actorMemberId, shares: c.member(o.memberId)?.shares ?? 1),
      for (final o in pending)
        selecting
            ? _SelectableRow(
                obligation: o,
                isMe: o.memberId == c.actorMemberId,
                shares: c.member(o.memberId)?.shares ?? 1,
                selected: widget.selected.contains(o.id),
                onTap: () => widget.onToggle(o),
              )
            : _StateRow(obligation: o, isMe: o.memberId == c.actorMemberId, shares: c.member(o.memberId)?.shares ?? 1),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(t.roundPaymentsTitle(round.number), style: context.text.titleMedium)),
            if (selecting && pending.length > 1)
              TextButton(
                onPressed: () => widget.onSelectAll(!allPicked),
                child: Text(allPicked ? t.clearSelection : t.selectAll),
              ),
          ],
        ),
        if (selecting && pending.isNotEmpty) ...[
          Row(
            children: [
              Icon(AppIcons.info, size: 16, color: colors.textMuted),
              const SizedBox(width: Space.xxs + 2),
              Expanded(child: Text(t.selectToRecordHint, style: context.text.bodySmall)),
            ],
          ),
          const SizedBox(height: Space.sm),
        ] else
          const SizedBox(height: Space.xs),
        if (rows.isNotEmpty)
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, row) in rows.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: Space.md, endIndent: Space.md),
                  row,
                ],
              ],
            ),
          ),
        if (paid.isNotEmpty) ...[
          if (rows.isNotEmpty) const SizedBox(height: Space.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: rows.isEmpty ? null : () => setState(() => _showPaid = !_showPaid),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                    child: Row(
                      children: [
                        Icon(AppIcons.success, size: 20, color: colors.success),
                        const SizedBox(width: Space.xs),
                        Expanded(child: Text(t.paidGroup(paid.length), style: context.text.labelLarge)),
                        AmountText(paid.fold<Money>(paid.first.amount.times(0), (sum, o) => sum + o.amount)),
                        if (rows.isNotEmpty) ...[
                          const SizedBox(width: Space.xs),
                          AnimatedRotation(
                            turns: showPaid ? 0.5 : 0,
                            duration: Motion.fast,
                            child: Icon(AppIcons.expand, size: 18, color: colors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: context.reduceMotion ? Duration.zero : Motion.standard,
                  curve: Motion.easing,
                  alignment: Alignment.topCenter,
                  child: showPaid
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final o in paid) ...[
                              const Divider(height: 1, indent: Space.md, endIndent: Space.md),
                              _PaidRow(obligation: o, isMe: o.memberId == c.actorMemberId,
                shares: c.member(o.memberId)?.shares ?? 1, onTap: () => _details(o)),
                            ],
                          ],
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ],
        if (organizer && round.state == RoundState.collecting && offApp.isNotEmpty && widget.selected.isEmpty) ...[
          const SizedBox(height: Space.sm),
          AppButton.text(
            label: t.waRemindAction(offApp.length),
            icon: AppIcons.message,
            onPressed: () => showAppSheet<void>(
              context,
              builder: (_) => WhatsAppRemindSheet(circleId: c.id, round: round, obligations: offApp),
            ),
          ),
        ],
        if (organizer && round.state == RoundState.collecting && reminders != null && remindable > 0 && widget.selected.isEmpty) ...[
          const SizedBox(height: Space.md),
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

/// Avatar (or a check when selected), name, amount and status. Tap to select.
class _SelectableRow extends StatelessWidget {
  const _SelectableRow({required this.obligation, required this.isMe, this.shares = 1, required this.selected, required this.onTap});
  final Obligation obligation;
  final bool isMe;
  final int shares;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final o = obligation;
    final duration = context.reduceMotion ? Duration.zero : Motion.fast;
    return Semantics(
      checked: selected,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: duration,
          color: selected ? colors.primaryContainer.withValues(alpha: 0.6) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                child: selected
                    ? Container(
                        key: const ValueKey('on'),
                        width: Sizes.avatar,
                        height: Sizes.avatar,
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                        child: Icon(AppIcons.check, size: 18, color: colors.onPrimary),
                      )
                    : InitialsAvatar(o.member, key: const ValueKey('off'), highlight: isMe),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemberName(isMe ? t.youName(o.member) : o.member, shares: shares),
                    AmountText(o.amount),
                  ],
                ),
              ),
              const SizedBox(width: Space.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: ObligationChip(o.state, overdue: o.overdue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only row (members, or a round that is no longer collecting).
class _StateRow extends StatelessWidget {
  const _StateRow({required this.obligation, required this.isMe, this.shares = 1});
  final Obligation obligation;
  final bool isMe;
  final int shares;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final o = obligation;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
      child: Row(
        children: [
          InitialsAvatar(o.member, highlight: isMe),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemberName(isMe ? t.youName(o.member) : o.member, shares: shares),
                AmountText(o.amount),
              ],
            ),
          ),
          const SizedBox(width: Space.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: ObligationChip(o.state, overdue: o.overdue),
          ),
        ],
      ),
    );
  }
}

/// A member said «دفعت القسط»: the organizer confirms or says it did not arrive.
class _ReportedRow extends StatelessWidget {
  const _ReportedRow({
    required this.obligation,
    required this.isMe,
    this.shares = 1,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final Obligation obligation;
  final bool isMe;
  final int shares;
  final Set<String> busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final o = obligation;
    return Padding(
      padding: const EdgeInsets.all(Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(o.member, highlight: isMe),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemberName(isMe ? t.youName(o.member) : o.member, shares: shares),
                    Text(
                      o.reportedAt != null ? t.reportedAt(relativeTime(t, o.reportedAt!)) : t.obligationReported,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              AmountText(o.amount),
            ],
          ),
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
      ),
    );
  }
}

class _PaidRow extends StatelessWidget {
  const _PaidRow({required this.obligation, required this.isMe, this.shares = 1, required this.onTap});
  final Obligation obligation;
  final bool isMe;
  final int shares;
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
                  MemberName(isMe ? t.youName(o.member) : o.member, shares: shares),
                  if (method != null || o.recordedByOrganizer)
                    Text(
                      [
                        if (method != null) methodLabel(t, method),
                        if (o.recordedByOrganizer) t.recordedByOrganizer,
                      ].join(' · '),
                      style: context.text.bodySmall,
                    ),
                ],
              ),
            ),
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
  const RecordSheet({required this.title, required this.amount, this.members = const [], super.key});
  final String title;
  final Money amount;

  /// Names included, shown when recording several at once.
  final List<String> members;

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
        if (widget.members.length > 1) ...[
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [for (final name in widget.members) StatusChip(name, tone: Tone.info)],
          ),
        ],
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


/// WhatsApp reminders for unpaid members who are not on Daira: one tap each
/// opens a chat with a ready message. A missing number is added right here.
class WhatsAppRemindSheet extends ConsumerStatefulWidget {
  const WhatsAppRemindSheet({required this.circleId, required this.round, required this.obligations, super.key});
  final String circleId;
  final Round round;
  final List<Obligation> obligations;

  @override
  ConsumerState<WhatsAppRemindSheet> createState() => _WhatsAppRemindSheetState();
}

class _WhatsAppRemindSheetState extends ConsumerState<WhatsAppRemindSheet> {
  final _sent = <String>{};

  /// Numbers added in this sheet (the circle reloads in the background).
  final _added = <String, String>{};

  Future<void> _remind(Circle circle, Obligation o, String phone) async {
    final t = context.l10n;
    final due = widget.round.dueDate;
    final text = t.waReminderText(
      o.member,
      circle.name,
      widget.round.number,
      o.amount.format(t.localeName),
      due == null ? '' : t.date(due),
    );
    if (!await openWhatsAppChat(phone, text)) {
      if (mounted) showToast(context, t.phoneCannotOpen, tone: Tone.danger);
      return;
    }
    if (mounted) setState(() => _sent.add(o.id));
  }

  Future<void> _addNumber(Circle circle, Obligation o, Member member) async {
    final phone = await showAppSheet<String>(
      context,
      builder: (_) => _MemberPhoneSheet(contactId: member.contactId!, name: o.member),
    );
    if (phone == null || !mounted) return;
    setState(() => _added[o.memberId] = phone);
    ref.read(circleProvider(widget.circleId).notifier).reload();
    await _remind(circle, o, phone);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final circle = ref.watch(circleProvider(widget.circleId)).valueOrNull;
    if (circle == null) return const Center(child: RingLoader());
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.waRemindTitle, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.waRemindBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: Space.md),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final o in widget.obligations)
                Builder(
                  builder: (context) {
                    final member = circle.member(o.memberId);
                    final phone = _added[o.memberId] ?? member?.phone;
                    final sent = _sent.contains(o.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: InitialsAvatar(o.member),
                      title: Text(o.member),
                      subtitle: AmountText(o.amount),
                      trailing: phone != null
                          ? (sent
                                ? AppButton.text(label: t.waSent, icon: AppIcons.check, onPressed: () => _remind(circle, o, phone))
                                : AppButton.text(label: t.waSend, icon: AppIcons.message, onPressed: () => _remind(circle, o, phone)))
                          : member?.contactId == null
                          ? null
                          : AppButton.text(label: t.addNumber, icon: AppIcons.add, onPressed: () => _addNumber(circle, o, member!)),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        AppButton.secondary(label: t.done, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

/// The phone number of a member not on Daira (kept on the organizer's contact).
class _MemberPhoneSheet extends ConsumerStatefulWidget {
  const _MemberPhoneSheet({required this.contactId, required this.name});
  final String contactId;
  final String name;

  @override
  ConsumerState<_MemberPhoneSheet> createState() => _MemberPhoneSheetState();
}

class _MemberPhoneSheetState extends ConsumerState<_MemberPhoneSheet> {
  final _phone = TextEditingController();
  late String _country;
  bool _busy = false;
  String? _error;

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
    final t = context.l10n;
    if (_phone.text.trim().isEmpty) {
      setState(() => _error = t.requiredField);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final contact = await ref.read(contactsRepositoryProvider).update(widget.contactId, phone: _phone.text, country: _country);
      refreshLists(ref.invalidate);
      if (mounted) Navigator.pop(context, contact.phone);
    } catch (error) {
      if (mounted) setState(() => _error = t.error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.memberPhoneTitle(widget.name), style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.memberPhoneBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: Space.lg),
        PhoneInput(
          controller: _phone,
          country: _country,
          onCountry: (c) => setState(() => _country = c),
          enabled: !_busy,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.xs),
            child: Text(_error!, style: context.text.bodySmall?.copyWith(color: context.colors.danger)),
          ),
        const SizedBox(height: Space.lg),
        AppButton(label: t.waSaveAndSend, icon: AppIcons.message, loading: _busy, onPressed: _save),
      ],
    );
  }
}
