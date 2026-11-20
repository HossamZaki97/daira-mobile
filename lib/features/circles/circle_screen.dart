import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/router.dart';
import '../../core/models/circle.dart';
import '../../core/models/money.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../state.dart';
import 'payments.dart';
import 'turns.dart';

/// One circle, top to bottom: the current round (with its due date), quick
/// actions, what I must do now, then the round's installments or the turns.
class CircleScreen extends ConsumerWidget {
  const CircleScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(circleProvider(id));
    final name = circle.valueOrNull?.name ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(name, overflow: TextOverflow.ellipsis)),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => ref.read(circleProvider(id).notifier).reload(),
        child: circle.when(
          skipLoadingOnReload: true,
          loading: () => const PageBody(
            children: [Skeleton.card(height: 220), SizedBox(height: Space.md), SkeletonList(count: 3, height: 72)],
          ),
          error: (e, _) => ListView(
            children: [SizedBox(height: 480, child: LoadError(e, onRetry: () => ref.invalidate(circleProvider(id))))],
          ),
          data: (c) => _CircleBody(c),
        ),
      ),
    );
  }
}

enum _View { payments, turns }

class _CircleBody extends ConsumerStatefulWidget {
  const _CircleBody(this.circle);
  final Circle circle;

  @override
  ConsumerState<_CircleBody> createState() => _CircleBodyState();
}

class _CircleBodyState extends ConsumerState<_CircleBody> {
  /// Actions waiting for the server, so their buttons show the loader.
  final _busy = <String>{};

  /// Unpaid installments the organizer picked to record together.
  final _selected = <String>{};
  _View? _view;

  CircleController get _controller => ref.read(circleProvider(widget.circle.id).notifier);

