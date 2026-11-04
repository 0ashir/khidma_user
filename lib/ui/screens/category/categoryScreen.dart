import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/categoryContainer.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.scrollController, final Key? key})
    : super(key: key);
  final ScrollController scrollController;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero).then((final value) {
      fetchCategory();
    });
    widget.scrollController.addListener(_fetchMoreOnScroll);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_fetchMoreOnScroll);
    super.dispose();
  }

  void fetchCategory() {
    context.read<CategoryCubit>().getCategory();
  }

  void _fetchMoreOnScroll() {
    if (!context.read<CategoryCubit>().hasMoreCategory()) return;
    final ScrollController controller = widget.scrollController;
    if (!controller.hasClients) return;
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      context.read<CategoryCubit>().fetchMoreCategory();
    }
  }

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: AnnotatedSafeArea(
          isAnnotated: true,
          applyBottomInset: false,
          child: Scaffold(
            appBar: UiUtils.getSimpleAppBar(
              context: context,
              title: 'services'.translate(context: context),
              centerTitle: true,
              isLeadingIconEnable: false,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              elevation: 0.5,
            ),
            body: CustomContainer(
              color: context.colors.backgroundSecondary,
              child: CustomRefreshIndicator(
                displacment: 12,
                onRefreshCallback: () {
                  fetchCategory();
                },
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder:
                      (
                        final BuildContext context,
                        final CategoryState categoryState,
                      ) {
                        if (categoryState is CategoryFetchFailure) {
                          return ErrorContainer(
                            errorMessage: categoryState.errorMessage.translate(
                              context: context,
                            ),
                            onTapRetry: fetchCategory,
                            showRetryButton: true,
                          );
                        } else if (categoryState is CategoryFetchSuccess) {
                          return categoryState.categoryList.isEmpty
                              ? Center(
                                  child: NoDataFoundWidget(
                                    titleKey: 'noServicesFound'.translate(
                                      context: context,
                                    ),
                                    subtitleKey: 'noServicesFoundSubTitle'
                                        .translate(context: context),
                                    showRetryButton: true,
                                    onTapRetry: () {
                                      fetchCategory();
                                    },
                                  ),
                                )
                              : _getCategoryList(
                                  categoryList: categoryState.categoryList,
                                  isLoadingMore: categoryState.isLoadingMore,
                                );
                        }

                        return _getCategoryShimmerEffect();
                      },
                ),
              ),
            ),
          ),
        ),
      );

  Widget _getCategoryShimmerEffect() => GridView.builder(
    padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
    itemCount: UiUtils.numberOfShimmerContainer * 2,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
      crossAxisCount: ResponsiveHelper.isTabletDevice(context) ? 3 : 2,
      height: 80,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemBuilder: (final context, final index) =>
        const CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf10,
        ),
  );

  Widget _getCategoryList({
    required final List<CategoryModel> categoryList,
    final bool isLoadingMore = false,
  }) => GridView.builder(
    controller: widget.scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(
      15.rw(context),
      15.rh(context),
      15.rw(context),
      kBottomNavigationBarHeight.rh(context),
    ),
    itemCount: categoryList.length + (isLoadingMore ? 1 : 0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
      crossAxisCount: ResponsiveHelper.isTabletDevice(context) ? 3 : 2,
      height: 80,
      crossAxisSpacing: ResponsiveHelper.isTabletDevice(context) ? 8 : 4,
      mainAxisSpacing: ResponsiveHelper.isTabletDevice(context) ? 8 : 4,
    ),
    itemBuilder: (final BuildContext context, int index) {
      if (index >= categoryList.length) {
        return const CustomLoadingMoreContainer(isError: false);
      }
      return CategoryContainer(
        backgroundColor: context.colors.surfaceElevated,
        imageURL: categoryList[index].categoryImage!,
        title: categoryList[index].name!,
        providers: categoryList[index].totalProviders!,
        maxLines: 2,
        imageRadius: UiUtils.borderRadiusOf10,
        fontWeight: FontWeight.w500,
        darkModeBackgroundColor: categoryList[index].backgroundDarkColor,
        lightModeBackgroundColor: categoryList[index].backgroundLightColor,
        onTap: () {
          if (categoryList[index].childrenCount != '0') {
            UiUtils.navigateToCategoryDetails(
              context,
              categoryId: categoryList[index].id,
              categoryName: categoryList[index].name,
            );
          }
        },
      );
    },
  );
}
