import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final Color? trackColor;
  final Color? activeColor;
  final Color? thumbColor;
  final double scale;
  final void Function(bool) onChanged;

  const CustomSwitch({
    super.key,
    required this.onChanged,
    required this.value,
    this.trackColor,
    this.activeColor,
    this.thumbColor,
    this.scale = 1,
  });

  static const double _width = 48;
  static const double _height = 24;
  static const double _padding = 4;
  static const double _thumbSize = 15;
  static const Duration _duration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final Widget switchWidget = GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: _duration,
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color:
              (value ? activeColor : trackColor) ??
              context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(_height / 2),
        ),
        child: AnimatedAlign(
          duration: _duration,
          curve: Curves.easeInOut,
          alignment: value
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            width: _thumbSize,
            height: _thumbSize,
            decoration: BoxDecoration(
              color: thumbColor ?? context.colors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );

    if (scale == 1) return switchWidget;
    return Transform.scale(scale: scale, child: switchWidget);
  }
}