  Future<void> _run(String id, Future<void> Function() action, {String? done}) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await action();
      if (mounted && done != null) showToast(context, done, tone: Tone.success);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _report(Obligation o) async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.confirmPaidTitle, body: t.confirmPaidBody, confirm: t.actionPaid);
    if (ok) await _run('report:${o.id}', () => _controller.report(o), done: t.paidDone);
  }

  Future<void> _payout(Round r) async {
    final t = context.l10n;
    final ok = await confirmDialog(
      context,
      title: t.confirmPayoutTitle,
      body: t.confirmPayoutBody(r.recipient),
      confirm: t.actionPayout,
    );
    if (ok) await _run('payout:${r.number}', () => _controller.payout(r.number), done: t.payoutDone);
  }

  Future<void> _markReceived(Round r) async {
    final t = context.l10n;
    final ok = await confirmDialog(
      context,
      title: t.markReceivedTitle(r.recipient),
      body: t.markReceivedBody(r.recipient),
      confirm: t.markReceived,
    );
    if (ok) await _run('received:${r.number}', () => _controller.markReceived(r.number), done: t.receivedDone);
  }

  Future<void> _undoPayout(Round r) async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.undoPayoutTitle, body: t.undoPayoutBody, confirm: t.undoPayout, danger: true);
    if (ok) await _run('undoPayout:${r.number}', () => _controller.undoPayout(r.number), done: t.undoPayoutDone);
  }

  Future<void> _dispute(Round r) async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.disputeTitle, body: t.disputeBody, confirm: t.notReceivedMine, danger: true);
    if (ok) await _run('dispute:${r.number}', () => _controller.disputeReceipt(r.number), done: t.disputeDone);
  }

  Future<void> _receipt(Round r) async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.confirmReceiptTitle, body: t.confirmReceiptBody, confirm: t.actionReceipt);
    if (ok) await _run('receipt:${r.number}', () => _controller.receipt(r.number), done: t.receiptDone);
  }

  /// Organizer: record the selected installments in one step (method and note optional).
  Future<void> _recordSelected(List<Obligation> items) async {
    if (items.isEmpty) return;
    final t = context.l10n;
    final result = await showAppSheet<RecordChoice>(
      context,
      builder: (_) => RecordSheet(
        title: items.length == 1 ? t.recordTitle(items.first.member) : t.recordSelected(items.length),
        amount: _total(items),
        members: [for (final o in items) o.member],
      ),
    );
    if (result == null || !mounted) return;
    await _run('record', () => _controller.recordPayments(items, method: result.method, note: result.note), done: t.recordedDone);
    if (mounted) setState(_selected.clear);
  }

  Money _total(List<Obligation> items) => items.fold<Money>(items.first.amount.times(0), (sum, o) => sum + o.amount);

  /// The latest round the organizer closed for me, recently: I can say it did not arrive.
  Round? _disputable(Circle c) {
    final last = c.lastClosedRound;
    if (c.isOrganizer || last == null || last.recipientId != c.actorMemberId || last.receivedBy != 'organizer') return null;
    final at = last.receivedAt;
    if (at == null || DateTime.now().toUtc().difference(at.toUtc()).inDays > 7) return null;
    return last;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final c = widget.circle;
    final round = c.currentRound;
    final mine = round?.obligations.where((o) => o.memberId == c.actorMemberId).firstOrNull;
    final active = c.status == CircleStatus.active;
    final showPayments = active && round != null && round.obligations.isNotEmpty;
    final view = showPayments ? (_view ?? _View.payments) : _View.turns;

    // Only unpaid installments of a round still collecting can be selected.
    final selectable = c.isOrganizer && active && round?.state == RoundState.collecting;
    final pending = [
      if (selectable)
        for (final o in round!.obligations)
          if (o.state == ObligationState.pending) o,
    ];
    final picked = [for (final o in pending) if (_selected.contains(o.id)) o];
    final barVisible = view == _View.payments && picked.isNotEmpty;
    final unpaidCount = round?.obligations.where((o) => o.state != ObligationState.approved).length ?? 0;

    return Stack(
      children: [
        PageBody(
          padding: EdgeInsets.fromLTRB(Space.gutter, Space.xs, Space.gutter, barVisible ? 120 : Space.xxl),
          children: [
            if (c.status == CircleStatus.suspended)
              _Gap(InlineBanner(title: t.circleSuspendedTitle, body: t.circleSuspendedBody, tone: Tone.danger)),
            if (c.status == CircleStatus.cancelled) _Gap(InlineBanner(title: t.circleCancelledTitle, tone: Tone.danger)),
            if (c.status == CircleStatus.completed)
              _Gap(InlineBanner(title: t.circleCompletedTitle, tone: Tone.success, icon: AppIcons.confirmed)),
            if (c.status == CircleStatus.draft) _DraftCard(c),
            if (_disputable(c) case final last?)
              _Gap(
                InlineBanner(
                  title: t.receiptRecordedForYou(last.number),
                  icon: AppIcons.received,
                  action: AppButton.text(label: t.notReceivedMine, onPressed: () => _dispute(last)),
                ),
              ),

            if (round != null && c.status != CircleStatus.draft) _RoundHero(circle: c, round: round) else _Summary(c),

            if (c.status != CircleStatus.draft) ...[
              const SizedBox(height: Space.md),
              _QuickActions(c),
            ],

            // --- what I must do now
            ..._myActions(c, round, mine, active),

            // --- the round's installments, or everyone's turns
            const SizedBox(height: Space.xl),
            if (showPayments) ...[
              SegmentedTabs<_View>(
                items: [(_View.payments, t.tabPayments, c.isOrganizer ? unpaidCount : null), (_View.turns, t.tabTurns, null)],
                value: view,
                onChanged: (v) => setState(() => _view = v),
              ),
              const SizedBox(height: Space.md),
            ] else ...[
              Text(t.turnOrder, style: context.text.titleMedium),
              const SizedBox(height: Space.sm),
            ],
            AnimatedSwitcher(
              duration: context.reduceMotion ? Duration.zero : Motion.standard,
              switchInCurve: Motion.easing,
              child: view == _View.payments
                  ? RoundPayments(
                      key: const ValueKey('payments'),
                      circle: c,
                      round: round!,
                      selected: {for (final o in picked) o.id},
                      onToggle: (o) => setState(() => _selected.contains(o.id) ? _selected.remove(o.id) : _selected.add(o.id)),
                      onSelectAll: (all) => setState(() {
                        _selected.clear();
                        if (all) _selected.addAll(pending.map((o) => o.id));
                      }),
                    )
                  : TurnsTimeline(key: const ValueKey('turns'), circle: c),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Sizes.maxContent),
            child: SelectionBar(
              visible: barVisible,
              label: picked.isEmpty ? '' : t.selectedSummary(picked.length, _total(picked).format(context.localeName)),
              onClear: () => setState(_selected.clear),
              action: AppButton(
                label: t.recordShort,
                icon: AppIcons.check,
                expand: false,
                loading: _busy.contains('record'),
                onPressed: () => _recordSelected(picked),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _myActions(Circle c, Round? round, Obligation? mine, bool active) {
    final t = context.l10n;
    if (!active || round == null) return const [];
    return [
      if (mine != null && round.state == RoundState.collecting && mine.state != ObligationState.approved)
        _ActionCard(
          icon: AppIcons.pay,
          title: t.yourPayment,
          trailing: MyPaymentChip(mine.state, overdue: mine.overdue),
          child: _MyPayment(obligation: mine, busy: _busy.contains('report:${mine.id}'), onPaid: () => _report(mine)),
        ),
      if (round.state == RoundState.payoutReported && round.recipientId == c.actorMemberId)
        _ActionCard(
          icon: AppIcons.receive,
          title: t.yourPayout,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.payoutSentToYou(round.expected.format(context.localeName)), style: context.text.bodyMedium),
              const SizedBox(height: Space.md),
              AppButton(
                label: t.actionReceipt,
                icon: AppIcons.receive,
                loading: _busy.contains('receipt:${round.number}'),
                onPressed: () => _receipt(round),
              ),
            ],
          ),
        ),
      if (c.isOrganizer && round.state == RoundState.readyForPayout)
        _ActionCard(
          icon: AppIcons.payout,
          title: t.handOver,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.readyForPayoutBody(round.recipient), style: context.text.bodyMedium),
              const SizedBox(height: Space.xs),
              AmountText(round.expected, large: true),
              const SizedBox(height: Space.md),
              AppButton(
                label: t.actionPayout,
                icon: AppIcons.payout,
                loading: _busy.contains('payout:${round.number}'),
                onPressed: () => _payout(round),
              ),
            ],
          ),
        ),
      if (c.isOrganizer && round.state == RoundState.payoutReported)
        _ActionCard(
          icon: AppIcons.waiting,
          title: t.handOver,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.waitingRecipient(round.recipient), style: context.text.bodyMedium),
              const SizedBox(height: Space.md),
              AppButton.secondary(
                label: t.markReceived,
                icon: AppIcons.received,
                loading: _busy.contains('received:${round.number}'),
                onPressed: () => _markReceived(round),
              ),
              const SizedBox(height: Space.xxs),
              AppButton.text(label: t.undoPayout, icon: AppIcons.undo, onPressed: () => _undoPayout(round)),
            ],
          ),
        ),
    ];
  }
}

