import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/activity.dart';
import '../../core/models/circle.dart';
import '../../core/models/contacts.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../feed.dart';
import '../startup/gate_screens.dart';
import '../state.dart';

/// "What do I need to do now?" — actions first, then my next turn, then what is coming.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final name = ref.watch(sessionProvider)?.profile.name ?? '';
    final home = ref.watch(homeProvider);
    final first = name.trim().split(RegExp(r'\s+')).first;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const DairaMark(size: 28),
            const SizedBox(width: Space.sm),
            Flexible(child: Text(t.hello(first), overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(tooltip: t.joinWithCode, icon: const Icon(AppIcons.ticket), onPressed: () => context.push(Routes.join())),
          IconButton(tooltip: t.createCircle, icon: const Icon(AppIcons.add), onPressed: () => context.push(Routes.newCircle)),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async {
          refreshLists(ref.invalidate);
          await ref.read(homeProvider.future);
        },
        child: home.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => const PageBody(children: [Skeleton.card(height: 150), SizedBox(height: Space.xl), SkeletonList()]),
          error: (e, _) => ListView(
            children: [
              SizedBox(
                height: 480,
                child: ErrorView(
                  title: t.unavailableTitle,
                  message: t.error(e),
                  retryLabel: t.retry,
                  offline: e is ApiException && e.isOffline,
                  onRetry: () => ref.invalidate(homeProvider),
                ),
              ),
            ],
          ),
          data: (data) => _HomeBody(data),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody(this.data);
  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    // Link and join requests waiting for my answer are "things to do" too.
    final requests = ref.watch(linksProvider).valueOrNull?.incoming ?? const <LinkRequest>[];
    final turn = data.nextTurn;
    final empty = data.activeCircles == 0 && data.actions.isEmpty && requests.isEmpty;
    final asked = {for (final a in data.actions) '${a.circleId}#${a.roundNumber}'};
    final later = [for (final u in data.upcoming) if (!asked.contains('${u.circleId}#${u.roundNumber}')) u];
    return PageBody(
      children: [
        const UpdateOfferBanner(),
        const AnnouncementBanners(),
        if (empty)
          SizedBox(
            height: 460,
            child: MessageView(
              showMark: true,
              title: t.emptyCirclesTitle,
              body: t.emptyCirclesBody,
              primary: AppButton(label: t.createCircle, icon: AppIcons.add, onPressed: () => context.push(Routes.newCircle)),
              secondary: AppButton.secondary(
                label: t.joinWithCode,
                icon: AppIcons.ticket,
                onPressed: () => context.push(Routes.join()),
              ),
            ),
          )
        else ...[
          if (turn != null) _NextTurnCard(turn),
          SectionHeader(t.needsYou),
          if (data.actions.isEmpty && requests.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
              child: Row(
                children: [
                  const FeedIcon(AppIcons.success, tone: FeedTone.success, size: 36),
                  const SizedBox(width: Space.sm),
                  Expanded(child: Text(t.nothingNeeded, style: context.text.bodyMedium)),
                ],
              ),
            )
          else
            FeedGroup(
              children: [
                for (final r in requests) _RequestRow(r),
                for (final action in data.actions) _ActionRow(action),
              ],
            ),
          // Only what is not already asked above, so nothing appears twice.
          if (later.isNotEmpty) ...[
            SectionHeader(t.upcomingPayments),
            FeedGroup(children: [for (final item in later) _UpcomingRow(item)]),
          ],
        ],
      ],
    );
  }
}

