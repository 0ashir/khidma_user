import 'package:flutter/material.dart';

/// Lays [children] out in rows of [columns] with equal-width cells and equal
/// height per row. Used for tablet grids whose cards vary in height, where a
/// fixed-height grid delegate would clip or leave gaps. A short last row keeps
/// its cells at column width instead of stretching.
class EqualHeightGrid extends StatelessWidget {
  const EqualHeightGrid({
    required this.children,
    super.key,
    this.columns = 2,
    this.spacing = 12,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;

  @override
  Widget build(final BuildContext context) => Column(
    spacing: spacing,
    children: [
      for (int i = 0; i < children.length; i += columns)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: [
              for (int j = i; j < i + columns; j++)
                Expanded(
                  child: j < children.length ? children[j] : const SizedBox(),
                ),
            ],
          ),
        ),
    ],
  );
}