class _Gap extends StatelessWidget {
  const _Gap(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: Space.md), child: child);
}

/// A thing to do now: tinted icon, title, then the content.
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.child, this.trailing});
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: Space.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: colors.accentContainer, shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: Space.sm),
                Expanded(child: Text(title, style: context.text.titleMedium)),
                // Status sits in the corner, at its natural width.
                if (trailing != null) ...[
                  const SizedBox(width: Space.xs),
                  ConstrainedBox(constraints: const BoxConstraints(maxWidth: 170), child: trailing!),
                ],
              ],
            ),
            const SizedBox(height: Space.sm),
            child,
          ],
        ),
      ),
    );
  }
}

/// Circle facts when there is no current round (draft or finished).
class _Summary extends StatelessWidget {
  const _Summary(this.circle);
  final Circle circle;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final c = circle;
    return Wrap(
      spacing: Space.xs,
      runSpacing: Space.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CircleStatusChip(c.status),
        StatusChip(t.perShare(c.installment.format(context.localeName)), tone: Tone.info, icon: AppIcons.pay),
        StatusChip(cadenceLabel(t, c.cadence, c.interval), tone: Tone.info, icon: AppIcons.calendar),
        if (c.isOrganizer) StatusChip(t.youOrganize, tone: Tone.info, icon: AppIcons.organizer),
      ],
    );
  }
}

/// The current round on navy: who receives, how much, progress and — most
/// visible — when the installment is due.
class _RoundHero extends StatelessWidget {
  const _RoundHero({required this.circle, required this.round});
  final Circle circle;
  final Round round;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final muted = context.text.bodySmall?.copyWith(color: colors.onHeroMuted);
    final mine = round.recipientId == circle.actorMemberId;
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${t.roundOf(round.number, circle.rounds.length)} · ${cadenceLabel(t, circle.cadence, circle.interval)}',
                  style: muted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.onHero.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(t.roundState(round.state), style: context.text.labelSmall?.copyWith(color: colors.accent)),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(
            mine ? t.yourTurnNow : t.recipientIs(round.recipient),
            style: context.text.titleMedium?.copyWith(color: colors.onHero),
          ),
          const SizedBox(height: Space.xxs),
          AmountText(round.expected, large: true, color: colors.onHero),
          const SizedBox(height: Space.md),
          ProgressBar(round.progress, onHero: true),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              // What the bar above measures, in words.
              Expanded(child: Text(t.collectedInstallments(round.paidCount, round.obligations.length), style: muted)),
              const SizedBox(width: Space.xs),
              Flexible(
                child: Text(
                  t.perShare(circle.installment.format(context.localeName)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ),
            ],
          ),
          if (round.dueDate != null) ...[
            const SizedBox(height: Space.md),
            _DueStrip(date: round.dueDate!, countdown: round.state == RoundState.collecting),
          ],
        ],
      ),
    );
  }
}