/// My next payout on navy: how much, when, and where it sits among the rounds.
class _NextTurnCard extends StatelessWidget {
  const _NextTurnCard(this.turn);
  final NextTurn turn;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final muted = context.text.bodySmall?.copyWith(color: colors.onHeroMuted);
    final current = (turn.roundNumber - turn.roundsBefore).clamp(1, turn.totalRounds);
    final when = turn.roundsBefore == 0 ? t.turnIsNow : t.turnInRounds(turn.roundsBefore);
    return HeroCard(
      onTap: () => context.push(Routes.circle(turn.circleId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(t.nextPayoutLabel, style: muted)),
              const SizedBox(width: Space.xs),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.onHero.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Text(
                    turn.circle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium?.copyWith(color: colors.onHero),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          AmountText(turn.amount, large: true, color: colors.onHero),
          Text(
            [when, if (turn.dueDate != null) t.date(turn.dueDate!)].join(' · '),
            style: context.text.titleSmall?.copyWith(color: colors.accent),
          ),
          const SizedBox(height: Space.md),
          RoundsTrack(total: turn.totalRounds, current: current, mine: turn.roundNumber, onHero: true),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Expanded(child: Text(t.roundOf(current, turn.totalRounds), style: muted)),
              if (turn.roundsBefore > 0) Text(t.myTurnRound(turn.roundNumber), style: muted),
            ],
          ),
        ],
      ),
    );
  }
}

/// One thing to do: what, where, until when — and the amount at the end.
class _ActionRow extends StatelessWidget {
  const _ActionRow(this.action);
  final HomeAction action;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final (icon, title) = switch (action.type) {
      HomeActionType.pay => (AppIcons.pay, t.actionPayTitle),
      HomeActionType.receipt => (AppIcons.receive, t.actionReceiptTitle),
      HomeActionType.confirm => (AppIcons.confirmed, t.actionConfirmTitle(action.count)),
      HomeActionType.payout => (AppIcons.payout, t.actionPayoutTitle(action.recipient ?? '')),
    };
    final due = action.dueDate;
    final late = due != null && daysUntil(due) < 0 && action.type == HomeActionType.pay;
    final today = due != null && daysUntil(due) == 0;
    return InkWell(
      onTap: () => context.push(Routes.circle(action.circleId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FeedIcon(icon, tone: late ? FeedTone.danger : FeedTone.action),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The circle first: the same action («ادفع قسطك») repeats across circles.
                      Text(action.circle, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: title),
                            if (due != null && action.type == HomeActionType.pay)
                              TextSpan(
                                text: ' · ${dueLabel(t, due)}',
                                style: TextStyle(
                                  color: late ? colors.danger : (today ? colors.text : null),
                                  fontWeight: late || today ? FontWeight.w600 : null,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.xs),
                if (action.type != HomeActionType.confirm) AmountText(action.amount),
                const SizedBox(width: Space.xxs),
                DirectionalIcon(AppIcons.forward, size: 16, color: colors.textDisabled),
              ],
            ),
            if (action.rejectedReason != null) ...[
              const SizedBox(height: Space.sm),
              InlineBanner(title: t.notReceivedReason(action.rejectedReason!), tone: Tone.danger),
            ],
          ],
        ),
      ),
    );
  }
}

/// A link or join request waiting for my answer; answered on the requests page.
class _RequestRow extends StatelessWidget {
  const _RequestRow(this.request);
  final LinkRequest request;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final r = request;
    final (icon, text) = switch (r.kind) {
      'invite' => (AppIcons.invite, t.reqInvite(r.accountName ?? r.name, r.name, r.circle ?? '')),
      'add' => (AppIcons.circles, t.reqAdd(r.organizer, r.circle ?? '', r.name)),
      _ => (AppIcons.link, t.reqCode(r.organizer, r.name)),
    };
    return InkWell(
      onTap: () => context.push(Routes.links),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm + 2),
        child: Row(
          children: [
            FeedIcon(icon, tone: FeedTone.action),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.linkRequestTitle, style: context.text.titleSmall),
                  Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: Space.xs),
            DirectionalIcon(AppIcons.forward, size: 16, color: context.colors.textDisabled),
          ],
        ),
      ),
    );
  }
}

/// A payment coming later: circle, round and when; the state only when it says something.
class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow(this.item);
  final UpcomingPayment item;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return InkWell(
      onTap: () => context.push(Routes.circle(item.circleId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm + 2),
        child: Row(
          children: [
            const FeedIcon(AppIcons.calendar, size: 40),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.circle, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                  Text(
                    [t.roundNumber(item.roundNumber), if (item.dueDate != null) dueLabel(t, item.dueDate!)].join(' · '),
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(item.amount),
                if (item.state != ObligationState.pending) ...[
                  const SizedBox(height: 2),
                  MyPaymentChip(item.state),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
