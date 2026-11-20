import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/circle.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../feed.dart';

/// The circle's audit trail: who did what and when. Read-only, newest first.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({required this.circleId, super.key});
  final String circleId;

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _items = <CircleEvent>[];
  String? _cursor;
  bool _loading = false;
  bool _done = false;
  Object? _error;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _more();
    });
    _more();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _more({bool reset = false}) async {
    if (_loading || (_done && !reset)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(circlesRepositoryProvider)
          .events(widget.circleId, cursor: reset ? null : _cursor);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _done = !page.hasMore;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(t.activityLog)),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => _more(reset: true),
        child: _items.isEmpty && _error != null
            ? ListView(children: [SizedBox(height: 480, child: LoadError(_error!, onRetry: () => _more(reset: true)))])
            : _items.isEmpty && _loading
            ? const PageBody(children: [SkeletonList(count: 6, height: 56)])
            : PageBody(
                controller: _scroll,
                children: [
                  if (_items.isEmpty)
                    SizedBox(height: 420, child: MessageView(icon: AppIcons.history, title: t.noActivity)),
                  for (final (day, items) in groupByDay(t, _items, (e) => e.at)) ...[
                    DayHeader(day),
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: Space.xs),
                      child: Column(
                        children: [
                          for (final (i, e) in items.indexed) _EventTile(e, first: i == 0, last: i == items.length - 1),
                        ],
                      ),
                    ),
                  ],
                  if (_loading) const Padding(padding: EdgeInsets.all(Space.lg), child: Center(child: RingLoader(size: 28))),
                ],
              ),
      ),
    );
  }
}

/// One entry on the day's timeline: tinted icon on a thin line, the sentence,
/// who and when, and the note (a reason, a comment) in a soft bubble.
class _EventTile extends StatelessWidget {
  const _EventTile(this.event, {required this.first, required this.last});
  final CircleEvent event;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final e = event;
    final (icon, text) = describeEvent(t, e);
    final note = e.note != null && !_noteInSentence.contains(e.action) ? e.note : null;
    Widget line(bool hidden) => Expanded(child: Container(width: 2, color: hidden ? Colors.transparent : colors.line));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(width: 2, height: Space.sm, color: first ? Colors.transparent : colors.line),
                  FeedIcon(icon, tone: eventTone(e), size: 36),
                  line(last),
                ],
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: context.text.bodyMedium?.copyWith(color: colors.text)),
                    const SizedBox(height: 2),
                    Text(
                      [e.byAdmin ? t.byDairaSupport : e.actor, if (e.at != null) feedTime(t, e.at)].join(' · '),
                      style: context.text.bodySmall,
                    ),
                    if (note != null) ...[
                      const SizedBox(height: Space.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                        decoration: BoxDecoration(
                          color: colors.surfaceSunken,
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(AppIcons.note, size: 16, color: colors.textMuted),
                            const SizedBox(width: Space.xs),
                            Expanded(child: Text(note, style: context.text.bodySmall?.copyWith(color: colors.text))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

FeedTone eventTone(CircleEvent e) => switch (e.action) {
  'approve' || 'record_payment' || 'collection_completed' || 'receipt' || 'receipt_recorded' || 'circle_completed' ||
  'invitation_accepted' || 'member_linked' || 'circle_resumed' => FeedTone.success,
  'reject' || 'receipt_disputed' || 'circle_suspended' || 'circle_cancelled' => FeedTone.danger,
  'report' || 'payout' || 'remind' => FeedTone.action,
  _ => FeedTone.neutral,
};

/// Events whose note is already part of the sentence (or is not for reading).
const _noteInSentence = {'remind', 'member_linked', 'member_unlinked', 'circle_saved'};

/// Icon and sentence for an audit entry.
(IconData, String) describeEvent(AppLocalizations t, CircleEvent e) {
  final round = e.roundNumber ?? 0;
  final member = e.member ?? '';
  return switch (e.action) {
    'circle_saved' when e.note == 'random_order' => (AppIcons.shuffle, t.evCircleSavedRandom),
    'circle_saved' => (AppIcons.edit, t.evCircleSaved),
    'report' => (AppIcons.pay, t.evReport(member, round)),
    'approve' => (AppIcons.confirmed, t.evApprove(member, round)),
    'reject' => (AppIcons.error, t.evReject(member, round)),
    'collection_completed' => (AppIcons.success, t.evCollectionCompleted(round)),
    'payout' => (AppIcons.payout, t.evPayout(round)),
    'receipt' => (AppIcons.receive, t.evReceipt(round)),
    'circle_completed' => (AppIcons.confirmed, t.evCircleCompleted),
    'invitation_created' => (AppIcons.ticket, t.evInvitationCreated),
    'invitation_revoked' || 'admin_invitation_revoked' => (AppIcons.close, t.evInvitationRevoked),
    'invitation_accepted' => (AppIcons.invite, t.evInvitationAccepted),
    'circle_suspended' => (AppIcons.warning, t.evCircleSuspended),
    'circle_resumed' => (AppIcons.refresh, t.evCircleResumed),
    'circle_cancelled' => (AppIcons.close, t.evCircleCancelled),
    'record_payment' => (AppIcons.confirmed, t.evRecordPayment(member, round)),
    'undo_payment' => (AppIcons.undo, t.evUndoPayment(member, round)),
    'undo_payout' => (AppIcons.undo, t.evUndoPayout(round)),
    'receipt_recorded' => (AppIcons.received, t.evReceiptRecorded(round)),
    'undo_receipt' => (AppIcons.undo, t.evUndoReceipt(round)),
    'receipt_disputed' => (AppIcons.warning, t.evReceiptDisputed(round)),
    'order_changed' => (AppIcons.reorder, t.evOrderChanged),
    'remind' => (AppIcons.remind, t.evRemind(round)),
    'reminder_settings' => (AppIcons.settings, t.evReminderSettings),
    'member_linked' => (AppIcons.link, t.evMemberLinked(e.note ?? member)),
    'member_unlinked' => (AppIcons.unlink, t.evMemberUnlinked(e.note ?? member)),
    _ => (AppIcons.info, e.action),
  };
}
