import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CategoryDetailsAppBar {
  const CategoryDetailsAppBar._();

  static const double filterRowHeight = 68;

  static PreferredSizeWidget build({
    required final BuildContext context,
    required final String title,
    required final Widget filterRow,
    final Widget? subtitle,
    final VoidCallback? onTapMap,
    final VoidCallback? onLeadingTap,
  }) {
    return UiUtils.getSimpleAppBar(
      context: context,
      titleSpacing: 4,
      onLeadingTap: onLeadingTap,
      actions: [mapButton(context, onTap: onTapMap)],
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            title,
            maxLines: 1,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
          if (subtitle != null) ...[const CustomSizedBox(height: 4), subtitle],
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(filterRowHeight),
        child: filterRow,
      ),
    );
  }

  static Widget mapButton(
    final BuildContext context, {
    final VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 16),
    child: CustomInkWellContainer(
      borderRadius: BorderRadius.circular(8),
      onTap:
          onTap ??
          () {
            UiUtils.showMessage(
              context,
              'comingsoon'.translate(context: context),
              ToastificationType.info,
            );
          },
      child: CustomContainer(
        color: context.colors.backgroundSecondary,
        border: Border.all(color: context.colors.borderDefault),
        borderRadius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.mapTrifold,
              height: 18,
              width: 18,
              color: context.colors.iconPrimary,
            ),
            CustomText(
              'map'.translate(context: context),
              fontSize: 14,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      ),
    ),
  );
}

class CategoryQuickFilterChip extends StatelessWidget {
  const CategoryQuickFilterChip({
    required this.label,
    this.icon,
    this.onTap,
    this.isSelected = false,
    super.key,
  });

  final String? icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(final BuildContext context) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? context.colors.backgroundBrandSubtle
            : context.colors.backgroundSecondary,
        borderRadius: UiUtils.borderRadiusOf12,
        border: isSelected
            ? Border.all(color: context.colors.backgroundBrand, width: 1)
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              CustomSvgPicture(
                avoideResponsive: true,
                svgImage: icon!,
                height: 20,
                width: 20,
                color: isSelected
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              const CustomSizedBox(width: 8),
            ],
            CustomText(
              label,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected
                  ? context.colors.textBrand
                  : context.colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryQuickFilterRow extends StatelessWidget {
  const CategoryQuickFilterRow({required this.chips, super.key});

  final List<CategoryQuickFilterChip> chips;

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: context.colors.overlayHeaderShadow,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      // The side gutter lives inside the scroller so chips slide under the
      // screen edges instead of being clipped 16px in from both sides.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (int index = 0; index < chips.length; index++) ...[
              if (index != 0) const CustomSizedBox(width: 8),
              chips[index],
            ],
          ],
        ),
      ),
    );
  }
}

class CategorySubCategoryRow extends StatelessWidget {
  const CategorySubCategoryRow({
    required this.subCategories,
    required this.onTapSubCategory,
    super.key,
    this.selectedSubCategoryId,
  });

  final List<SubCategory> subCategories;
  final void Function(SubCategory subCategory) onTapSubCategory;
  final String? selectedSubCategoryId;

  static String countLabel(
    final BuildContext context,
    final SubCategory subCategory,
  ) {
    final bool showServices = context
        .read<SystemSettingCubit>()
        .isCategoryDetailsViewTypeServices;
    final int count = showServices
        ? (subCategory.totalServices ?? '0').convertToInt()
        : (subCategory.totalProviders ?? '0').convertToInt();
    if (count == 0) return 'comingsoon'.translate(context: context);
    final String unitKey = showServices
        ? (count > 1 ? 'services' : 'service')
        : (count > 1 ? 'providers' : 'provider');
    return '$count ${unitKey.translate(context: context)}';
  }

  @override
  Widget build(final BuildContext context) {
    if (subCategories.isEmpty) return const CustomSizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (int index = 0; index < subCategories.length; index++) ...[
              if (index != 0) const CustomSizedBox(width: 8),
              CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTapSubCategory(subCategories[index]),
                child: CustomContainer(
                  width: 160,
                  color: context.colors.backgroundPrimary,
                  borderRadius: 12,
                  border: subCategories[index].id == selectedSubCategoryId
                      ? Border.all(color: context.colors.backgroundBrand)
                      : null,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CustomCachedNetworkImage(
                          networkImageUrl:
                              subCategories[index].categoryImage ?? '',
                          height: 40,
                          width: 30,
                          fit: BoxFit.cover,
                          defaultColourFilter: false,
                        ),
                      ),
                      const CustomSizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              subCategories[index].name ?? '',
                              maxLines: 1,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                            const CustomSizedBox(height: 4),
                            CustomText(
                              countLabel(context, subCategories[index]),
                              maxLines: 1,
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ],
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
    );
  }
}