/// «موعد القسط · الخميس 5 ديسمبر» with how long is left, inside the hero.
class _DueStrip extends StatelessWidget {
  const _DueStrip({required this.date, required this.countdown});
  final DateTime date;
  final bool countdown;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final days = daysUntil(date);
    final (Color bg, Color fg) = days < 0
        ? (colors.dangerContainer, colors.danger)
        : days == 0
        ? (colors.accent, colors.onAccent)
        : (colors.onHero.withValues(alpha: 0.14), colors.onHero);
    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: colors.onHero.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(AppIcons.dueDate, size: 20, color: colors.accent),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.installmentDue, style: context.text.labelSmall?.copyWith(color: colors.onHeroMuted)),
                Text(
                  DateFormat.MMMMEEEEd(t.localeName).format(date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(color: colors.onHero, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (countdown) ...[
            const SizedBox(width: Space.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
              child: Text(dueLabel(t, date), style: context.text.labelSmall?.copyWith(color: fg)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Everything that used to hide behind ⋯, as visible tiles.
class _QuickActions extends ConsumerWidget {
  const _QuickActions(this.circle);
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final c = circle;
    final active = c.status == CircleStatus.active;
    final turnOrder = ref.watch(settingsProvider)?.features.turnOrder ?? true;
    final controller = ref.read(circleProvider(c.id).notifier);
    return ActionTiles(
      children: [
        ActionTile(icon: AppIcons.table, label: t.installmentsTable, onTap: () => context.push(Routes.installments(c.id))),
        if (c.isOrganizer && active && turnOrder && c.futureRounds.length > 1)
          ActionTile(icon: AppIcons.reorder, label: t.turnOrder, onTap: () => context.push(Routes.turnOrder(c.id))),
        if (c.isOrganizer && active)
          ActionTile(
            icon: AppIcons.remind,
            label: t.reminderSettings,
            onTap: () => showAppSheet<void>(context, builder: (_) => ReminderSettingsSheet(circle: c)),
          ),
        if (!c.isOrganizer && active)
          ActionTile(
            icon: c.muted ? AppIcons.mute : AppIcons.remind,
            label: c.muted ? t.unmuteReminders : t.muteReminders,
            onTap: () => runCircleAction(context, () => controller.mute(!c.muted), done: c.muted ? t.unmutedDone : t.mutedDone),
          ),
        ActionTile(icon: AppIcons.history, label: t.activityLog, onTap: () => context.push(Routes.activity(c.id))),
      ],
    );
  }
}

class _MyPayment extends StatelessWidget {
  const _MyPayment({required this.obligation, required this.busy, required this.onPaid});
  final Obligation obligation;
  final bool busy;
  final VoidCallback onPaid;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final o = obligation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AmountText(o.amount, large: true),
        if (o.state == ObligationState.pending && o.reason != null) ...[
          const SizedBox(height: Space.sm),
          InlineBanner(title: t.notReceivedReason(o.reason!), body: t.notReceivedHint, tone: Tone.danger),
        ],
        const SizedBox(height: 2),
        if (o.state == ObligationState.pending) ...[
          Text(t.payHint, style: context.text.bodySmall),
          const SizedBox(height: Space.sm),
          AppButton(label: t.actionPaid, icon: AppIcons.pay, loading: busy, onPressed: onPaid),
        ] else
          Text(t.waitingOrganizer, style: context.text.bodyMedium),
      ],
    );
  }
}

/// Draft: only the organizer sees it; edit or start it.
class _DraftCard extends ConsumerStatefulWidget {
  const _DraftCard(this.circle);
  final Circle circle;

  @override
  ConsumerState<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends ConsumerState<_DraftCard> {
  bool _busy = false;

  Future<void> _activate() async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.startCircleTitle, body: t.startCircleBody, confirm: t.startCircle);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(circleProvider(widget.circle.id).notifier).activate(widget.circle.version);
      if (mounted) showToast(context, t.circleStarted, tone: Tone.success);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (!widget.circle.isOrganizer) return const SizedBox.shrink();
    return _Gap(
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.draftTitle, style: context.text.titleMedium),
            const SizedBox(height: Space.xxs),
            Text(t.draftBody, style: context.text.bodySmall),
            const SizedBox(height: Space.md),
            AppButton(label: t.startCircle, loading: _busy, onPressed: _activate),
            const SizedBox(height: Space.xs),
            AppButton.secondary(
              label: t.editDraft,
              icon: AppIcons.edit,
              onPressed: _busy ? null : () => context.push(Routes.editDraft(widget.circle.id)),
            ),
          ],
        ),
      ),
    );
  }
}
