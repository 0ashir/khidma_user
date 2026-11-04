import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(builder: (final _) => const AllCategoriesScreen());

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _scrollController.addListener(_fetchMoreOnScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_fetchMoreOnScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchCategories() {
    context.read<CategoryCubit>().getCategory();
  }

  void _fetchMoreOnScroll() {
    if (!context.read<CategoryCubit>().hasMoreCategory()) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
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
              title: 'categories'.translate(context: context),
              fontWeight: FontWeight.w500,
              fontSize: 16,
              elevation: 0.5,
            ),
            body: CustomContainer(
              color: context.colors.backgroundSecondary,
              child: CustomRefreshIndicator(
                displacment: 12,
                onRefreshCallback: _fetchCategories,
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder:
                      (final BuildContext context, final CategoryState state) {
                        if (state is CategoryFetchFailure) {
                          return ErrorContainer(
                            errorMessage: state.errorMessage.translate(
                              context: context,
                            ),
                            onTapRetry: _fetchCategories,
                            showRetryButton: true,
                          );
                        } else if (state is CategoryFetchSuccess) {
                          return state.categoryList.isEmpty
                              ? Center(
                                  child: NoDataFoundWidget(
                                    titleKey: 'noServicesFound'.translate(
                                      context: context,
                                    ),
                                    subtitleKey: 'noServicesFoundSubTitle'
                                        .translate(context: context),
                                    showRetryButton: true,
                                    onTapRetry: _fetchCategories,
                                  ),
                                )
                              : _categoryGrid(
                                  categoryList: state.categoryList,
                                  isLoadingMore: state.isLoadingMore,
                                );
                        }
                        return _shimmerGrid();
                      },
                ),
              ),
            ),
          ),
        ),
      );

  /// The icon circle and fonts scale with the device, but the grid cell height
  /// is fixed, so tablets get a taller cell to fit a two-line category name.
  double _gridItemHeight(final BuildContext context) {
    if (ResponsiveHelper.isLargeTablet(context)) return 164;
    if (ResponsiveHelper.isTablet(context)) return 148;
    return 124;
  }

  Widget _categoryGrid({
    required final List<CategoryModel> categoryList,
    final bool isLoadingMore = false,
  }) => GridView.builder(
    controller: _scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsetsDirectional.only(
      start: 16.rw(context),
      end: 16.rw(context),
      top: 24.rh(context),
      bottom: UiUtils.getScrollViewBottomPadding(context),
    ),
    itemCount: categoryList.length + (isLoadingMore ? 1 : 0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
      crossAxisCount: ResponsiveHelper.isTabletDevice(context) ? 5 : 3,
      height: _gridItemHeight(context),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemBuilder: (final BuildContext context, final int index) {
      if (index >= categoryList.length) {
        return const CustomLoadingMoreContainer(isError: false);
      }
      return _categoryCard(categoryList[index]);
    },
  );

  Widget _categoryCard(final CategoryModel category) {
    final bool showServices = context
        .read<SystemSettingCubit>()
        .isCategoryDetailsViewTypeServices;
    final String count = showServices
        ? (category.totalServices ?? '0')
        : (category.totalProviders ?? '0');
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (category.totalProviders != '0' || category.childrenCount != '0') {
          UiUtils.navigateToCategoryDetails(
            context,
            categoryId: category.id,
            categoryName: category.name,
          );
        }
      },
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const CustomSizedBox(height: 2),
            CustomText(
              count.convertToInt() == 0
                  ? 'comingsoon'.translate(context: context)
                  : showServices
                  ? '$count ${count.convertToInt() > 1 ? 'services'.translate(context: context) : 'service'.translate(context: context)}'
                  : '$count ${count.convertToInt() > 1 ? 'providers'.translate(context: context) : 'provider'.translate(context: context)}',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerGrid() => GridView.builder(
    padding: EdgeInsetsDirectional.only(
      start: 16.rw(context),
      end: 16.rw(context),
      top: 24.rh(context),
    ),
    itemCount: UiUtils.numberOfShimmerContainer * 2,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
      crossAxisCount: ResponsiveHelper.isTabletDevice(context) ? 5 : 3,
      height: _gridItemHeight(context),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemBuilder: (final context, final index) =>
        const CustomShimmerLoadingContainer(borderRadius: 16),
  );
}
