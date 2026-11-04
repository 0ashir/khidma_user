import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class SortByBottomSheet extends StatelessWidget {
  const SortByBottomSheet({
    super.key,
    required this.currentSortBy,
    required this.onSelected,
  });

  final String? currentSortBy;
  final ValueChanged<String> onSelected;

  static const List<(String labelKey, String sortBy)> options = [
    ('default', ''),
    ('priceLowToHigh', 'price_low_to_high'),
    ('priceHighToLow', 'price_high_to_low'),
    ('ratingHighToLow', 'rating_high_to_low'),
    ('ratingLowToHigh', 'rating_low_to_high'),
    ('distanceLowToHigh', 'distance_low_to_high'),
    ('distanceHighToLow', 'distance_high_to_low'),
    ('durationShortestFirst', 'duration_shortest_first'),
    ('durationLongestFirst', 'duration_longest_first'),
  ];

  static Future<void> show(
    final BuildContext context, {
    required final String? currentSortBy,
    required final ValueChanged<String> onSelected,
  }) => UiUtils.showBottomSheet(
    context: context,
    child: SortByBottomSheet(
      currentSortBy: currentSortBy,
      onSelected: onSelected,
    ),
  );

  @override
  Widget build(final BuildContext context) {
    final String selected = currentSortBy ?? '';

    return CustomContainer(
      color: context.colors.surfacePrimary,
      borderRadiusStyle: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.borderDefault,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const CustomSizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CustomText(
                    'sortBy'.translate(context: context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const CustomSizedBox(height: 8),
                Divider(height: 1, color: context.colors.borderMuted),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < options.length; i++) ...[
                    if (i > 0) ...[
                      const CustomSizedBox(height: 12),
                      CustomSizedBox(
                        height: 1,
                        width: double.infinity,
                        child: DashedRect(
                          color: context.colors.borderDefault,
                          strokeWidth: 1,
                          gap: 4,
                        ),
                      ),
                      const CustomSizedBox(height: 12),
                    ],
                    _buildOptionRow(context, options[i], selected),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    final BuildContext context,
    final (String labelKey, String sortBy) option,
    final String selected,
  ) {
    final bool isSelected = option.$2 == selected;
    return CustomInkWellContainer(
      onTap: () {
        Navigator.pop(context);
        onSelected(option.$2);
      },
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              option.$1.translate(context: context),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: context.colors.textPrimary,
            ),
          ),
          const CustomSizedBox(width: 12),
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 24,
            color: isSelected
                ? context.colors.iconBrand
                : context.colors.iconTertiary,
          ),
        ],
      ),
    );
  }
}
