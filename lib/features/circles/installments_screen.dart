import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/circle.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../state.dart';
import 'payments.dart';

/// Every member × every round at a glance: paid, waiting, not paid, late.
class InstallmentsScreen extends ConsumerWidget {
  const InstallmentsScreen({required this.circleId, super.key});
  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final circle = ref.watch(circleProvider(circleId));
    return Scaffold(
      appBar: AppBar(title: Text(t.installmentsTable)),
      body: circle.when(
        skipLoadingOnReload: true,
        loading: () => const PageBody(children: [Skeleton.card(height: 320)]),
        error: (e, _) => LoadError(e, onRetry: () => ref.invalidate(circleProvider(circleId))),
        data: (c) => _Table(c),
      ),
    );
  }
}

const _rowHeight = 52.0;
const _cellWidth = 56.0;
const _nameWidth = 132.0;

class _Table extends StatelessWidget {
  const _Table(this.circle);
  final Circle circle;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final c = circle;
    final rounds = c.rounds;
    final members = c.members;

    Obligation? find(Round r, Member m) {
      for (final o in r.obligations) {
        if (o.memberId == m.id) return o;
      }
      return null;
    }

    Widget header(String text, {bool current = false}) => Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        text,
        style: context.text.labelMedium?.copyWith(color: current ? colors.primary : colors.textMuted),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.sm, Space.gutter, Space.xxl),
      children: [
        Wrap(
          spacing: Space.md,
          runSpacing: Space.xs,
          children: [
            _Legend(color: colors.success, label: t.obligationApproved),
            _Legend(color: colors.pending, label: t.obligationReported),
            _Legend(color: colors.skeleton, label: t.obligationPending),
            _Legend(color: colors.danger, label: t.obligationOverdue),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(t.tableLegend, style: context.text.bodySmall),
        const SizedBox(height: Space.md),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Names stay in place while the rounds scroll sideways.
              SizedBox(
                width: _nameWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    for (final m in members)
                      SizedBox(
                        height: _rowHeight,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: Space.sm),
                          child: Row(
                            children: [
                              InitialsAvatar(m.name, size: 28, highlight: m.id == c.actorMemberId),
                              const SizedBox(width: Space.xs),
                              Expanded(
                                child: Text(m.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final r in rounds)
                            SizedBox(width: _cellWidth, child: header('${r.number}', current: r.number == c.currentRoundNumber)),
                        ],
                      ),
                      for (final m in members)
                        SizedBox(
                          height: _rowHeight,
                          child: Row(
                            children: [
                              for (final r in rounds)
                                SizedBox(
                                  width: _cellWidth,
                                  child: _Cell(circle: c, round: r, member: m, obligation: find(r, m)),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: Space.xxs),
      Text(label, style: context.text.bodySmall),
    ],
  );
}

class _Cell extends ConsumerWidget {
  const _Cell({required this.circle, required this.round, required this.member, required this.obligation});
  final Circle circle;
  final Round round;
  final Member member;
  final Obligation? obligation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final o = obligation;
    final receives = round.recipientId == member.id;
    final color = o == null
        ? colors.surfaceSunken
        : switch (o.state) {
            ObligationState.approved => colors.success,
            ObligationState.reported => colors.pending,
            ObligationState.pending => o.overdue ? colors.danger : colors.skeleton,
          };
    return InkResponse(
      onTap: o == null || o.historical ? null : () => _open(context, ref, o),
      radius: 24,
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            // The member who receives this round gets a ring around their box.
            border: receives ? Border.all(color: colors.accent, width: 2.5) : null,
          ),
          child: o?.state == ObligationState.approved ? Icon(AppIcons.check, size: 14, color: colors.surface) : null,
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Obligation o) async {
    final t = context.l10n;
    final open = round.state == RoundState.collecting || round.state == RoundState.readyForPayout;
    if (o.state == ObligationState.approved) {
      await showAppSheet<void>(
        context,
        builder: (_) => PaymentDetailsSheet(circleId: circle.id, obligation: o, canUndo: circle.isOrganizer && open),
      );
      return;
    }
    if (!circle.isOrganizer || !open || circle.status != CircleStatus.active) {
      showToast(context, '${o.member} · ${t.roundColumn(round.number)} · ${t.obligation(o.state, overdue: o.overdue)}');
      return;
    }
    final choice = await showAppSheet<RecordChoice>(
      context,
      builder: (_) => RecordSheet(title: t.recordTitle(o.member), amount: o.amount),
    );
    if (choice == null || !context.mounted) return;
    await runCircleAction(
      context,
      () => ref.read(circleProvider(circle.id).notifier).recordPayments([o], method: choice.method, note: choice.note),
      done: t.recordedDone,
    );
  }
}
