import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/circle.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../state.dart';
import 'payments.dart';

/// Organizer: move every turn that has not been handed over yet (the current
/// one included while it is still collecting). The change is reviewed before
/// it is saved.
class TurnOrderScreen extends ConsumerWidget {
  const TurnOrderScreen({required this.circleId, super.key});
  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(circleProvider(circleId));
    return circle.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        appBar: AppBar(title: Text(context.l10n.editTurnOrder)),
        body: const PageBody(children: [SkeletonList(count: 5, height: 64)]),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.editTurnOrder)),
        body: LoadError(e, onRetry: () => ref.invalidate(circleProvider(circleId))),
      ),
      data: (c) => _Editor(c),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor(this.circle);
  final Circle circle;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

/// One turn that moved: who, from which round to which.
typedef _Change = ({String member, Round from, Round to});

class _EditorState extends ConsumerState<_Editor> {
  /// Recipient member id for each movable round, in order.
  late List<String> _order = _initial;
  bool _busy = false;

  List<Round> get _movable => widget.circle.futureRounds;
  List<String> get _initial => [for (final r in _movable) r.recipientId];

  List<_Change> get _changes {
    final before = <String, List<Round>>{};
    final after = <String, List<Round>>{};
    for (final (i, r) in _movable.indexed) {
      before.putIfAbsent(r.recipientId, () => []).add(r);
      after.putIfAbsent(_order[i], () => []).add(r);
    }
    return [
      for (final id in before.keys)
        for (final (k, from) in before[id]!.indexed)
          if (after[id]![k].number != from.number) (member: id, from: from, to: after[id]![k]),
    ];
  }

  /// The round this member had before any change (for «كان الدور 3»).
  int? _was(int index) {
    final id = _order[index];
    if (id == _movable[index].recipientId) return null;
    final k = [for (var i = 0; i < index; i++) if (_order[i] == id) i].length;
    final rounds = [for (final r in _movable) if (r.recipientId == id) r.number];
    return k < rounds.length ? rounds[k] : null;
  }

