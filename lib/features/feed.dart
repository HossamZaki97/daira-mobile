import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../design/design.dart';
import '../l10n/messages.dart';
import 'common.dart';

/// How an entry in a feed looks: calm, good news, needs attention, or a
/// problem. «Action» uses the amber accent, the only place it means "your move".
enum FeedTone { neutral, success, action, danger }

extension FeedToneColors on FeedTone {
  (Color background, Color foreground) colors(DairaColors c) => switch (this) {
    FeedTone.neutral => (c.surfaceSunken, c.textMuted),
    FeedTone.success => (c.successContainer, c.success),
    FeedTone.action => (c.accentContainer, c.onPrimaryContainer),
    FeedTone.danger => (c.dangerContainer, c.danger),
  };
}

/// Round tinted icon at the start of a feed entry.
class FeedIcon extends StatelessWidget {
  const FeedIcon(this.icon, {this.tone = FeedTone.neutral, this.size = 40, super.key});
  final IconData icon;
  final FeedTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = tone.colors(context.colors);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.5, color: fg),
    );
  }
}

/// Items split by calendar day, newest first: «اليوم», «أمس», then the date.
List<(String, List<T>)> groupByDay<T>(AppLocalizations t, List<T> items, DateTime? Function(T) at) {
  final groups = <(String, List<T>)>[];
  String? last;
  for (final item in items) {
    final label = dayLabel(t, at(item));
    if (label != last) {
      groups.add((label, <T>[]));
      last = label;
    }
    groups.last.$2.add(item);
  }
  return groups;
}

String dayLabel(AppLocalizations t, DateTime? value) {
  if (value == null) return '';
  final local = value.isUtc ? value.toLocal() : value;
  final days = -daysUntil(local);
  if (days == 0) return t.dateToday;
  if (days == 1) return t.dayYesterday;
  final now = DateTime.now();
  return (local.year == now.year ? DateFormat.MMMMEEEEd(t.localeName) : DateFormat.yMMMMEEEEd(t.localeName)).format(local);
}

/// "5 min ago" today, otherwise the clock time (the day is in the header).
String feedTime(AppLocalizations t, DateTime? value) {
  if (value == null) return '';
  final local = value.isUtc ? value.toLocal() : value;
  if (daysUntil(local) == 0) return relativeTime(t, value);
  return DateFormat.jm(t.localeName).format(local);
}

/// Small muted day title above a group of entries.
class DayHeader extends StatelessWidget {
  const DayHeader(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: Space.xxs, top: Space.lg, bottom: Space.xs),
    child: Text(label, style: context.text.labelMedium?.copyWith(color: context.colors.textMuted)),
  );
}

/// The entries of one day in a single card, with hairlines between them.
class FeedGroup extends StatelessWidget {
  const FeedGroup({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const Divider(height: 1, indent: 64, endIndent: Space.md),
          child,
        ],
      ],
    ),
  );
}
