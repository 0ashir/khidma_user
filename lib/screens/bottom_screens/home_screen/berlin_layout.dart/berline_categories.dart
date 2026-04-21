import 'package:fixit_user/config.dart';

class BerlineCategories extends StatelessWidget {
  final bool isTokyo;
  const BerlineCategories({super.key, this.isTokyo = false});

  @override
  Widget build(BuildContext context) {
    return Consumer3<CommonApiProvider, DashboardProvider,
            CategoriesDetailsProvider>(
        builder: (context, commonApi, dash, categoryDetails, child) {
      return ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: homeCategoryList.length,
          itemBuilder: (context, index) {
            return TopCategoriesLayout(
                isExapnded: false,
                index: index,
                isCircle: isTokyo == true ? true : false,
                selectedIndex: dash.topSelected,
                data: homeCategoryList[index],
                onTap: () {
                  categoryDetails.fetchBannerAdsData(context);
                  // categoryDetails.mediaUrls = [];
                  categoryDetails.hasCategoryList.clear();
                  categoryDetails.hasCategoryList.addAll(
                    (commonApi.dashboardModel!.categories?[index]
                                .hasSubCategories ??
                            [])
                        .map((subCategory) => CategoryModel(
                              id: subCategory.id,
                              title: subCategory.title,
                              media: [
                                Media(
                                    originalUrl: (subCategory.media != null &&
                                            subCategory.media!.isNotEmpty)
                                        ? subCategory.media!.first.originalUrl
                                        : '')
                              ],
                              // Add other required fields here
                            ))
                        .toList() as Iterable<CategoryModel>,
                  );

                  route.pushNamed(context, routeName.categoriesDetailsScreen,
                      arg: homeCategoryList[index]);
                });
          });
    });
  }
}