  Future<void> _moveTo(int from) async {
    final t = context.l10n;
    final c = widget.circle;
    final target = await showAppSheet<int>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.moveMemberTo(c.member(_order[from])?.name ?? ''), style: context.text.titleLarge),
          const SizedBox(height: Space.sm),
          for (final (i, r) in _movable.indexed)
            if (i != from)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _Number(r.number),
                title: Text(t.roundColumn(r.number)),
                subtitle: Text([if (r.dueDate != null) t.date(r.dueDate!), c.member(_order[i])?.name ?? ''].join(' · ')),
                onTap: () => Navigator.pop(context, i),
              ),
        ],
      ),
    );
    if (target == null || !mounted) return;
    HapticFeedback.selectionClick();
    setState(() => _order.insert(target, _order.removeAt(from)));
  }

  Future<void> _review() async {
    final changes = _changes;
    if (changes.isEmpty) return;
    final ok = await showAppSheet<bool>(context, builder: (_) => _ReviewSheet(circle: widget.circle, changes: changes));
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final t = context.l10n;
    final done = await runCircleAction(
      context,
      () => ref.read(circleProvider(widget.circle.id).notifier).reorder(_order),
      done: t.reorderDone,
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
    final colors = context.colors;
    final c = widget.circle;
    final movable = {for (final r in _movable) r.number};
    final locked = [for (final r in c.rounds) if (!movable.contains(r.number)) r];
    final changed = _changes.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.editTurnOrder),
        actions: [
          if (changed > 0)
            TextButton(
              onPressed: _busy ? null : () => setState(() => _order = _initial),
              child: Text(t.resetChanges),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(Space.gutter, Space.sm, Space.gutter, Space.xl),
              buildDefaultDragHandles: false,
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
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InlineBanner(title: t.reorderBody, body: t.reorderHowTo, icon: AppIcons.reorder),
                  if (locked.isNotEmpty) ...[
                    const SizedBox(height: Space.lg),
                    Text(t.lockedTurns, style: context.text.labelLarge?.copyWith(color: colors.textMuted)),
                    const SizedBox(height: Space.xs),
                    for (final r in locked)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.xs),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                          decoration: BoxDecoration(
                            color: colors.surfaceSunken,
                            borderRadius: BorderRadius.circular(Radii.lg),
                          ),
                          child: Row(
                            children: [
                              _Number(r.number, muted: true),
                              const SizedBox(width: Space.sm),
                              Expanded(
                                child: Text(r.recipient, style: context.text.titleSmall?.copyWith(color: colors.textMuted)),
                              ),
                              if (r.state == RoundState.completed)
                                StatusChip(t.receivedLabel, tone: Tone.success, icon: AppIcons.received)
                              else
                                StatusChip(t.roundState(r.state), tone: roundTone(r.state)),
                            ],
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: Space.lg),
                  Text(t.movableTurns, style: context.text.labelLarge),
                  const SizedBox(height: Space.xs),
                ],
              ),
              itemCount: _order.length,
              onReorderStart: (_) => HapticFeedback.mediumImpact(),
              onReorderItem: (from, to) => setState(() => _order.insert(to, _order.removeAt(from))),
              itemBuilder: (context, i) {
                final round = _movable[i];
                final member = c.member(_order[i]);
                final was = _was(i);
                final current = round.number == c.currentRoundNumber;
                // A member with two shares appears twice: the key follows each occurrence.
                final occurrence = [for (var k = 0; k < i; k++) if (_order[k] == _order[i]) k].length;
                return ReorderableDelayedDragStartListener(
                  key: ValueKey('${_order[i]}#$occurrence'),
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: AnimatedContainer(
                      duration: context.reduceMotion ? Duration.zero : Motion.standard,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: Border.all(color: was != null ? colors.accent : colors.line, width: was != null ? 1.5 : 1),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(Radii.lg),
                          onTap: () => _moveTo(i),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(Space.md, Space.sm, Space.xxs, Space.sm),
                            child: Row(
                              children: [
                                _Number(round.number),
                                const SizedBox(width: Space.sm),
                                InitialsAvatar(member?.name ?? '', size: 32),
                                const SizedBox(width: Space.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(member?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                                      Text(
                                        [
                                          if (round.dueDate != null) t.date(round.dueDate!),
                                          if (was != null) t.wasRound(was) else if (current) t.currentRoundTag,
                                        ].join(' · '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.bodySmall?.copyWith(color: was != null ? colors.text : null),
                                      ),
                                    ],
                                  ),
                                ),
                                // Subtle handle: drag it right away, or long-press anywhere on the card.
                                ReorderableDragStartListener(
                                  index: i,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    child: Icon(AppIcons.reorder, size: 20, color: colors.textMuted, semanticLabel: t.dragToReorder),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.gutter, Space.xs, Space.gutter, Space.md),
              child: AppButton(
                label: changed == 0 ? t.noChangesYet : t.reviewChangesCount(changed),
                icon: changed == 0 ? null : AppIcons.check,
                loading: _busy,
                onPressed: changed == 0 ? null : _review,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number(this.number, {this.muted = false});
  final int number;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: muted ? colors.surface : colors.primaryContainer, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: context.text.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontFeatures: DairaType.numeric.fontFeatures,
          color: muted ? colors.textMuted : colors.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Before saving: every member whose turn moves, old round crossed out → new
/// round and its date.
class _ReviewSheet extends StatelessWidget {
  const _ReviewSheet({required this.circle, required this.changes});
  final Circle circle;
  final List<_Change> changes;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.reorderConfirmTitle, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.reorderReviewBody(changes.length), style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
        const SizedBox(height: Space.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, ch) in changes.indexed) ...[
                if (i > 0) const Divider(height: 1, indent: Space.md, endIndent: Space.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                  child: Row(
                    children: [
                      InitialsAvatar(circle.member(ch.member)?.name ?? '', size: 32),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          circle.member(ch.member)?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall,
                        ),
                      ),
                      const SizedBox(width: Space.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.roundColumn(ch.from.number),
                                style: context.text.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: colors.textMuted,
                                ),
                              ),
                              const SizedBox(width: Space.xxs),
                              DirectionalIcon(AppIcons.arrowForward, size: 14, color: colors.textMuted),
                              const SizedBox(width: Space.xxs),
                              Text(
                                t.roundColumn(ch.to.number),
                                style: context.text.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          if (ch.to.dueDate != null) Text(t.date(ch.to.dueDate!), style: context.text.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            Icon(AppIcons.notifications, size: 16, color: colors.textMuted),
            const SizedBox(width: Space.xxs + 2),
            Expanded(child: Text(t.reorderNotice, style: context.text.bodySmall)),
          ],
        ),
        const SizedBox(height: Space.lg),
        AppButton(label: t.saveOrder, icon: AppIcons.check, onPressed: () => Navigator.pop(context, true)),
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context, false)),
      ],
    );
  }
}
