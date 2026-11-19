import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/circle.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../invitations/invite_sheet.dart';
import '../state.dart';
import 'payments.dart';

/// One circle: the current round, what I must do, what the organizer must do,
/// members and the full turn order.
class CircleScreen extends ConsumerWidget {
  const CircleScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final circle = ref.watch(circleProvider(id));
    final name = circle.valueOrNull?.name ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(name, overflow: TextOverflow.ellipsis),
        actions: [
          if (circle.hasValue)
            IconButton(
              tooltip: t.activityLog,
              icon: const Icon(AppIcons.history),
              onPressed: () => context.push(Routes.activity(id)),
            ),
          if (circle.valueOrNull case final c? when c.status != CircleStatus.draft) _CircleMenu(c),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => ref.read(circleProvider(id).notifier).reload(),
        child: circle.when(
          skipLoadingOnReload: true,
          loading: () => const PageBody(
            children: [Skeleton.card(height: 180), SizedBox(height: Space.md), SkeletonList(count: 3, height: 72)],
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

class _CircleBody extends ConsumerStatefulWidget {
  const _CircleBody(this.circle);
  final Circle circle;

  @override
  ConsumerState<_CircleBody> createState() => _CircleBodyState();
}

class _CircleBodyState extends ConsumerState<_CircleBody> {
  /// Actions waiting for the server, so their buttons show the loader.
  final _busy = <String>{};

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
    final me = c.me;
    final mine = round?.obligations.where((o) => o.memberId == c.actorMemberId).firstOrNull;
    final active = c.status == CircleStatus.active;
    return PageBody(
      children: [
        if (c.status == CircleStatus.suspended)
          _Notice(InlineBanner(title: t.circleSuspendedTitle, body: t.circleSuspendedBody, tone: Tone.danger)),
        if (c.status == CircleStatus.cancelled)
          _Notice(InlineBanner(title: t.circleCancelledTitle, tone: Tone.danger)),
        if (c.status == CircleStatus.completed)
          _Notice(InlineBanner(title: t.circleCompletedTitle, tone: Tone.success, icon: AppIcons.confirmed)),
        if (c.status == CircleStatus.draft) _DraftCard(c),
        if (_disputable(c) case final last?)
          _Notice(
            InlineBanner(
              title: t.receiptRecordedForYou(last.number),
              icon: AppIcons.received,
              action: AppButton.text(label: t.notReceivedMine, onPressed: () => _dispute(last)),
            ),
          ),
        _Summary(c),
        if (round != null) ...[
          const SizedBox(height: Space.md),
          _RoundHero(circle: c, round: round),
        ],

        // --- what I must do
        if (active && round != null && mine != null && round.state == RoundState.collecting) ...[
          SectionHeader(t.yourPayment),
          _MyPayment(
            obligation: mine,
            busy: _busy.contains('report:${mine.id}'),
            onPaid: () => _report(mine),
          ),
        ],
        if (active && round != null && round.state == RoundState.payoutReported && round.recipientId == c.actorMemberId) ...[
          SectionHeader(t.yourPayout),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.payoutSentToYou(round.expected.format(context.localeName)), style: context.text.bodyLarge),
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
        ],

        // --- what the organizer must do
        if (c.isOrganizer && active && round != null) ...[
          if (round.state == RoundState.readyForPayout) ...[
            SectionHeader(t.handOver),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.readyForPayoutBody(round.recipient), style: context.text.bodyLarge),
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
          ],
          if (round.state == RoundState.payoutReported) ...[
            const SizedBox(height: Space.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.waitingRecipient(round.recipient), style: context.text.bodyLarge),
                  const SizedBox(height: Space.md),
                  AppButton.secondary(
                    label: t.markReceived,
                    icon: AppIcons.received,
                    loading: _busy.contains('received:${round.number}'),
                    onPressed: () => _markReceived(round),
                  ),
                  const SizedBox(height: Space.xs),
                  AppButton.text(label: t.undoPayout, icon: AppIcons.undo, onPressed: () => _undoPayout(round)),
                ],
              ),
            ),
          ],
          if (round.state == RoundState.collecting || round.state == RoundState.readyForPayout)
            RoundPayments(circle: c, round: round),
        ],

        // --- people and turns
        SectionHeader(t.membersCount(c.members.length)),
        _Members(circle: c, me: me),
        SectionHeader(t.turnOrder),
        _Rounds(c),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: Space.md), child: child);
}

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
              Expanded(child: Text(t.roundOf(round.number, circle.rounds.length), style: muted)),
              Text(t.roundState(round.state), style: context.text.labelMedium?.copyWith(color: colors.accent)),
            ],
          ),
          const SizedBox(height: Space.xs),
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
              Expanded(
                child: Text(
                  t.collectedOf(round.approved.amount(context.localeName), round.expected.amount(context.localeName)),
                  style: muted,
                ),
              ),
              if (round.dueDate != null)
                Text(
                  round.overdue ? t.daysLate(-daysUntil(round.dueDate!)) : t.date(round.dueDate!),
                  style: muted?.copyWith(color: round.overdue ? colors.accent : null),
                ),
            ],
          ),
        ],
      ),
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: AlignmentDirectional.centerStart, child: ObligationChip(o.state, overdue: o.overdue)),
          const SizedBox(height: Space.xs),
          AmountText(o.amount, large: true),
          if (o.state == ObligationState.pending && o.reason != null) ...[
            const SizedBox(height: Space.sm),
            InlineBanner(title: t.notReceivedReason(o.reason!), body: t.notReceivedHint, tone: Tone.danger),
          ],
          const SizedBox(height: Space.sm),
          if (o.state == ObligationState.pending) ...[
            Text(t.payHint, style: context.text.bodySmall),
            const SizedBox(height: Space.md),
            AppButton(label: t.actionPaid, icon: AppIcons.pay, loading: busy, onPressed: onPaid),
          ] else if (o.state == ObligationState.reported)
            Text(t.waitingOrganizer, style: context.text.bodyMedium)
          else
            Text(t.paymentConfirmed, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

class _Members extends ConsumerWidget {
  const _Members({required this.circle, required this.me});
  final Circle circle;
  final Member? me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final c = circle;
    final canInvite = c.isOrganizer &&
        c.status == CircleStatus.active &&
        (ref.watch(settingsProvider)?.features.invitations ?? true);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, m) in c.members.indexed) ...[
            if (i > 0) const Divider(indent: Space.md, endIndent: Space.md),
            ListTile(
              leading: InitialsAvatar(m.name, highlight: m.id == me?.id),
              title: Text(m.id == me?.id ? t.youName(m.name) : m.name),
              subtitle: Text(
                [
                  if (m.organizer) t.organizer,
                  if (m.shares > 1) t.sharesCount(m.shares),
                  if (!m.organizer) m.linked ? t.memberJoined : t.memberNotJoined,
                  for (final n in m.receivedRounds) t.receivedRound(n),
                  if (m.accountName != null) t.accountNameLabel(m.accountName!),
                ].join(' · '),
              ),
              trailing: canInvite && !m.linked && !m.organizer
                  ? TextButton.icon(
                      onPressed: () => showInviteSheet(context, circle: c, member: m),
                      icon: const Icon(AppIcons.invite, size: 18),
                      label: Text(t.invite),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _Rounds extends StatelessWidget {
  const _Rounds(this.circle);
  final Circle circle;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Column(
        children: [
          for (final r in circle.rounds)
            Builder(
              builder: (context) {
                final current = r.number == circle.currentRoundNumber;
                final mine = r.recipientId == circle.actorMemberId;
                return Container(
                  color: current ? colors.primaryContainer.withValues(alpha: 0.5) : null,
                  padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('${r.number}', style: context.text.labelLarge?.copyWith(fontFeatures: DairaType.numeric.fontFeatures)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mine ? t.youName(r.recipient) : r.recipient,
                                style: context.text.titleSmall?.copyWith(fontWeight: mine ? FontWeight.w700 : null)),
                            if (r.dueDate != null) Text(t.date(r.dueDate!), style: context.text.bodySmall),
                          ],
                        ),
                      ),
                      if (r.legacy)
                        StatusChip(t.importedRound, tone: Tone.info)
                      else if (r.state == RoundState.completed)
                        StatusChip(t.receivedLabel, tone: Tone.success, icon: AppIcons.received)
                      else if (current)
                        StatusChip(t.roundState(r.state), tone: roundTone(r.state))
                      else if (mine)
                        Icon(AppIcons.turn, size: 20, color: colors.accent),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
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
    return _Notice(
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


/// More actions for one circle: installments table, turns, reminders, corrections.
class _CircleMenu extends ConsumerWidget {
  const _CircleMenu(this.circle);
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final c = circle;
    final active = c.status == CircleStatus.active;
    final turnOrder = ref.watch(settingsProvider)?.features.turnOrder ?? true;
    final controller = ref.read(circleProvider(c.id).notifier);
    final last = c.lastClosedRound;
    final items = <(String, IconData, VoidCallback)>[
      (t.installmentsTable, AppIcons.table, () => context.push(Routes.installments(c.id))),
      if (c.isOrganizer && active && turnOrder && c.futureRounds.length > 1)
        (t.editTurnOrder, AppIcons.reorder, () => context.push(Routes.turnOrder(c.id))),
      if (c.isOrganizer && active)
        (t.reminderSettings, AppIcons.remind, () => showAppSheet<void>(context, builder: (_) => ReminderSettingsSheet(circle: c))),
      if (c.isOrganizer && c.canUndoReceipt && last != null)
        (
          t.reopenRound(last.number),
          AppIcons.undo,
          () async {
            final ok = await confirmDialog(
              context,
              title: t.reopenRound(last.number),
              body: t.reopenBody,
              confirm: t.reopenRound(last.number),
              danger: true,
            );
            if (ok && context.mounted) {
              await runCircleAction(context, () => controller.undoReceipt(last.number), done: t.reopenedDone);
            }
          },
        ),
      if (!c.isOrganizer && active)
        (
          c.muted ? t.unmuteReminders : t.muteReminders,
          c.muted ? AppIcons.remind : AppIcons.mute,
          () => runCircleAction(context, () => controller.mute(!c.muted), done: c.muted ? t.unmutedDone : t.mutedDone),
        ),
    ];
    return PopupMenuButton<int>(
      tooltip: t.moreActions,
      icon: const Icon(AppIcons.more),
      onSelected: (i) => items[i].$3(),
      itemBuilder: (context) => [
        for (final (i, item) in items.indexed)
          PopupMenuItem(
            value: i,
            child: Row(
              children: [
                Icon(item.$2, size: 20),
                const SizedBox(width: Space.sm),
                Expanded(child: Text(item.$1)),
              ],
            ),
          ),
      ],
    );
  }
}
