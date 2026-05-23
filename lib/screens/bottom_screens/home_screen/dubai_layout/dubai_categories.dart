import 'package:fixit_user/config.dart';

class DubaiCategories extends StatelessWidget {
  const DubaiCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonApiProvider, DashboardProvider>(
        builder: (context, commonApi, dash, child) {
      if (commonApi.dashboardModel == null) return const SizedBox.shrink();
      final categoryDetails =
          Provider.of<CategoriesDetailsProvider>(context, listen: false);
      return Column(
        children: [
          if (commonApi.dashboardModel?.categories?.isNotEmpty == true)
            HeadingRowCommon(
                    title: translations!.topCategories,
                    isTextSize: true,
                    onTap: () => route.pushNamed(
                        context, routeName.categoriesListScreen))
                .paddingSymmetric(horizontal: Insets.i20),
          if (commonApi.dashboardModel?.categories?.isNotEmpty == true)
            const VSpace(Sizes.s15),
          SizedBox(
            height: Sizes.s48,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: homeCategoryList.length,
                itemBuilder: (context, index) {
                  return Row(children: [
                    homeCategoryList[index].media != null &&
                            homeCategoryList[index].media!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: homeCategoryList[index]
                                    .media
                                    ?.first
                                    .originalUrl ??
                                "",
                            imageBuilder: (context, imageProvider) => Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              height: Sizes.s20,
                              /* color: appColor(context).darkText, */
                              width: Sizes.s20,
                            ).paddingAll(Insets.i14),
                            placeholder: (context, url) => Image.asset(
                                    eImageAssets.noImageFound1,
                                    fit: BoxFit.fill,
                                    height: Sizes.s22,
                                    width: Sizes.s22)
                                .paddingAll(Insets.i18),
                            errorWidget: (context, url, error) => Image.asset(
                                    eImageAssets.noImageFound1,
                                    fit: BoxFit.fill,
                                    height: Sizes.s22,
                                    width: Sizes.s22)
                                .paddingAll(Insets.i18),
                          )
                        : dash.topSelected == index
                            ? Image.asset(eImageAssets.noImageFound1,
                                    color: appColor(context).primary,
                                    fit: BoxFit.cover,
                                    height: Sizes.s22,
                                    width: Sizes.s22)
                                .paddingAll(Insets.i18)
                            : Image.asset(eImageAssets.noImageFound1,
                                    fit: BoxFit.cover,
                                    height: Sizes.s22,
                                    width: Sizes.s22)
                                .paddingAll(Insets.i18),
                    Text(homeCategoryList[index].title ?? "",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: appCss.dmDenseRegular13.textColor(
                                dash.topSelected == index
                                    ? appColor(context).primary
                                    : appColor(context).darkText))
                        .padding(right: Insets.i10)
                  ])
                      .inkWell(onTap: () {
                        // Pre-set provider state BEFORE navigating so the
                        // destination page renders correctly on its first frame
                        // with the correct title and shimmer loading state.
                        categoryDetails.categoryModel = homeCategoryList[index];
                        categoryDetails.isServiceLoading = true;
                        categoryDetails.demoList = [];
                        categoryDetails.serviceDemo.clear();
                        categoryDetails.hasCategoryList
                          ..clear()
                          ..addAll(
                            (commonApi.dashboardModel?.categories?[index]
                                        .hasSubCategories ??
                                    [])
                                .map((subCategory) => CategoryModel(
                                      id: subCategory.id,
                                      title: subCategory.title,
                                      media: [
                                        Media(
                                            originalUrl: subCategory
                                                .media?.first.originalUrl)
                                      ],
                                    )),
                          );

                        route.pushNamed(
                            context, routeName.categoriesDetailsScreen,
                            arg: homeCategoryList[index]);
                      })
                      .decorated(
                        borderRadius: BorderRadius.circular(25),
                        color: dash.topSelected == index
                            ? appColor(context).primary.withOpacity(0.2)
                            : dash.topSelected == true
                                ? appColor(context).whiteBg
                                : appColor(context).fieldCardBg,
                      )
                      .padding(left: Insets.i15);
                }),
          )
          /* GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
              itemCount: /* dash.categoryList.length */
                  commonApi.dashboardModel!.categories?.length == 8
                      ? commonApi.dashboardModel!.categories
                          ?.getRange(0, 8)
                          .length /* dash.categoryList.getRange(0, 8).length */
                      : commonApi.dashboardModel!.categories
                          ?.length /* dash.categoryList.length */,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisExtent: Sizes.s110,
                  mainAxisSpacing: Sizes.s10,
                  crossAxisSpacing: Sizes.s10),
              itemBuilder: (context, index) {
                // Top Categories lists
                return TopCategoriesLayout(
                    isCircle: true,
                    index: index,
                    selectedIndex: dash.topSelected,
                    data:
                        homeCategoryList[index] /* dash.categoryList[index] */,
                    onTap: () {
                      categoryDetails.hasCategoryList.clear();
                      categoryDetails.hasCategoryList.addAll(
                        (commonApi.dashboardModel!.categories?[index]
                                    .hasSubCategories ??
                                [])
                            .map((subCategory) => CategoryModel(
                                  // Map fields from HasSubCategoryElement to CategoryModel
                                  id: subCategory
                                      .id, // Example: assuming id exists
                                  title: subCategory
                                      .title, // Adjust based on your model
                                  media: [
                                    Media(
                                        originalUrl: subCategory
                                            .media?.first.originalUrl)
                                  ],
                                  // Add other required fields here
                                ))
                            .toList() as Iterable<CategoryModel>,
                      );

                      route.pushNamed(
                          context, routeName.categoriesDetailsScreen,
                          arg: /* dash.categoryList */
                              homeCategoryList[index]);
                    });
              }), */
        ],
      );
    });
  }
}
