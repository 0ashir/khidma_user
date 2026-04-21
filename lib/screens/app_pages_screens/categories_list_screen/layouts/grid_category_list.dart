import 'dart:developer';

import '../../../../config.dart';

class GridCategoryList extends StatelessWidget {
  const GridCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<CategoriesDetailsProvider, LanguageProvider,
            CategoriesListProvider, DashboardProvider>(
        builder: (context1, category, lang, value, dash, child) {
      return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: value.categoryList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisExtent: Sizes.s110,
              mainAxisSpacing: Sizes.s10,
              crossAxisSpacing: Sizes.s10),
          itemBuilder: (context, index) {
            // Top Categories lists
            return TopCategoriesLayout(
                index: index,
                selectedIndex: dash.topSelected,
                data: value.categoryList[index],
                onTap: () {
                  log("value.categoryList[index]:${value.categoryList[index].id}");
                  category.fetchBannerAdsData(context);
                  category.demoList = [];
                  category
                      .getServiceByCategoryId(context,
                          id: value.categoryList[index].id)
                      /*  .getCategoryService(id: value.categoryList[index].id) */
                      .then(
                    (val) {
                      route.pushNamed(
                          context, routeName.categoriesDetailsScreen,
                          arg: value.categoryList[index]);
                    },
                  );
                });
          });
    });
  }
}
