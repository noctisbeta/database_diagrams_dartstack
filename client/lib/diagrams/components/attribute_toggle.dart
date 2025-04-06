import 'package:flutter/material.dart';

class AttributeToggle extends StatelessWidget {
  const AttributeToggle({
    required this.selected,
    required this.onSelected,
    required this.child,
    required this.tooltip,
    super.key,
  });

  final bool selected;
  final ValueChanged<bool> onSelected;
  final Widget child;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: () => onSelected(!selected),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color:
              selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          border: Border.all(
            color:
                selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: 14,
              color:
                  selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color:
                    selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
