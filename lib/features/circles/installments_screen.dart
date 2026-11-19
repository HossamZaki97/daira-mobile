import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

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

const _rowHeight = 56.0;
const _headerHeight = 60.0;
const _footerHeight = 40.0;
const _cellWidth = 58.0;
const _nameWidth = 128.0;

Obligation? _find(Round r, Member m) {
  for (final o in r.obligations) {
    if (o.memberId == m.id) return o;
  }
  return null;
}

class _Table extends StatefulWidget {
  const _Table(this.circle);
  final Circle circle;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Open on the current round, with one finished round still visible before it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = widget.circle.currentRoundNumber;
      if (current == null || !_scroll.hasClients) return;
      final target = ((current - 2) * _cellWidth).clamp(0.0, _scroll.position.maxScrollExtent);
      _scroll.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final c = widget.circle;
    final rounds = c.rounds;
    final members = c.members;
    final dayMonth = DateFormat.MMMd(t.localeName);

    Color? stripe(int i) => i.isOdd ? colors.surfaceSunken.withValues(alpha: 0.45) : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.sm, Space.gutter, Space.xxl),
      children: [
        const _Legend(),
        const SizedBox(height: Space.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Names stay in place while the rounds scroll sideways.
              Container(
                width: _nameWidth,
                decoration: BoxDecoration(
                  border: BorderDirectional(end: BorderSide(color: colors.line)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: _headerHeight,
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsetsDirectional.only(start: Space.sm),
                      child: Text(t.tableMember, style: context.text.labelSmall),
                    ),
                    for (final (i, m) in members.indexed)
                      Container(
                        height: _rowHeight,
                        color: stripe(i),
                        padding: const EdgeInsetsDirectional.only(start: Space.sm, end: Space.xs),
                        child: Row(
                          children: [
                            InitialsAvatar(m.name, size: 28, highlight: m.id == c.actorMemberId),
                            const SizedBox(width: Space.xs),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.labelMedium,
                                  ),
                                  Text(
                                    t.paidRatio(
                                      rounds.where((r) => _find(r, m)?.state == ObligationState.approved).length,
                                      rounds.where((r) => _find(r, m) != null).length,
                                    ),
                                    style: context.text.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      height: _footerHeight,
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsetsDirectional.only(start: Space.sm),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.line))),
                      child: Text(t.tablePaid, style: context.text.labelSmall),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final r in rounds)
                        _Column(
                          circle: c,
                          round: r,
                          current: r.number == c.currentRoundNumber && c.status == CircleStatus.active,
                          date: r.dueDate == null ? null : dayMonth.format(r.dueDate!),
                          stripe: stripe,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        Text(t.tableLegend, style: context.text.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

/// One round: header pill with its date, a cell per member, and how many paid.
/// The current round is tinted from top to bottom.
class _Column extends StatelessWidget {
  const _Column({required this.circle, required this.round, required this.current, required this.date, required this.stripe});
  final Circle circle;
  final Round round;
  final bool current;
  final String? date;
  final Color? Function(int) stripe;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final r = round;
    final done = r.state == RoundState.completed;
    return Container(
      width: _cellWidth,
      color: current ? colors.accentContainer.withValues(alpha: 0.6) : null,
      child: Column(
        children: [
          SizedBox(
            height: _headerHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: current ? colors.accent : (done ? colors.successContainer : colors.surfaceSunken),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Text(
                    '${r.number}',
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: DairaType.numeric.fontFeatures,
                      color: current ? colors.onAccent : (done ? colors.success : colors.text),
                    ),
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(date!, maxLines: 1, style: context.text.labelSmall?.copyWith(fontSize: 10)),
                ],
              ],
            ),
          ),
          for (final (i, m) in circle.members.indexed)
            Container(
              height: _rowHeight,
              color: current ? null : stripe(i),
              alignment: Alignment.center,
              child: _Cell(circle: circle, round: r, member: m, obligation: _find(r, m)),
            ),
          Container(
            height: _footerHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.line))),
            child: Text(
              r.legacy ? '—' : '${r.paidCount}/${r.obligations.length}',
              style: context.text.labelSmall?.copyWith(
                color: r.obligations.isNotEmpty && r.paidCount == r.obligations.length ? colors.success : colors.textMuted,
                fontFeatures: DairaType.numeric.fontFeatures,
              ),
              semanticsLabel: t.paidOf(r.paidCount, r.obligations.length),
            ),
          ),
        ],
      ),
    );
  }
}

