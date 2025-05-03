import 'package:flutter/material.dart';

class AttributeToggle extends StatelessWidget {
  const AttributeToggle({
    required this.selected,
    required this.onSelected,
    required this.child,
    required this.tooltip,
    required this.disabled,
    super.key,
  });

  final bool selected;
  final ValueChanged<bool> onSelected;
  final Widget child;
  final String tooltip;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor;
    final Color effectiveBackgroundColor;
    final Color effectiveForegroundColor;
    final Color disabledColor = Theme.of(context).disabledColor;
    final Color outlineColor = Theme.of(context).colorScheme.outline;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color primaryContainerColor =
        Theme.of(context).colorScheme.primaryContainer;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    if (disabled) {
      effectiveBorderColor = disabledColor.withValues(alpha: 0.5);
      effectiveBackgroundColor = Colors.transparent.withValues(alpha: 0.1);
      effectiveForegroundColor = disabledColor;
    } else {
      effectiveBorderColor = selected ? primaryColor : outlineColor;
      effectiveBackgroundColor =
          selected ? primaryContainerColor : Colors.transparent;
      effectiveForegroundColor = selected ? primaryColor : onSurfaceColor;
    }

    return Tooltip(
      message: disabled ? 'Disabled' : tooltip,
      child: InkWell(
        onTap: disabled ? null : () => onSelected(!selected),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: effectiveBackgroundColor,
            border: Border.all(color: effectiveBorderColor),
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(size: 14, color: effectiveForegroundColor),
              child: DefaultTextStyle(
                style: TextStyle(fontSize: 12, color: effectiveForegroundColor),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
