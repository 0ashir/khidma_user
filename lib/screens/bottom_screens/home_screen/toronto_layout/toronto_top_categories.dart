import 'package:fixit_user/config.dart';

class TorontoTopCategories extends StatelessWidget {
  const TorontoTopCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<CommonApiProvider, DashboardProvider,
            CategoriesDetailsProvider>(
        builder: (context, commonApi, dash, categoryDetails, child) {
      final categories = commonApi.dashboardModel?.categories ?? [];

      return Column(
        children: [
          if (commonApi.dashboardModel?.categories?.isNotEmpty ?? false)
            HeadingRowCommon(
                    title: translations!.topCategories,
                    isTextSize: true,
                    onTap: () => route.pushNamed(
                        context, routeName.categoriesListScreen))
                .paddingSymmetric(horizontal: Insets.i20),
          if (commonApi.dashboardModel?.categories?.isNotEmpty ?? false)
            const VSpace(Sizes.s15),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
            itemCount: categories.isEmpty
                ? 0
                : (categories.length >= 8 ? 8 : categories.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisExtent: Sizes.s110,
              mainAxisSpacing: Sizes.s10,
              crossAxisSpacing: Sizes.s10,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];

              return TopCategoriesLayout(
                isCircle: true,
                index: index,
                selectedIndex: dash.topSelected,
                data: homeCategoryList.isNotEmpty
                    ? homeCategoryList[index]
                    : null,
                onTap: () {
                  categoryDetails.hasCategoryList.clear();

                  if (category.hasSubCategories != null &&
                      category.hasSubCategories!.isNotEmpty) {
                    categoryDetails.hasCategoryList.addAll(
                      category.hasSubCategories!
                          .map((subCategory) => CategoryModel(
                                id: subCategory.id,
                                title: subCategory.title,
                                media: [
                                  Media(
                                    originalUrl: (subCategory.media != null &&
                                            subCategory.media!.isNotEmpty)
                                        ? subCategory.media![0].originalUrl
                                        : '',
                                  )
                                ],
                              ))
                          .toList(),
                    );
                  }

                  route.pushNamed(
                    context,
                    routeName.categoriesDetailsScreen,
                    arg: homeCategoryList.isNotEmpty
                        ? homeCategoryList[index]
                        : null,
                  );
                },
              );
            },
          )
        ],
      );
    });
  }
}
