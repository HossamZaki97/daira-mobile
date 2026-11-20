import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/circle.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../contacts/link_sheets.dart';
import '../invitations/invite_sheet.dart';
import '../state.dart';
import 'payments.dart';

/// Members and turn order in one list: who receives each round, when, and
/// where the circle is now. Tap a turn for the member's details and actions.
class TurnsTimeline extends StatefulWidget {
  const TurnsTimeline({required this.circle, super.key});
  final Circle circle;

  @override
  State<TurnsTimeline> createState() => _TurnsTimelineState();
}

class _TurnsTimelineState extends State<TurnsTimeline> {
  /// Long circles open on the rounds around now; the rest is one tap away.
  static const _window = 10;
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final c = widget.circle;
    final rounds = c.rounds;
    var from = 0;
    var to = rounds.length;
    if (!_all && rounds.length > _window + 2) {
      final now = rounds.indexWhere((r) => r.number == c.currentRoundNumber);
      from = (now < 0 ? 0 : now - 2).clamp(0, rounds.length - _window);
      to = from + _window;
    }
    final shown = rounds.sublist(from, to);

    Widget more(String label, IconData icon) => InkWell(
      onTap: () => setState(() => _all = !_all),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(width: Space.xs),
            Text(label, style: context.text.labelLarge?.copyWith(color: colors.primary)),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${t.membersCount(c.members.length)} · ${t.roundsCount(rounds.length)}',
              style: context.text.bodySmall,
            ),
            if (c.randomOrder) StatusChip(t.randomOrderChip, tone: Tone.info, icon: AppIcons.shuffle),
          ],
        ),
        const SizedBox(height: Space.sm),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: Column(
            children: [
              if (from > 0) ...[
                more(t.showEarlierRounds(from), AppIcons.expand),
                const Divider(height: 1),
              ],
              for (final (k, r) in shown.indexed)
                _TurnRow(
                  circle: c,
                  round: r,
                  first: from + k == 0,
                  last: from + k == rounds.length - 1,
                  // The line above this badge is "done" when the previous round is finished.
                  doneAbove: from + k > 0 && rounds[from + k - 1].state == RoundState.completed,
                  onTap: () => showAppSheet<void>(context, builder: (_) => MemberSheet(circleId: c.id, round: r)),
                ),
              if (to < rounds.length) ...[
                const Divider(height: 1),
                more(t.showAllRounds(rounds.length), AppIcons.expand),
              ] else if (_all && rounds.length > _window + 2) ...[
                const Divider(height: 1),
                more(t.showFewerRounds, AppIcons.close),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TurnRow extends StatelessWidget {
  const _TurnRow({
    required this.circle,
    required this.round,
    required this.first,
    required this.last,
    required this.doneAbove,
    required this.onTap,
  });
  final Circle circle;
  final Round round;
  final bool first;
  final bool last;
  final bool doneAbove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final r = round;
    final c = circle;
    final current = r.number == c.currentRoundNumber && c.status == CircleStatus.active;
    final done = r.state == RoundState.completed;
    final mine = r.recipientId == c.actorMemberId;
    final member = c.member(r.recipientId);
    final meta = [
      if (r.dueDate != null) t.date(r.dueDate!),
      if (member != null && !member.organizer && !member.linked) t.memberNotJoined,
      if (member?.organizer ?? false) t.organizer,
    ].join(' · ');

    Widget line(bool on, bool hidden) =>
        Expanded(child: Container(width: 2, color: hidden ? Colors.transparent : (on ? colors.success : colors.line)));

    return InkWell(
      onTap: onTap,
      child: Container(
        color: current ? colors.accentContainer.withValues(alpha: 0.55) : null,
        padding: const EdgeInsets.symmetric(horizontal: Space.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    line(doneAbove, first),
                    _Badge(number: r.number, done: done, current: current),
                    line(done, last),
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MemberName(
                        mine ? t.youName(r.recipient) : r.recipient,
                        shares: member?.shares ?? 1,
                        style: context.text.titleSmall?.copyWith(fontWeight: mine || current ? FontWeight.w700 : null),
                      ),
                      if (meta.isNotEmpty) Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Space.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Center(
                widthFactor: 1,
                child: r.legacy
                    ? StatusChip(t.importedRound, tone: Tone.info)
                    : done
                    ? StatusChip(t.receivedLabel, tone: Tone.success, icon: AppIcons.received)
                    : current
                    ? StatusChip(t.roundState(r.state), tone: roundTone(r.state))
                    : mine
                    ? StatusChip(t.yourTurnTag, tone: Tone.info, icon: AppIcons.turn)
                    : DirectionalIcon(AppIcons.forward, size: 16, color: colors.textDisabled),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round number in a circle: green check when received, amber while current.
class _Badge extends StatelessWidget {
  const _Badge({required this.number, required this.done, required this.current});
  final int number;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.labelMedium?.copyWith(fontFeatures: DairaType.numeric.fontFeatures);
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? colors.success : (current ? colors.accent : colors.surface),
        border: done || current ? null : Border.all(color: colors.lineStrong, width: 1.5),
        boxShadow: current ? [BoxShadow(color: colors.accent.withValues(alpha: 0.35), blurRadius: 8)] : null,
      ),
      child: done
          ? Icon(AppIcons.check, size: 16, color: colors.surface)
          : Text('$number', style: style?.copyWith(color: current ? colors.onAccent : colors.textMuted, fontWeight: FontWeight.w700)),
    );
  }
}

/// One turn's member: account, shares, all their turns; invite them or
/// reopen their round when allowed.
class MemberSheet extends ConsumerWidget {
  const MemberSheet({required this.circleId, required this.round, super.key});
  final String circleId;
  final Round round;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final colors = context.colors;
    final c = ref.watch(circleProvider(circleId)).valueOrNull;
    if (c == null) return const SizedBox.shrink();
    final m = c.member(round.recipientId);
    if (m == null) return const SizedBox.shrink();
    final isMe = m.id == c.actorMemberId;
    final turns = [for (final r in c.rounds) if (r.recipientId == m.id) r];
    final canInvite = c.isOrganizer &&
        c.status == CircleStatus.active &&
        !m.linked &&
        !m.organizer &&
        (ref.watch(settingsProvider)?.features.invitations ?? true);
    final last = c.lastClosedRound;
    final canReopen = c.isOrganizer && c.canUndoReceipt && last != null && last.recipientId == m.id;

    Future<void> reopen() async {
      final ok = await confirmDialog(
        context,
        title: t.reopenRound(last!.number),
        body: t.reopenBody,
        confirm: t.reopenRound(last.number),
        danger: true,
      );
      if (!ok || !context.mounted) return;
      final done = await runCircleAction(
        context,
        () => ref.read(circleProvider(circleId).notifier).undoReceipt(last.number),
        done: t.reopenedDone,
      );
      if (done && context.mounted) Navigator.pop(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InitialsAvatar(m.name, size: 52, highlight: isMe),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isMe ? t.youName(m.name) : m.name, style: context.text.titleLarge),
                  const SizedBox(height: Space.xxs),
                  Wrap(
                    spacing: Space.xs,
                    runSpacing: Space.xxs,
                    children: [
                      if (m.organizer) StatusChip(t.organizer, tone: Tone.info, icon: AppIcons.organizer),
                      if (!m.organizer)
                        m.linked
                            ? StatusChip(t.memberJoined, tone: Tone.success, icon: AppIcons.link)
                            : StatusChip(t.memberNotJoined, tone: Tone.pending),
                      if (m.shares > 1) StatusChip(t.sharesCount(m.shares), tone: Tone.info),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // The account's own name differs from the organizer's: offer one name for both.
        if (m.accountName != null) ...[
          const SizedBox(height: Space.md),
          if (c.isOrganizer && m.contactId != null)
            InlineBanner(
              title: t.accountNameIs(m.accountName!),
              body: t.unifyNameBody,
              icon: AppIcons.user,
              action: AppButton.secondary(
                label: t.useAccountName,
                icon: AppIcons.check,
                expand: false,
                onPressed: () async {
                  final done = await runCircleAction(
                    context,
                    () async {
                      await ref.read(contactsRepositoryProvider).update(m.contactId!, name: m.accountName!);
                      await ref.read(circleProvider(circleId).notifier).reload();
                    },
                    done: t.nameUpdated,
                  );
                  if (done && context.mounted) Navigator.pop(context);
                },
              ),
            )
          else
            Text(t.accountNameLabel(m.accountName!), style: context.text.bodySmall),
        ],
        const SizedBox(height: Space.lg),
        Text(t.tabTurns, style: context.text.labelLarge),
        const SizedBox(height: Space.xs),
        AppCard(
          padding: EdgeInsets.zero,
          color: colors.surfaceSunken,
          child: Column(
            children: [
              for (final (i, r) in turns.indexed) ...[
                if (i > 0) const Divider(height: 1, indent: Space.md, endIndent: Space.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.roundColumn(r.number), style: context.text.titleSmall),
                            if (r.dueDate != null) Text(t.date(r.dueDate!), style: context.text.bodySmall),
                          ],
                        ),
                      ),
                      AmountText(r.expected),
                      const SizedBox(width: Space.sm),
                      if (r.legacy)
                        StatusChip(t.importedRound, tone: Tone.info)
                      else if (r.state == RoundState.completed)
                        StatusChip(t.receivedLabel, tone: Tone.success, icon: AppIcons.received)
                      else if (r.number == c.currentRoundNumber)
                        StatusChip(t.roundState(r.state), tone: roundTone(r.state)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        if (canInvite) ...[
          AppButton(
            label: t.invite,
            icon: AppIcons.invite,
            onPressed: () {
              // The sheet closes first; the invitation opens from the screen under it.
              final host = Navigator.of(context).context;
              Navigator.pop(context);
              showInviteSheet(host, circle: c, member: m);
            },
          ),
          const SizedBox(height: Space.xs),
        ],
        // A request is out: say so, and allow withdrawing it (only one at a time).
        if (canInvite && m.contactId != null && m.linkPending) ...[
          InlineBanner(
            title: t.linkPendingTitle,
            body: t.linkPendingMemberBody,
            tone: Tone.pending,
            action: AppButton(
              kind: ButtonKind.danger,
              expand: false,
              icon: AppIcons.close,
              label: t.withdrawRequest,
              onPressed: () async {
                final ok = await confirmDialog(
                  context,
                  title: t.withdrawRequestTitle,
                  body: t.withdrawRequestBody(m.name),
                  confirm: t.withdrawRequest,
                  danger: true,
                );
                if (!ok || !context.mounted) return;
                final done = await runCircleAction(
                  context,
                  () async {
                    await ref.read(contactsRepositoryProvider).unlink(m.contactId!);
                    await ref.read(circleProvider(circleId).notifier).reload();
                  },
                  done: t.requestWithdrawn,
                );
                if (done && context.mounted) Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: Space.sm),
        ],
        // Link by account ID: the person accepts once, and joins every circle they are in.
        if (canInvite && m.contactId != null && !m.linkPending) ...[
          AppButton.secondary(
            label: t.linkByAccountCode,
            icon: AppIcons.link,
            onPressed: () async {
              final linked = await showLinkAccountSheet(context, contactId: m.contactId!, name: m.name);
              if (linked != null && context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: Space.xs),
        ],
        if (canReopen) ...[
          AppButton(kind: ButtonKind.danger, label: t.reopenRound(last.number), icon: AppIcons.undo, onPressed: reopen),
          const SizedBox(height: Space.xs),
        ],
        AppButton.text(label: t.close, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