/// The look of one installment state, shared by the cells and the legend.
class _CellStyle {
  const _CellStyle(this.fill, this.border, this.icon, this.iconColor);
  final Color fill;
  final Color? border;
  final IconData? icon;
  final Color? iconColor;

  static _CellStyle of(DairaColors colors, ObligationState state, {bool overdue = false}) => switch (state) {
    ObligationState.approved => _CellStyle(colors.success, null, AppIcons.check, colors.surface),
    ObligationState.reported => _CellStyle(colors.pendingContainer, colors.pending.withValues(alpha: 0.5), AppIcons.waiting, colors.pending),
    ObligationState.pending when overdue => _CellStyle(colors.dangerContainer, colors.danger.withValues(alpha: 0.6), AppIcons.warning, colors.danger),
    ObligationState.pending => _CellStyle(colors.surface, colors.lineStrong, null, null),
  };
}

class _Box extends StatelessWidget {
  const _Box(this.style, {this.recipient = false, this.size = 30});
  final _CellStyle style;
  final bool recipient;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.fill,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: style.border == null ? null : Border.all(color: style.border!, width: 1.5),
      ),
      child: style.icon == null ? null : Icon(style.icon, size: size * 0.5, color: style.iconColor),
    );
    if (!recipient) return box;
    // The member who receives this round: an amber ring around their box.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3 + 3),
        border: Border.all(color: colors.accent, width: 2),
      ),
      child: box,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    Widget item(Widget sample, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [sample, const SizedBox(width: Space.xs), Text(label, style: context.text.bodySmall)],
    );
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.sm,
      children: [
        item(_Box(_CellStyle.of(colors, ObligationState.approved), size: 20), t.obligationApproved),
        item(_Box(_CellStyle.of(colors, ObligationState.reported), size: 20), t.obligationReported),
        item(_Box(_CellStyle.of(colors, ObligationState.pending), size: 20), t.obligationPending),
        item(_Box(_CellStyle.of(colors, ObligationState.pending, overdue: true), size: 20), t.obligationOverdue),
        item(_Box(_CellStyle.of(colors, ObligationState.pending), size: 16, recipient: true), t.tableRecipient),
      ],
    );
  }
}

class _Cell extends ConsumerWidget {
  const _Cell({required this.circle, required this.round, required this.member, required this.obligation});
  final Circle circle;
  final Round round;
  final Member member;
  final Obligation? obligation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final colors = context.colors;
    final o = obligation;
    final receives = round.recipientId == member.id;
    if (o == null) {
      return receives
          ? _Box(_CellStyle(colors.surfaceSunken, null, null, null), recipient: true)
          : Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.lineStrong, shape: BoxShape.circle));
    }
    return Semantics(
      button: !o.historical,
      label: '${member.name} · ${t.roundColumn(round.number)} · ${t.obligation(o.state, overdue: o.overdue)}',
      child: InkResponse(
        onTap: o.historical ? null : () => _open(context, ref, o),
        radius: 26,
        child: _Box(_CellStyle.of(colors, o.state, overdue: o.overdue), recipient: receives),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Obligation o) async {
    final t = context.l10n;
    final open = round.state == RoundState.collecting || round.state == RoundState.readyForPayout;
    final active = circle.status == CircleStatus.active;
    if (o.state == ObligationState.approved) {
      await showAppSheet<void>(
        context,
        builder: (_) => PaymentDetailsSheet(circleId: circle.id, obligation: o, canUndo: circle.isOrganizer && active && open),
      );
      return;
    }
    if (!circle.isOrganizer || !open || !active) {
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
