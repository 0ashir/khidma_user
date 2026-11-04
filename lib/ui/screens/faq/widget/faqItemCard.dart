import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class FaqItemCard extends StatefulWidget {
  const FaqItemCard({
    required this.question,
    required this.answer,
    this.highlightExpandedHeader = true,
    super.key,
  });

  final String question;
  final String answer;

  /// When false, the header keeps the card colour while expanded.
  final bool highlightExpandedHeader;

  @override
  State<FaqItemCard> createState() => _FaqItemCardState();
}

class _FaqItemCardState extends State<FaqItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.backgroundPrimary,
    borderRadius: UiUtils.borderRadiusOf12,
    border: Border.all(color: context.colors.borderDefault),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInkWellContainer(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: CustomContainer(
            color: _isExpanded && widget.highlightExpandedHeader
                ? context.colors.backgroundSecondary
                : context.colors.backgroundPrimary,
            borderRadiusStyle: _isExpanded
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  )
                : const BorderRadius.all(Radius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    widget.question,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const CustomSizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomSvgPicture(
                    svgImage: AppAssets.downArrow,
                    height: 24,
                    width: 24,
                    color: context.colors.iconPrimary,
                    avoideResponsive: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          if (!widget.highlightExpandedHeader)
            Divider(height: 1, color: context.colors.borderDefault),
          Padding(
            padding: const EdgeInsets.all(12),
            child: CustomText(
              widget.answer,
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              maxLines: 100,
            ),
          ),
        ],
      ],
    ),
  );
}
