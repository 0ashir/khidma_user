import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

/// A bill row whose arrow opens [details] (e.g. base price + each tax) under it.
class ExpandableChargeRow extends StatefulWidget {
  const ExpandableChargeRow({
    required this.title,
    required this.amount,
    required this.details,
    this.fontSize = 14,
    this.padding = EdgeInsets.zero,
    this.detailsGap = 8,
    super.key,
  });

  final String title;
  final String amount;
  final List<Widget> details;
  final double fontSize;

  /// Around the title/amount row.
  final EdgeInsetsGeometry padding;
  final double detailsGap;

  @override
  State<ExpandableChargeRow> createState() => _ExpandableChargeRowState();
}

class _ExpandableChargeRowState extends State<ExpandableChargeRow> {
  bool _expanded = false;

  @override
  Widget build(final BuildContext context) => Column(
    children: [
      InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: widget.padding,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: CustomText(
                        widget.title,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const CustomSizedBox(width: 2),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: widget.fontSize + 4,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CustomText(
                widget.amount,
                textAlign: TextAlign.end,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ],
          ),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: _expanded
            ? Container(
                width: double.infinity,
                margin: EdgeInsetsDirectional.only(
                  start: 4,
                  top: widget.detailsGap,
                ),
                padding: const EdgeInsetsDirectional.only(start: 12),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(
                      color: context.colors.borderDefault,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(children: widget.details),
              )
            : const SizedBox(width: double.infinity),
      ),
    ],
  );
}
