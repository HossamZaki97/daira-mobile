import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/models/money.dart';
import '../../design/design.dart';
import '../../l10n/messages.dart';
import '../common.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The chosen date, big and clear; three one-tap choices on one line; and a
/// calendar that opens in place (no dialog) for any other day.
class DatePickerCard extends StatefulWidget {
  const DatePickerCard({required this.value, required this.onChanged, this.allowPast = false, super.key});
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  /// A running circle's current installment may already be due.
  final bool allowPast;

  @override
  State<DatePickerCard> createState() => _DatePickerCardState();
}

class _DatePickerCardState extends State<DatePickerCard> {
  bool _calendar = false;

  void _pick(DateTime d) {
    HapticFeedback.selectionClick();
    widget.onChanged(_day(d));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final today = _day(DateTime.now());
    final value = _day(widget.value);
    final presets = <(String, DateTime)>[
      (t.dateToday, today),
      (t.dateNextWeek, today.add(const Duration(days: 7))),
      (t.dateNextMonthStart, DateTime(today.year, today.month + 1, 1)),
    ];
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.sm),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: colors.accentContainer, shape: BoxShape.circle),
                  child: Icon(AppIcons.dueDate, size: 22, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: context.reduceMotion ? Duration.zero : Motion.fast,
                        child: Text(
                          DateFormat.yMMMMEEEEd(t.localeName).format(value),
                          key: ValueKey(value),
                          style: context.text.titleMedium,
                        ),
                      ),
                      Text(dueLabel(t, value), style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick choices on one line (scrolls sideways on very narrow phones).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: Row(
              children: [
                for (final (label, date) in presets) ...[
                  ChoiceChip(
                    label: Text(label),
                    selected: value == date,
                    showCheckmark: false,
                    onSelected: (_) => _pick(date),
                  ),
                  const SizedBox(width: Space.xs),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.xs),
          const Divider(height: 1),
          InkWell(
            onTap: () => setState(() => _calendar = !_calendar),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
              child: Row(
                children: [
                  Icon(AppIcons.calendar, size: 18, color: colors.primary),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: Text(t.pickFromCalendar, style: context.text.labelLarge?.copyWith(color: colors.primary)),
                  ),
                  AnimatedRotation(
                    turns: _calendar ? 0.5 : 0,
                    duration: Motion.fast,
                    child: Icon(AppIcons.expand, size: 18, color: colors.primary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: context.reduceMotion ? Duration.zero : Motion.standard,
            curve: Motion.easing,
            alignment: Alignment.topCenter,
            child: _calendar
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(Space.sm, 0, Space.sm, Space.sm),
                    child: MonthCalendar(
                      selected: value,
                      first: widget.allowPast ? DateTime(today.year - 1, today.month, today.day) : today,
                      last: DateTime(today.year + 3, today.month, today.day),
                      onPick: _pick,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// A month of days in the app's style: tap a day; arrows change the month.
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({required this.selected, required this.first, required this.last, required this.onPick, super.key});
  final DateTime selected;
  final DateTime first;
  final DateTime last;
  final ValueChanged<DateTime> onPick;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month = DateTime(widget.selected.year, widget.selected.month);

  bool get _canBack => DateTime(_month.year, _month.month).isAfter(DateTime(widget.first.year, widget.first.month));
  bool get _canNext => DateTime(_month.year, _month.month).isBefore(DateTime(widget.last.year, widget.last.month));

  void _go(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    final symbols = DateFormat.yMMMM(t.localeName).dateSymbols;
    final firstWeekday = symbols.FIRSTDAYOFWEEK; // 0 = Monday
    final names = symbols.NARROWWEEKDAYS; // Sunday first
    final start = DateTime(_month.year, _month.month);
    final offset = (start.weekday - 1 - firstWeekday) % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final today = _day(DateTime.now());
    final first = _day(widget.first);
    final last = _day(widget.last);
    final cells = [for (var i = 0; i < offset; i++) null, for (var d = 1; d <= days; d++) DateTime(_month.year, _month.month, d)];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    Widget arrow(IconData icon, bool enabled, int delta, String tooltip) => IconButton(
      tooltip: tooltip,
      onPressed: enabled ? () => _go(delta) : null,
      icon: DirectionalIcon(icon, size: 18, color: enabled ? colors.primary : colors.textDisabled),
    );

    return Column(
      children: [
        Row(
          children: [
            arrow(AppIcons.back, _canBack, -1, MaterialLocalizations.of(context).previousMonthTooltip),
            Expanded(
              child: Text(
                DateFormat.yMMMM(t.localeName).format(_month),
                textAlign: TextAlign.center,
                style: context.text.titleSmall,
              ),
            ),
            arrow(AppIcons.arrowForward, _canNext, 1, MaterialLocalizations.of(context).nextMonthTooltip),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  // NARROWWEEKDAYS starts on Sunday; Monday is index 1.
                  child: Text(names[(firstWeekday + 1 + i) % 7], style: context.text.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.xxs),
        for (var row = 0; row < cells.length ~/ 7; row++)
          Row(
            children: [
              for (final day in cells.sublist(row * 7, row * 7 + 7))
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: day == null
                        ? const SizedBox.shrink()
                        : _DayCell(
                            day: day,
                            selected: day == _day(widget.selected),
                            today: day == today,
                            enabled: !day.isBefore(first) && !day.isAfter(last),
                            onTap: () => widget.onPick(day),
                          ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.selected, required this.today, required this.enabled, required this.onTap});
  final DateTime day;
  final bool selected;
  final bool today;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: selected ? colors.primary : Colors.transparent,
        shape: CircleBorder(side: today && !selected ? BorderSide(color: colors.accent, width: 1.5) : BorderSide.none),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              '${day.day}',
              style: context.text.bodyMedium?.copyWith(
                fontFeatures: DairaType.numeric.fontFeatures,
                fontWeight: selected || today ? FontWeight.w700 : null,
                color: selected ? colors.onPrimary : (enabled ? colors.text : colors.textDisabled),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shares as calm numbered choices with what they mean, instead of − / +.
class SharesSheet extends StatefulWidget {
  const SharesSheet({required this.name, required this.value, required this.max, required this.installment, super.key});
  final String name;
  final int value;
  final int max;

  /// Per share, to show what each choice means.
  final Money installment;

  @override
  State<SharesSheet> createState() => _SharesSheetState();
}

class _SharesSheetState extends State<SharesSheet> {
  late int _value = widget.value;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.sharesFor(widget.name), style: context.text.titleLarge),
        const SizedBox(height: Space.xs),
        Text(t.sharesExplain, style: context.text.bodyMedium?.copyWith(color: colors.textMuted)),
        const SizedBox(height: Space.lg),
        SharesChoice(value: _value, max: widget.max, onChanged: (v) => setState(() => _value = v)),
        const SizedBox(height: Space.md),
        Container(
          padding: const EdgeInsets.all(Space.sm),
          decoration: BoxDecoration(color: colors.surfaceSunken, borderRadius: BorderRadius.circular(Radii.md)),
          child: Text(
            t.sharesMeaning(_value, widget.installment.times(_value).format(t.localeName)),
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
        ),
        const SizedBox(height: Space.lg),
        AppButton(label: t.done, onPressed: () => Navigator.pop(context, _value)),
      ],
    );
  }
}

/// Numbered round choices 1…max in one wrapping row: the selected one is filled.
class SharesChoice extends StatelessWidget {
  const SharesChoice({required this.value, required this.max, required this.onChanged, super.key});
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (var n = 1; n <= max; n++)
          Semantics(
            selected: n == value,
            button: true,
            label: context.l10n.sharesCount(n),
            excludeSemantics: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(n);
              },
              child: AnimatedContainer(
                duration: context.reduceMotion ? Duration.zero : Motion.fast,
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: n == value ? colors.primary : colors.surface,
                  border: Border.all(color: n == value ? colors.primary : colors.line),
                ),
                child: Text(
                  '$n',
                  style: context.text.titleMedium?.copyWith(
                    color: n == value ? colors.onPrimary : colors.text,
                    fontFeatures: DairaType.numeric.fontFeatures,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Running circle: tap the round it is at now. Rounds before it count as
/// received; each chip shows who receives it.
class CurrentRoundPicker extends StatelessWidget {
  const CurrentRoundPicker({required this.names, required this.current, required this.onChanged, this.enabled = true, super.key});

  /// Recipient of each round, in order.
  final List<String> names;

  /// 1-based.
  final int current;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.currentRoundQuestion, style: context.text.titleSmall),
                Text(
                  current <= 1 ? t.currentRoundFirst : t.currentRoundHint(current - 1),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var n = 1; n <= names.length; n++) ...[
                  if (n > 1) const SizedBox(width: Space.xs),
                  InkWell(
                    borderRadius: BorderRadius.circular(Radii.md),
                    onTap: enabled
                        ? () {
                            HapticFeedback.selectionClick();
                            onChanged(n);
                          }
                        : null,
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: context.reduceMotion ? Duration.zero : Motion.fast,
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: n < current ? colors.successContainer : (n == current ? colors.accent : colors.surface),
                              border: Border.all(
                                color: n < current ? colors.success : (n == current ? colors.accent : colors.line),
                              ),
                            ),
                            child: n < current
                                ? Icon(AppIcons.check, size: 18, color: colors.success)
                                : Text(
                                    '$n',
                                    style: context.text.labelLarge?.copyWith(
                                      color: n == current ? colors.onAccent : colors.text,
                                      fontFeatures: DairaType.numeric.fontFeatures,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: Space.xxs),
                          Text(
                            names[n - 1].split(' ').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: context.text.labelSmall?.copyWith(
                              color: n == current ? colors.text : null,
                              fontWeight: n == current ? FontWeight.w700 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
