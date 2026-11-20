import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/activity.dart';
import '../../core/providers.dart';
import '../../core/push.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../feed.dart';
import '../state.dart';

/// In-app notifications, newest first. Opening one marks it read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _items = <AppNotification>[];
  final _read = <String>{};
  String? _cursor;
  bool _loading = false;
  bool _done = false;
  bool _loaded = false;
  Object? _error;
  final _scroll = ScrollController();

  /// Show only what still needs an answer from me.
  bool _onlyPending = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _load();
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading || (_done && !reset)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(notificationsRepositoryProvider).page(cursor: reset ? null : _cursor);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items.clear();
          _read.clear();
        }
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _done = !page.hasMore;
        _loaded = true;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isRead(AppNotification n) => n.read || _read.contains(n.id);

  Future<void> _open(AppNotification n) async {
    if (!_isRead(n)) {
      setState(() => _read.add(n.id));
      ref.read(notificationsRepositoryProvider).markRead([n.id]).then(
        (_) => ref.invalidate(unreadProvider),
        onError: (Object _) {},
      );
    }
    if (linkRequestKinds.contains(n.kind)) {
      await context.push(Routes.links);
    } else if (n.circleId != null) {
      await context.push(Routes.circle(n.circleId!));
    } else if (linkAnswerKinds.contains(n.kind)) {
      await context.push(Routes.contacts);
    }
  }

  Future<void> _readAll() async {
    try {
      await ref.read(notificationsRepositoryProvider).markRead();
      if (!mounted) return;
      setState(() => _read.addAll(_items.map((n) => n.id)));
      ref.invalidate(unreadProvider);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final anyUnread = _items.any((n) => !_isRead(n));
    final pending = [for (final n in _items) if (n.actionRequired) n];
    // New notifications arrive with the unread count (foreground refresh).
    ref.listen(unreadProvider, (previous, next) {
      final before = previous?.valueOrNull ?? 0;
      if ((next.valueOrNull ?? 0) > before && _loaded) _load(reset: true);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(t.tabNotifications),
        actions: [
          if (anyUnread) TextButton(onPressed: _readAll, child: Text(t.markAllRead)),
          const SizedBox(width: Space.xs),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async {
          ref.invalidate(unreadProvider);
          await _load(reset: true);
        },
        child: !_loaded && _error != null
            ? ListView(children: [SizedBox(height: 480, child: LoadError(_error!, onRetry: () => _load(reset: true)))])
            : !_loaded
            ? const PageBody(children: [SkeletonList(count: 6, height: 64)])
            : _items.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: 460,
                    child: MessageView(icon: AppIcons.notifications, title: t.noNotifications, body: t.noNotificationsBody),
                  ),
                ],
              )
            : PageBody(
                controller: _scroll,
                children: [
                  const SizedBox(height: Space.xs),
                  SegmentedTabs<bool>(
                    items: [(false, t.filterAll, null), (true, t.filterNeedsAction, pending.length)],
                    value: _onlyPending,
                    onChanged: (v) => setState(() => _onlyPending = v),
                  ),
                  if (_onlyPending && pending.isEmpty)
                    SizedBox(
                      height: 360,
                      child: MessageView(icon: AppIcons.success, title: t.noPendingNotifications),
                    ),
                  for (final (day, items) in groupByDay(t, _onlyPending ? pending : _items, (n) => n.at)) ...[
                    DayHeader(day),
                    FeedGroup(
                      children: [for (final n in items) _NotificationTile(n, read: _isRead(n), onTap: () => _open(n))],
                    ),
                  ],
                  if (_loading) const Padding(padding: EdgeInsets.all(Space.lg), child: Center(child: RingLoader(size: 28))),
                ],
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.n, {required this.read, required this.onTap});
  final AppNotification n;
  final bool read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final (icon, text) = describeNotification(t, n, context.localeName);
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: context.reduceMotion ? Duration.zero : Motion.standard,
          color: read ? Colors.transparent : colors.accentContainer.withValues(alpha: 0.35),
          padding: const EdgeInsets.all(Space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedIcon(icon, tone: notificationTone(n)),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (n.circle != null)
                      Text(
                        n.circle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(color: colors.textMuted),
                      ),
                    Text(
                      text,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.text,
                        fontWeight: read ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                    if (n.actionRequired && !read) ...[
                      const SizedBox(height: Space.xs),
                      StatusChip(t.needsAction, tone: Tone.pending, icon: AppIcons.waiting),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Space.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(feedTime(t, n.at), style: context.text.labelSmall),
                  if (!read) ...[
                    const SizedBox(height: Space.xs),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Good news is green, problems red, things waiting for you amber.
FeedTone notificationTone(AppNotification n) => switch (n.kind) {
  'payment_confirmed' || 'payout_received' || 'circle_completed' || 'payment_recorded' || 'receipt_recorded' ||
  'link_accepted' || 'member_joined' || 'added_to_circle' || 'circle_resumed' => FeedTone.success,
  'payment_not_received' || 'payment_overdue' || 'receipt_disputed' || 'circle_suspended' ||
  'circle_cancelled' => FeedTone.danger,
  'payment_reported' || 'ready_for_payout' || 'payout_sent' || 'payment_due_soon' || 'payment_due_today' ||
  'payment_reminder' || 'link_request' || 'join_request' || 'circle_invitation' => FeedTone.action,
  _ => FeedTone.neutral,
};

/// Sentence for a notification, written in the reader's language from its facts.
(IconData, String) describeNotification(AppLocalizations t, AppNotification n, String locale) {
  final actor = n.actor ?? '';
  final member = n.member ?? '';
  final round = n.roundNumber ?? 0;
  final amount = n.amount?.format(locale) ?? '';
  return switch (n.kind) {
    'payment_reported' => (AppIcons.pay, t.ntPaymentReported(actor, round)),
    'payment_confirmed' => (AppIcons.confirmed, t.ntPaymentConfirmed(actor, round)),
    'payment_not_received' => (AppIcons.error, t.ntPaymentNotReceived(round, n.note ?? '')),
    'ready_for_payout' => (AppIcons.payout, t.ntReadyForPayout(round, member)),
    'payout_sent' => (AppIcons.receive, t.ntPayoutSent(actor, amount)),
    'payout_received' => (AppIcons.success, t.ntPayoutReceived(actor, round)),
    'member_joined' => (AppIcons.invite, t.ntMemberJoined(actor)),
    'payment_due_soon' => (AppIcons.calendar, t.ntDueSoon(round, amount)),
    'payment_overdue' => (AppIcons.warning, t.ntOverdue(round, amount)),
    'circle_completed' => (AppIcons.confirmed, t.ntCircleCompleted),
    'circle_suspended' => (AppIcons.warning, t.ntCircleSuspended),
    'circle_resumed' => (AppIcons.refresh, t.ntCircleResumed),
    'circle_cancelled' => (AppIcons.close, t.ntCircleCancelled),
    'payment_due_today' => (AppIcons.calendar, t.ntPaymentDueToday(round, amount)),
    'payment_reminder' => (AppIcons.remind, t.ntReminder(actor, round)),
    'payment_recorded' => (AppIcons.confirmed, t.ntPaymentRecorded(actor, round)),
    'payment_undone' => (AppIcons.undo, t.ntPaymentUndone(actor, round)),
    'receipt_recorded' => (AppIcons.received, t.ntReceiptRecorded(actor, round)),
    'receipt_disputed' => (AppIcons.warning, t.ntReceiptDisputed(member, round)),
    'payout_undone' => (AppIcons.undo, t.ntPayoutUndone(round)),
    'receipt_undone' => (AppIcons.undo, t.ntReceiptUndone(round)),
    'turn_changed' => (AppIcons.reorder, t.ntTurnChanged(round)),
    'link_request' => (AppIcons.link, t.ntLinkRequest(actor, member)),
    'join_request' => (AppIcons.invite, t.ntJoinRequest(actor, member)),
    'circle_invitation' => (AppIcons.invite, t.ntCircleInvitation(actor)),
    'link_accepted' => (AppIcons.link, t.ntLinkAccepted(member)),
    'added_to_circle' => (AppIcons.circles, t.ntAddedToCircle(actor)),
    'link_declined' => (AppIcons.unlink, t.ntLinkDeclined(actor, member)),
    'link_removed' => (AppIcons.unlink, t.ntLinkRemoved(actor, member)),
    _ => (AppIcons.notifications, t.ntGeneric),
  };
}
