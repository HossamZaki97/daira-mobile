import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/router.dart';
import '../../core/data/repositories.dart';
import '../../core/models/circle.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../state.dart';

/// All my circles, split into active, drafts and finished.
class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.tabCircles),
          actions: [
            IconButton(tooltip: t.joinWithCode, icon: const Icon(AppIcons.ticket), onPressed: () => context.push(Routes.join())),
            const SizedBox(width: Space.xxs),
          ],
          bottom: TabBar(
            tabs: [Tab(text: t.filterActive), Tab(text: t.filterDrafts), Tab(text: t.filterCompleted)],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(Routes.newCircle),
          icon: const Icon(AppIcons.add),
          label: Text(t.createCircle),
        ),
        body: const TabBarView(
          children: [
            _CircleList(CircleFilter.active),
            _CircleList(CircleFilter.draft),
            _CircleList(CircleFilter.completed),
          ],
        ),
      ),
    );
  }
}

class _CircleList extends ConsumerWidget {
  const _CircleList(this.filter);
  final CircleFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final circles = ref.watch(circlesProvider(filter));
    return RefreshIndicator(
      color: context.colors.primary,
      onRefresh: () => ref.refresh(circlesProvider(filter).future),
      child: circles.when(
        loading: () => const PageBody(padding: EdgeInsets.all(Space.gutter), children: [SkeletonList(count: 4, height: 120)]),
        error: (e, _) => ListView(
          children: [SizedBox(height: 480, child: LoadError(e, onRetry: () => ref.invalidate(circlesProvider(filter))))],
        ),
        data: (items) => items.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: 460,
                    child: MessageView(
                      icon: filter == CircleFilter.draft ? AppIcons.edit : AppIcons.circles,
                      title: switch (filter) {
                        CircleFilter.active => t.emptyCirclesTitle,
                        CircleFilter.draft => t.noDrafts,
                        CircleFilter.completed => t.noCompleted,
                      },
                      body: filter == CircleFilter.active ? t.emptyCirclesBody : null,
                    ),
                  ),
                ],
              )
            : PageBody(
                padding: const EdgeInsets.fromLTRB(Space.gutter, Space.md, Space.gutter, 96),
                children: [
                  for (final c in items)
                    Padding(padding: const EdgeInsets.only(bottom: Space.sm), child: CircleCard(c)),
                ],
              ),
      ),
    );
  }
}

class CircleCard extends StatelessWidget {
  const CircleCard(this.circle, {super.key});
  final CircleSummary circle;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final c = circle;
    final draft = c.status == CircleStatus.draft;
    final running = c.status == CircleStatus.active || c.status == CircleStatus.suspended;
    final mine = c.myObligationState;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(Space.md, Space.sm + 2, Space.md, Space.sm + 2),
      onTap: () => context.push(draft && c.isOrganizer ? Routes.editDraft(c.id) : Routes.circle(c.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name, and the person's role in words (not an unexplained crown).
          Row(
            children: [
              Expanded(child: Text(c.name, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (c.status != CircleStatus.active)
                CircleStatusChip(c.status)
              else if (c.isOrganizer)
                StatusChip(t.youOrganize, tone: Tone.info, icon: AppIcons.organizer),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              AmountText(c.installment),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  cadenceLabel(t, c.cadence, c.interval),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall,
                ),
              ),
              // My installment this round, in plain words, in the corner.
              if (running && mine != null) MyPaymentChip(mine),
            ],
          ),
          if (running && c.currentRound != null) ...[
            const SizedBox(height: Space.sm),
            RoundsTrack(total: c.totalRounds, current: c.currentRound!, mine: c.myNextTurn),
            const SizedBox(height: Space.xs),
            Row(
              children: [
                Expanded(child: Text(t.roundOf(c.currentRound!, c.totalRounds), style: context.text.bodySmall)),
                if (c.myNextTurn != null) ...[
                  Icon(AppIcons.receive, size: 14, color: colors.textMuted),
                  const SizedBox(width: Space.xxs),
                  Text(
                    c.myNextTurn == c.currentRound
                        ? t.yourTurnTag
                        : [t.myTurnRound(c.myNextTurn!), if (c.myNextTurnDate != null) DateFormat.MMMd(t.localeName).format(c.myNextTurnDate!)]
                            .join(' · '),
                    style: context.text.labelSmall?.copyWith(color: colors.text),
                  ),
                ],
              ],
            ),
          ] else if (draft) ...[
            const SizedBox(height: Space.xxs),
            Text(t.draftHint, style: context.text.bodySmall),
          ],
        ],
      ),
    );
  }
}
