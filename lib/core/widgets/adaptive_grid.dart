import 'package:flutter/material.dart';

/// Lays children out in equal-width columns that follow the window width.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.maxColumns = 4,
    this.minItemWidth = 240,
    this.spacing = 20,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = ((constraints.maxWidth + spacing) / (minItemWidth + spacing)).floor();
        final columns = fit.clamp(1, maxColumns);
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
