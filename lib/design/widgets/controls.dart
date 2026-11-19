import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens.dart';

/// Two or three views of one screen in a soft pill track («الأقساط | الأدوار»).
/// The white thumb slides to the selected item.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({required this.items, required this.value, required this.onChanged, super.key});

  /// (value, label, optional count shown as a small number).
  final List<(T, String, int?)> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final index = items.indexWhere((i) => i.$1 == value).clamp(0, items.length - 1);
    final duration = context.reduceMotion ? Duration.zero : Motion.standard;
    // -1 is the start edge; it flips with the text direction.
    final x = items.length == 1 ? 0.0 : -1 + 2 * index / (items.length - 1);
    return Semantics(
      container: true,
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(Space.xxs),
        decoration: BoxDecoration(color: colors.surfaceSunken, borderRadius: BorderRadius.circular(Radii.pill)),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: duration,
              curve: Motion.easing,
              alignment: AlignmentDirectional(x, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / items.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(Radii.pill),
                    boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(0, 1))],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final (v, label, count) in items)
                  Expanded(
                    child: Semantics(
                      selected: v == value,
                      button: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Radii.pill),
                        onTap: v == value
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                onChanged(v);
                              },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            style: context.text.labelLarge!.copyWith(
                              color: v == value ? colors.primary : colors.textMuted,
                              fontWeight: v == value ? FontWeight.w700 : FontWeight.w600,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                if (count != null && count > 0) ...[
                                  const SizedBox(width: Space.xxs + 2),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: v == value ? colors.accent : colors.lineStrong,
                                      borderRadius: BorderRadius.circular(Radii.pill),
                                    ),
                                    child: Text(
                                      '$count',
                                      textAlign: TextAlign.center,
                                      style: context.text.labelSmall?.copyWith(
                                        color: v == value ? colors.onAccent : colors.text,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A quick action under a screen's main card: tinted icon, short label.
/// Several sit side by side in [ActionTiles].
class ActionTile extends StatelessWidget {
  const ActionTile({required this.icon, required this.label, required this.onTap, this.dot = false, super.key});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Small amber dot: something here needs a look.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.xs, horizontal: Space.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.line),
                    ),
                    child: Icon(icon, size: 22, color: colors.primary),
                  ),
                  if (dot)
                    PositionedDirectional(
                      top: 2,
                      end: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.background, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.xs),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium?.copyWith(color: colors.text, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of [ActionTile]s sharing the width equally.
class ActionTiles extends StatelessWidget {
  const ActionTiles({required this.children, super.key});
  final List<ActionTile> children;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [for (final tile in children) Expanded(child: tile)],
  );
}

/// Bar that rises from the bottom while items are selected: what will happen
/// and the one action. Put it in a Stack over the page.
class SelectionBar extends StatelessWidget {
  const SelectionBar({required this.visible, required this.label, required this.action, this.onClear, super.key});
  final bool visible;
  final String label;
  final Widget action;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.reduceMotion ? Duration.zero : Motion.emphasis;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 1.2),
        duration: duration,
        curve: Motion.easing,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: duration,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.all(Space.gutter),
            child: Material(
              color: colors.hero,
              elevation: 8,
              shadowColor: colors.primary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(Radii.xl),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(Space.xs, Space.xs, Space.xs, Space.xs),
                child: Row(
                  children: [
                    if (onClear != null)
                      IconButton(
                        onPressed: onClear,
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        icon: Icon(AppIcons.close, color: colors.onHeroMuted, size: 20),
                      )
                    else
                      const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge?.copyWith(color: colors.onHero),
                      ),
                    ),
                    const SizedBox(width: Space.xs),
                    action,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
