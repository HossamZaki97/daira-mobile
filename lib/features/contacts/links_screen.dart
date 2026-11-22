import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/contacts.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../feed.dart';
import '../state.dart';

/// Links of my account: requests waiting for my answer, requests I sent,
/// and the organizers who linked me (each can be undone with «هذا ليس أنا»).
class LinksScreen extends ConsumerWidget {
  const LinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final links = ref.watch(linksProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.linkRequests)),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => ref.refresh(linksProvider.future),
        child: links.when(
          skipLoadingOnRefresh: true,
          loading: () => const PageBody(children: [SkeletonList(count: 3, height: 96)]),
          error: (e, _) => ListView(
            children: [SizedBox(height: 480, child: LoadError(e, onRetry: () => ref.invalidate(linksProvider)))],
          ),
          data: (data) => PageBody(
            children: [
              if (data.requests.isEmpty && data.links.isEmpty)
                SizedBox(
                  height: 460,
                  child: MessageView(icon: AppIcons.link, title: t.noLinks, body: t.noLinksBody),
                ),
              if (data.incoming.isNotEmpty) ...[
                DayHeader(t.waitingForYou),
                for (final r in data.incoming)
                  Padding(padding: const EdgeInsets.only(bottom: Space.sm), child: _IncomingCard(r)),
              ],
              if (data.outgoing.isNotEmpty) ...[
                DayHeader(t.sentRequests),
                FeedGroup(children: [for (final r in data.outgoing) _OutgoingRow(r)]),
              ],
              if (data.links.isNotEmpty) ...[
                DayHeader(t.linkedOrganizers),
                FeedGroup(children: [for (final l in data.links) _LinkedRow(l)]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingCard extends ConsumerStatefulWidget {
  const _IncomingCard(this.request);
  final LinkRequest request;

  @override
  ConsumerState<_IncomingCard> createState() => _IncomingCardState();
}

class _IncomingCardState extends ConsumerState<_IncomingCard> {
  bool? _busy; // true = accepting, false = declining

  Future<void> _answer(bool accept) async {
    final t = context.l10n;
    setState(() => _busy = accept);
    try {
      await ref.read(contactsRepositoryProvider).answer(widget.request.id, accept: accept);
      refreshLists(ref.invalidate);
      if (mounted) showToast(context, accept ? t.linkAcceptedDone : t.linkDeclinedDone, tone: accept ? Tone.success : Tone.info);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final r = widget.request;
    final (icon, text, yes, no) = switch (r.kind) {
      'invite' => (AppIcons.invite, t.reqInvite(r.accountName ?? r.name, r.name, r.circle ?? ''), t.approve, t.reject),
      'add' => (AppIcons.circles, t.reqAdd(r.organizer, r.circle ?? '', r.name), t.joinCircle, t.reject),
      _ => (AppIcons.link, t.reqCode(r.organizer, r.name), t.yesItsMe, t.notMe),
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedIcon(icon, tone: FeedTone.action),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: context.text.bodyMedium?.copyWith(color: context.colors.text, fontWeight: FontWeight.w600)),
                    if (r.createdAt != null) Text(feedTime(t, r.createdAt), style: context.text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (r.kind == 'code' || r.kind == 'phone') ...[
            const SizedBox(height: Space.xs),
            Text(t.reqCodeHint, style: context.text.bodySmall),
          ],
          const SizedBox(height: Space.md),
          ButtonPair(
            first: AppButton(label: yes, loading: _busy == true, onPressed: _busy == false ? null : () => _answer(true)),
            second: AppButton.secondary(label: no, loading: _busy == false, onPressed: _busy == true ? null : () => _answer(false)),
          ),
        ],
      ),
    );
  }
}

class _OutgoingRow extends StatelessWidget {
  const _OutgoingRow(this.request);
  final LinkRequest request;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final r = request;
    return Padding(
      padding: const EdgeInsets.all(Space.md),
      child: Row(
        children: [
          InitialsAvatar(r.name, size: 40),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: context.text.titleSmall),
                Text(
                  [if (r.accountName != null) t.accountNameLabel(r.accountName!), feedTime(t, r.createdAt)].join(' · '),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(t.linkPendingShort, tone: Tone.pending, icon: AppIcons.waiting),
        ],
      ),
    );
  }
}

class _LinkedRow extends ConsumerWidget {
  const _LinkedRow(this.link);
  final LinkedOrganizer link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final l = link;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(Space.md, Space.sm, Space.xs, Space.sm),
      child: Row(
        children: [
          InitialsAvatar(l.organizer, size: 40),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.organizer, style: context.text.titleSmall),
                Text(t.callsYou(l.name), style: context.text.bodySmall),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: t.leaveLinkTitle(l.organizer),
                body: t.leaveLinkBody,
                confirm: t.notMe,
                danger: true,
              );
              if (!ok || !context.mounted) return;
              try {
                await ref.read(contactsRepositoryProvider).leave(l.id);
                refreshLists(ref.invalidate);
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
            child: Text(t.notMe),
          ),
        ],
      ),
    );
  }
}
