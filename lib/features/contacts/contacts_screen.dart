import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/repositories.dart';
import '../../core/models/contacts.dart';
import '../../core/providers.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';
import '../feed.dart';
import '../state.dart';
import 'link_sheets.dart';

/// The organizer's people: everyone they put in a circle, registered or not.
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final t = context.l10n;
    final name = await showAppSheet<String>(
      context,
      builder: (_) => NameSheet(title: t.addContact, confirm: t.add),
    );
    if (name == null || !mounted) return;
    try {
      await ref.read(contactsRepositoryProvider).create(name);
      ref.invalidate(contactsProvider);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final contacts = ref.watch(contactsProvider);
    final query = _search.text.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: Text(t.contacts),
        actions: [
          IconButton(tooltip: t.addContact, icon: const Icon(AppIcons.add), onPressed: _add),
          const SizedBox(width: Space.xxs),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => ref.refresh(contactsProvider.future),
        child: contacts.when(
          skipLoadingOnRefresh: true,
          loading: () => const PageBody(children: [SkeletonList(count: 6, height: 64)]),
          error: (e, _) => ListView(
            children: [SizedBox(height: 480, child: LoadError(e, onRetry: () => ref.invalidate(contactsProvider)))],
          ),
          data: (all) {
            final shown = [for (final c in all) if (query.isEmpty || c.name.toLowerCase().contains(query)) c];
            final registered = all.where((c) => c.registered).length;
            return PageBody(
              children: [
                if (all.isEmpty)
                  SizedBox(
                    height: 460,
                    child: MessageView(
                      icon: AppIcons.contacts,
                      title: t.noContacts,
                      body: t.noContactsBody,
                      primary: AppButton(label: t.addContact, icon: AppIcons.add, onPressed: _add),
                    ),
                  )
                else ...[
                  const SizedBox(height: Space.xs),
                  AppTextField(
                    controller: _search,
                    label: t.searchContacts,
                    icon: AppIcons.user,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: Space.sm),
                  Text(t.contactsSummary(all.length, registered), style: context.text.bodySmall),
                  const SizedBox(height: Space.xs),
                  if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(Space.xl),
                      child: Text(t.noResults, textAlign: TextAlign.center, style: context.text.bodyMedium),
                    )
                  else
                    FeedGroup(
                      children: [
                        for (final c in shown)
                          ContactRow(
                            c,
                            onTap: () => showAppSheet<void>(context, builder: (_) => ContactSheet(contactId: c.id)),
                          ),
                      ],
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// «مسجَّل» / «بانتظار الموافقة» / «غير مسجَّل», in words and color.
class ContactStatus extends StatelessWidget {
  const ContactStatus(this.contact, {super.key});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final c = contact;
    if (c.registered) return StatusChip(t.registered, tone: Tone.success, icon: AppIcons.link);
    if (c.linkPending) return StatusChip(t.linkPendingShort, tone: Tone.pending, icon: AppIcons.waiting);
    return StatusChip(t.notRegistered, tone: Tone.info);
  }
}

class ContactRow extends StatelessWidget {
  const ContactRow(this.contact, {required this.onTap, super.key});
  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final c = contact;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        child: Row(
          children: [
            InitialsAvatar(c.name, size: 40),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                  Text(
                    c.circles == 0 ? t.inNoCircle : t.inCircles(c.circles),
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.xs),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: ContactStatus(c)),
          ],
        ),
      ),
    );
  }
}

/// One contact: status, account name, commitment record, circles, and what
/// the organizer can do (link, rename, merge, unlink, delete).
class ContactSheet extends ConsumerStatefulWidget {
  const ContactSheet({required this.contactId, super.key});
  final String contactId;

  @override
  ConsumerState<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends ConsumerState<ContactSheet> {
  Contact? _contact;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await ref.read(contactsRepositoryProvider).get(widget.contactId);
      if (mounted) setState(() => _contact = c);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _do(Future<Contact?> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      final c = await action();
      refreshLists(ref.invalidate);
      if (!mounted) return;
      if (c != null) setState(() => _contact = c);
      if (done != null) showToast(context, done, tone: Tone.success);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  ContactsRepository get _repo => ref.read(contactsRepositoryProvider);

  Future<void> _rename(Contact c, [String? suggested]) async {
    final t = context.l10n;
    final name = suggested ??
        await showAppSheet<String>(
          context,
          builder: (_) => NameSheet(title: t.renameContact, confirm: t.save, initial: c.name, body: t.renameContactBody),
        );
    if (name == null || name == c.name || !mounted) return;
    await _do(() => _repo.update(c.id, name: name), done: t.nameUpdated);
  }

  Future<void> _merge(Contact c) async {
    final t = context.l10n;
    final all = await ref.read(contactsProvider.future);
    if (!mounted) return;
    final others = [for (final o in all) if (o.id != c.id) o];
    final into = await showAppSheet<Contact>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.mergeTitle(c.name), style: context.text.titleLarge),
          const SizedBox(height: Space.xs),
          Text(t.mergeBody, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
          const SizedBox(height: Space.md),
          if (others.isEmpty)
            Text(t.noContacts, style: context.text.bodyMedium)
          else
            FeedGroup(children: [for (final o in others) ContactRow(o, onTap: () => Navigator.pop(context, o))]),
        ],
      ),
    );
    if (into == null || !mounted) return;
    // Two different names: the organizer picks the one that stays.
    final keep = c.name.trim() == into.name.trim()
        ? (await confirmDialog(context, title: t.mergeConfirmTitle, body: t.mergeConfirmBody(c.name, into.name), confirm: t.merge)
              ? into.name
              : null)
        : await showAppSheet<String>(context, builder: (_) => _MergeNameSheet(first: into.name, second: c.name));
    if (keep == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final merged = await _repo.merge(c.id, into.id);
      if (keep != merged.name) await _repo.update(merged.id, name: keep);
      refreshLists(ref.invalidate);
      if (!mounted) return;
      showToast(context, t.mergedDone, tone: Tone.success);
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        showError(context, error);
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _unlink(Contact c) async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.unlinkTitle(c.name), body: t.unlinkBody, confirm: t.unlink, danger: true);
    if (ok && mounted) await _do(() => _repo.unlink(c.id), done: t.unlinkedDone);
  }

  Future<void> _delete(Contact c) async {
    final t = context.l10n;
    final ok = await confirmDialog(context, title: t.deleteContactTitle(c.name), body: t.deleteContactBody, confirm: t.delete, danger: true);
    if (!ok || !mounted) return;
    try {
      await _repo.delete(c.id);
      ref.invalidate(contactsProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final c = _contact;
    if (c == null) {
      return Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Center(
          child: _error == null ? const RingLoader() : Text(t.error(_error!), textAlign: TextAlign.center),
        ),
      );
    }
    Widget action(IconData icon, String label, VoidCallback onTap, {bool danger = false}) => NavRow(
      icon: icon,
      title: label,
      danger: danger,
      onTap: _busy ? null : onTap,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InitialsAvatar(c.name, size: 52),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: context.text.titleLarge),
                  const SizedBox(height: Space.xxs),
                  ContactStatus(c),
                ],
              ),
            ),
          ],
        ),
        if (c.nameDiffers) ...[
          const SizedBox(height: Space.md),
          InlineBanner(
            title: t.accountNameIs(c.accountName!),
            body: t.unifyNameBody,
            icon: AppIcons.user,
            action: AppButton.secondary(
              label: t.useAccountName,
              icon: AppIcons.check,
              expand: false,
              onPressed: _busy ? null : () => _rename(c, c.accountName),
            ),
          ),
        ],
        if (c.linkPending) ...[
          const SizedBox(height: Space.md),
          InlineBanner(
            title: t.linkPendingTitle,
            body: t.linkPendingMemberBody,
            tone: Tone.pending,
            action: AppButton(
              kind: ButtonKind.danger,
              expand: false,
              icon: AppIcons.close,
              label: t.withdrawRequest,
              onPressed: _busy ? null : () => _do(() => _repo.unlink(c.id), done: t.requestWithdrawn),
            ),
          ),
        ],
        const SizedBox(height: Space.md),
        // Commitment record and circles, side by side.
        Row(
          children: [
            Expanded(child: _Fact(value: '${c.onTime}', label: t.paidOnTime, color: colors.success)),
            const SizedBox(width: Space.xs),
            Expanded(child: _Fact(value: '${c.late}', label: t.paidLate, color: c.late > 0 ? colors.danger : colors.textMuted)),
            const SizedBox(width: Space.xs),
            Expanded(child: _Fact(value: '${c.circles}', label: t.circlesLabel, color: colors.text)),
          ],
        ),
        if (c.circleList.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final circle in c.circleList)
                ActionChip(
                  avatar: Icon(AppIcons.circles, size: 16, color: colors.textMuted),
                  label: Text(circle.name),
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    router.push(Routes.circle(circle.id));
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: Space.lg),
        if (!c.registered && !c.linkPending) ...[
          AppButton(
            label: t.linkToAccount,
            icon: AppIcons.link,
            onPressed: _busy
                ? null
                : () async {
                    final updated = await showLinkAccountSheet(context, contactId: c.id, name: c.name, phone: c.phone);
                    if (updated != null && mounted) setState(() => _contact = updated);
                  },
          ),
          const SizedBox(height: Space.sm),
        ],
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              action(AppIcons.edit, t.renameContact, () => _rename(c)),
              const Divider(indent: 56),
              action(AppIcons.merge, t.mergeAction, () => _merge(c)),
              if (c.registered) ...[
                const Divider(indent: 56),
                action(AppIcons.unlink, t.unlink, () => _unlink(c), danger: true),
              ],
              if (c.circles == 0) ...[
                const Divider(indent: 56),
                action(AppIcons.delete, t.delete, () => _delete(c), danger: true),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Merging two contacts with different names: which name stays (applied to every open circle).
class _MergeNameSheet extends StatefulWidget {
  const _MergeNameSheet({required this.first, required this.second});
  final String first;
  final String second;

  @override
  State<_MergeNameSheet> createState() => _MergeNameSheetState();
}

class _MergeNameSheetState extends State<_MergeNameSheet> {
  late String _keep = widget.first;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    Widget option(String name) {
      final selected = _keep == name;
      return Padding(
        padding: const EdgeInsets.only(bottom: Space.xs),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.lg),
            onTap: () => setState(() => _keep = name),
            child: AnimatedContainer(
              duration: context.reduceMotion ? Duration.zero : Motion.fast,
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: selected ? colors.primaryContainer.withValues(alpha: 0.6) : colors.surface,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(color: selected ? colors.primary : colors.line, width: selected ? 2 : 1),
              ),
              child: Row(
                children: [
                  InitialsAvatar(name, size: 36),
                  const SizedBox(width: Space.sm),
                  Expanded(child: Text(name, style: context.text.titleSmall)),
                  Icon(selected ? AppIcons.success : AppIcons.checkbox, color: selected ? colors.primary : colors.lineStrong),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.mergeKeepTitle, style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.mergeKeepBody, style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
        const SizedBox(height: Space.md),
        option(widget.first),
        option(widget.second),
        const SizedBox(height: Space.md),
        AppButton(label: t.merge, icon: AppIcons.merge, onPressed: () => Navigator.pop(context, _keep)),
        const SizedBox(height: Space.xs),
        AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: Space.sm, horizontal: Space.xs),
    decoration: BoxDecoration(color: context.colors.surfaceSunken, borderRadius: BorderRadius.circular(Radii.md)),
    child: Column(
      children: [
        Text(value, style: DairaType.amountM.copyWith(color: color)),
        Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelSmall),
      ],
    ),
  );
}

/// One name to type: new contact, rename.
class NameSheet extends StatefulWidget {
  const NameSheet({required this.title, required this.confirm, this.initial, this.body, super.key});
  final String title;
  final String confirm;
  final String? initial;
  final String? body;

  @override
  State<NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<NameSheet> {
  late final _name = TextEditingController(text: widget.initial);
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _done() {
    if (_form.currentState?.validate() ?? false) Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: context.text.titleLarge),
          if (widget.body != null) ...[
            const SizedBox(height: Space.xs),
            Text(widget.body!, style: context.text.bodyMedium?.copyWith(color: context.colors.textMuted)),
          ],
          const SizedBox(height: Space.lg),
          AppTextField(
            controller: _name,
            label: t.name,
            icon: AppIcons.user,
            maxLength: 100,
            autofocus: true,
            onSubmitted: (_) => _done(),
            validator: (v) => (v ?? '').trim().isEmpty ? t.requiredField : null,
          ),
          const SizedBox(height: Space.lg),
          AppButton(label: widget.confirm, onPressed: _done),
          const SizedBox(height: Space.xs),
          AppButton.text(label: t.cancel, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
