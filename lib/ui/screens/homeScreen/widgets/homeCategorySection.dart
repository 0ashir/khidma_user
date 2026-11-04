import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({
    required this.sectionData,
    required this.isAllCategories,
    super.key,
  });

  final Sections sectionData;
  final bool isAllCategories;
  static const int _categoryGridMinItems = 4;

  Widget _categoryItem(
    final BuildContext context,
    final CategoryModel category,
  ) => CustomInkWellContainer(
    onTap: () {
      UiUtils.navigateToCategoryDetails(
        context,
        categoryId: category.id,
        categoryName: category.name,
      );
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          width: 48,
          height: 48,
          borderRadius: 24,
          color: context.colors.backgroundSecondary,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(12),
          child: CustomCachedNetworkImage(
            networkImageUrl: category.categoryImage ?? '',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            defaultColourFilter: false,
          ),
        ),
        const CustomSizedBox(height: 6),
        CustomText(
          category.name ?? '',
          fontSize: 12,
          color: context.colors.textPrimary,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    ),
  );

  Widget _categoryGrid(
    final BuildContext context,
    final List<CategoryModel> categoryList,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final int crossAxisCount = ResponsiveHelper.isTabletDevice(context)
          ? 6
          : 4;
      const double spacing = 24;
      final double itemWidth =
          (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
          crossAxisCount;
      return Wrap(
        spacing: spacing,
        runSpacing: 16,
        children: List.generate(categoryList.length, (index) {
          return SizedBox(
            width: itemWidth,
            child: _categoryItem(context, categoryList[index]),
          );
        }),
      );
    },
  );

  Widget _gridCard(
    final BuildContext context,
    final List<CategoryModel> categories,
  ) => Padding(
    padding: EdgeInsetsDirectional.symmetric(horizontal: 15.rs(context)),
    child: CustomContainer(
      // Without an explicit width the card shrink-wraps its items, so a
      // short last row (e.g. 5 items on a 6-column tablet grid) leaves it
      // narrower than the screen.
      width: double.infinity,
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      padding: EdgeInsets.all(12.rh(context)),
      child: _categoryGrid(context, categories),
    ),
  );

  Widget _allCategories(final BuildContext context) {
    final List<CategoryModel> categories = sectionData.categories;
    if (categories.isEmpty) return const CustomSizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 15.rs(context),
            end: 15.rs(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'seviceCategory'.translate(context: context),
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                textAlign: TextAlign.left,
              ),
              CustomInkWellContainer(
                onTap: () {
                  Navigator.pushNamed(context, allCategoriesRoute);
                },
                child: CustomText(
                  'viewAll'.translate(context: context),
                  color: context.colors.textBrand,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const CustomSizedBox(height: 12),
        _gridCard(
          context,
          categories
              .take(ResponsiveHelper.isTabletDevice(context) ? 12 : 8)
              .toList(),
        ),
      ],
    );
  }

  Widget _featuredCategories(final BuildContext context) {
    final List<CategoryModel> categories = sectionData.categories;
    final int gridMaxItems = ResponsiveHelper.isTabletDevice(context) ? 12 : 8;
    final bool useGrid =
        categories.length >= _categoryGridMinItems &&
        categories.length <= gridMaxItems;
    final Widget content = useGrid
        ? _gridCard(context, categories)
        : Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 15.rs(context),
            ),
            child: CustomContainer(
              width: double.infinity,
              color: context.colors.backgroundPrimary,
              borderRadius: UiUtils.borderRadiusOf12,
              padding: EdgeInsets.all(12.rh(context)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: categories
                      .map(
                        (final category) => CustomSizedBox(
                          width: 64,
                          child: _categoryItem(context, category),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 15.rs(context),
            end: 15.rs(context),
          ),
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                child: CustomText(
                  sectionData.translatedTitle ?? '',
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        CustomSizedBox(height: 12.rh(context)),
        content,
      ],
    );
  }

  @override
  Widget build(final BuildContext context) =>
      isAllCategories ? _allCategories(context) : _featuredCategories(context);
}
