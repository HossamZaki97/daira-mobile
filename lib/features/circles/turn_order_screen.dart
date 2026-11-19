import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/circle.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../state.dart';
import 'payments.dart';

/// Organizer: move the turns that have not started yet. Received and current
/// turns stay locked; the change is reviewed before it is saved.
class TurnOrderScreen extends ConsumerWidget {
  const TurnOrderScreen({required this.circleId, super.key});
  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final circle = ref.watch(circleProvider(circleId));
    return Scaffold(
      appBar: AppBar(title: Text(t.editTurnOrder)),
      body: circle.when(
        skipLoadingOnReload: true,
        loading: () => const PageBody(children: [SkeletonList(count: 5, height: 64)]),
        error: (e, _) => LoadError(e, onRetry: () => ref.invalidate(circleProvider(circleId))),
        data: (c) => _Editor(c),
      ),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor(this.circle);
  final Circle circle;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  /// Recipient member id for each future round, in order.
  late final List<String> _order = [for (final r in widget.circle.futureRounds) r.recipientId];
  bool _busy = false;

  List<Round> get _future => widget.circle.futureRounds;

  /// (member id, from round, to round) for every turn that moved.
  List<(String, int, int)> get _changes {
    final before = <String, List<int>>{};
    final after = <String, List<int>>{};
    for (final (i, r) in _future.indexed) {
      before.putIfAbsent(r.recipientId, () => []).add(r.number);
      after.putIfAbsent(_order[i], () => []).add(r.number);
    }
    return [
      for (final id in before.keys)
        for (final (k, from) in before[id]!.indexed)
          if (after[id]![k] != from) (id, from, after[id]![k]),
    ];
  }

  Future<void> _move(int from) async {
    final t = context.l10n;
    final target = await showAppSheet<int>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.moveToRound, style: context.text.titleLarge),
          const SizedBox(height: Space.sm),
          for (final (i, r) in _future.indexed)
            if (i != from)
              ListTile(
                title: Text(t.roundColumn(r.number)),
                subtitle: r.dueDate == null ? null : Text(t.date(r.dueDate!)),
                onTap: () => Navigator.pop(context, i),
              ),
        ],
      ),
    );
    if (target == null || !mounted) return;
    setState(() => _order.insert(target, _order.removeAt(from)));
  }

  Future<void> _save() async {
    final t = context.l10n;
    final c = widget.circle;
    final changes = _changes;
    if (changes.isEmpty) {
      showToast(context, t.noChanges);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.reorderConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (member, from, to) in changes)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: Text(t.reorderChange(c.member(member)?.name ?? '', from, to), style: context.text.bodyMedium),
              ),
            const SizedBox(height: Space.sm),
            Text(t.reorderNotice, style: context.text.bodySmall),
          ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.save)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final done = await runCircleAction(context, () => ref.read(circleProvider(c.id).notifier).reorder(_order), done: t.reorderDone);
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
    final locked = [for (final r in c.rounds) if (c.currentRoundNumber == null || r.number <= c.currentRoundNumber!) r];
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.md, Space.gutter, Space.xl),
            buildDefaultDragHandles: false,
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.reorderBody, style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
                const SizedBox(height: Space.md),
                Text(t.lockedTurns, style: context.text.labelLarge),
                const SizedBox(height: Space.xs),
                for (final r in locked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: AppCard(
                      color: colors.surfaceSunken,
                      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                      child: Row(
                        children: [
                          SizedBox(width: 28, child: Text('${r.number}', style: context.text.labelLarge)),
                          Expanded(child: Text(r.recipient, style: context.text.titleSmall?.copyWith(color: colors.textMuted))),
                          Icon(AppIcons.password, size: 18, color: colors.textMuted),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: Space.sm),
                Text(t.dragHint, style: context.text.labelLarge),
                const SizedBox(height: Space.xs),
              ],
            ),
            itemCount: _order.length,
            onReorderStart: (_) => HapticFeedback.selectionClick(),
            onReorderItem: (from, to) => setState(() => _order.insert(to, _order.removeAt(from))),
            itemBuilder: (context, i) {
              final round = _future[i];
              final member = c.member(_order[i]);
              final moved = _order[i] != round.recipientId;
              // Long-press anywhere on the card, or drag the handle.
              return ReorderableDelayedDragStartListener(
                key: ValueKey('$i-${_order[i]}'),
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _move(i),
                          child: SizedBox(
                            width: 28,
                            child: Text(
                              '${round.number}',
                              style: context.text.labelLarge?.copyWith(color: moved ? colors.primary : null),
                            ),
                          ),
                        ),
                        InitialsAvatar(member?.name ?? '', size: 32),
                        const SizedBox(width: Space.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member?.name ?? '', style: context.text.titleSmall),
                              if (round.dueDate != null) Text(t.date(round.dueDate!), style: context.text.bodySmall),
                            ],
                          ),
                        ),
                        ReorderableDragStartListener(
                          index: i,
                          child: Padding(
                            padding: const EdgeInsets.all(Space.xs),
                            child: Icon(AppIcons.drag, color: colors.text, semanticLabel: t.dragToReorder),
                          ),
                        ),
                      ],
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
            child: AppButton(label: t.reviewChanges, loading: _busy, onPressed: _save),
          ),
        ),
      ],
    );
  }
}
