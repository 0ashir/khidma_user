import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryServicesScreen extends StatefulWidget {
  const CategoryServicesScreen({
    required this.categoryId,
    required this.categoryName,
    super.key,
  });

  final String categoryId;
  final String categoryName;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => BlocProvider<CategoryServicesCubit>(
        create: (final _) => CategoryServicesCubit(ServiceRepository()),
        child: CategoryServicesScreen(
          categoryId: arguments['categoryId']?.toString() ?? '',
          categoryName: arguments['categoryName']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  State<CategoryServicesScreen> createState() => _CategoryServicesScreenState();
}

class _CategoryServicesScreenState extends State<CategoryServicesScreen> {
  late Future<Map<String, dynamic>> _topLevelSubCategoriesFuture;
  late Future<Map<String, dynamic>> _subCategoriesFuture;
  final TextEditingController _mapSearchController = TextEditingController();

  final List<SubCategory> _drillPath = [];

  String? _selectedLeafSubCategoryId;
  CategoryServicesFetchSuccess? _lastServicesSuccess;

  String get _appBarTitle =>
      _drillPath.isEmpty ? widget.categoryName : _drillPath.last.name ?? '';

  String get _currentContainerId =>
      _drillPath.isEmpty ? widget.categoryId : _drillPath.last.id ?? '';

  String get _effectiveCategoryId =>
      _selectedLeafSubCategoryId ?? _currentContainerId;

  void _onTapSubCategory(final SubCategory subCategory) {
    if (subCategory.childrenCount != '0') {
      setState(() {
        _drillPath.add(subCategory);
        _selectedLeafSubCategoryId = null;
        _subCategoriesFuture = SubCategoryRepository().fetchSubCategory(
          isAuthTokenRequired: false,
          categoryID: subCategory.id ?? '',
        );
      });
    } else {
      final bool isDeselecting = _selectedLeafSubCategoryId == subCategory.id;
      setState(() {
        _selectedLeafSubCategoryId = isDeselecting ? null : subCategory.id;
      });
    }
    context.read<CategoryServicesCubit>().fetchServices(
      categoryId: _effectiveCategoryId,
    );
  }

  bool _handleBackPress() {
    if (_drillPath.isEmpty) return false;
    setState(() {
      _drillPath.removeLast();
      _selectedLeafSubCategoryId = null;
      _subCategoriesFuture = _drillPath.isEmpty
          ? _topLevelSubCategoriesFuture
          : SubCategoryRepository().fetchSubCategory(
              isAuthTokenRequired: false,
              categoryID: _drillPath.last.id ?? '',
            );
    });
    context.read<CategoryServicesCubit>().fetchServices(
      categoryId: _effectiveCategoryId,
    );
    return true;
  }

  @override
  void initState() {
    super.initState();
    context.read<CategoryServicesCubit>().fetchServices(
      categoryId: _effectiveCategoryId,
    );
    _topLevelSubCategoriesFuture = SubCategoryRepository().fetchSubCategory(
      isAuthTokenRequired: false,
      categoryID: widget.categoryId,
    );
    _subCategoriesFuture = _topLevelSubCategoriesFuture;
  }

  @override
  void dispose() {
    _mapSearchController.dispose();
    super.dispose();
  }

  void _openMap() {
    final CategoryServicesState state = context
        .read<CategoryServicesCubit>()
        .state;
    Navigator.pushNamed(
      context,
      searchResultMapScreen,
      arguments: {
        'showServices': true,
        'searchController': _mapSearchController,
        'onTapFilter': _showFilterBottomSheet,
        'services': state is CategoryServicesFetchSuccess
            ? state.services
            : <Services>[],
      },
    );
  }

  Future<void> _showFilterBottomSheet() async {
    final CategoryServicesCubit cubit = context.read<CategoryServicesCubit>();
    final CategoryServicesState cubitState = cubit.state;
    final double maxPrice = cubitState is CategoryServicesFetchSuccess
        ? (double.tryParse(cubitState.serviceMaxPrice ?? '') ?? 2000.0)
        : 2000.0;
    final double minPrice = cubitState is CategoryServicesFetchSuccess
        ? (double.tryParse(cubitState.serviceMinPrice ?? '') ?? 0.0)
        : 0.0;

    final Object? result = await UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: FilterBottomSheet(
        maxPrice: maxPrice,
        minPrice: minPrice,
        currentFilter: cubit.currentFilter,
      ),
    );

    if (result is ServiceFilterModel && mounted) {
      await cubit.applyFilter(
        categoryId: _effectiveCategoryId,
        filter: result.isEmpty ? null : result,
      );
    }
  }

  Widget _quickFilterRow(final CategoryServicesCubit cubit) {
    final ServiceFilterModel? filter = cubit.currentFilter;
    final bool isFilterActive = filter != null && !filter.isEmpty;
    final bool isPayLater = filter?.payLaterAllowed ?? false;
    final bool isTopRated = filter?.sortBy == ServiceSortBy.topRated;

    return CategoryQuickFilterRow(
      chips: [
        CategoryQuickFilterChip(
          icon: AppAssets.sortFilter,
          label: "filter".translate(context: context),
          isSelected: isFilterActive,
          onTap: _showFilterBottomSheet,
        ),
        CategoryQuickFilterChip(
          label: "availableToday".translate(context: context),
          isSelected: cubit.availableTodayOnly,
          onTap: () =>
              cubit.toggleAvailableToday(categoryId: _effectiveCategoryId),
        ),
        CategoryQuickFilterChip(
          label: "topRated".translate(context: context),
          isSelected: isTopRated,
          onTap: () => cubit.toggleTopRated(categoryId: _effectiveCategoryId),
        ),
        CategoryQuickFilterChip(
          label: "under1Hour".translate(context: context),
          isSelected: cubit.under1HourOnly,
          onTap: () => cubit.toggleUnder1Hour(categoryId: _effectiveCategoryId),
        ),
        CategoryQuickFilterChip(
          label: "payLater".translate(context: context),
          isSelected: isPayLater,
          onTap: () => cubit.togglePayLater(categoryId: _effectiveCategoryId),
        ),
      ],
    );
  }

  Widget _serviceItem(final Services service) {
    final String? serviceProviderName =
        (service.translatedPartnerName ?? '').isNotEmpty
        ? service.translatedPartnerName
        : ((service.companyName ?? '').isNotEmpty
              ? service.companyName
              : service.partnerName);
    // ServiceCard's "already added" quantity is computed with
    // context.read<CartCubit>() (not watch), so it only reflects cart
    // changes when something forces this widget to rebuild. This screen's
    // list only rebuilds on CategoryServicesCubit changes, not CartCubit —
    // wrap here so tapping Add updates the qty stepper immediately.
    return BlocBuilder<CartCubit, CartState>(
      builder: (final context, final _) => ServiceCard(
        serviceId: service.id ?? '',
        providerId: service.userId ?? '0',
        title: service.translatedTitle,
        image: service.imageOfTheService,
        price: service.price,
        discountedPrice: service.discountedPrice,
        discountPercentage: service.discountPercentage,
        duration: service.duration,
        durationType: service.durationType,
        numberOfMembersRequired: service.numberOfMembersRequired,
        averageRating: service.averageRating ?? service.rating,
        maximumAllowedQuantity:
            int.tryParse(service.maxQuantityAllowed ?? '0') ?? 0,
        companyName: service.companyName,
        isProviderVerified: service.isProviderVerified ?? false,
        isBookmarked: service.isBookmarked,
        serviceProviderName: serviceProviderName,
        showBorder: false,
        onTap: () {
          Navigator.pushNamed(
            context,
            providerServiceDetails,
            arguments: {
              'serviceDetails': service,
              'serviceId': service.id ?? '',
              'providerId': service.userId ?? '0',
            },
          );
        },
      ),
    );
  }

  // Tablet shows 2-column cards (20 gap); phone keeps the single column.
  Widget _cardList(final BuildContext context, final List<Widget> cards) =>
      ResponsiveHelper.isTabletDevice(context)
      ? EqualHeightGrid(spacing: 20, children: cards)
      : Column(spacing: 12, children: cards);

  @override
  Widget build(
    final BuildContext context,
  ) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: UiUtils.getSystemUiOverlayStyle(context: context),
    child: PopScope(
      canPop: _drillPath.isEmpty,
      onPopInvokedWithResult: (final didPop, final _) {
        if (!didPop) _handleBackPress();
      },
      child: AnnotatedSafeArea(
        isAnnotated: true,
        applyBottomInset: false,
        child: Scaffold(
          appBar: CategoryDetailsAppBar.build(
            context: context,
            title: _appBarTitle,
            onTapMap: _openMap,
            onLeadingTap: _drillPath.isNotEmpty
                ? () {
                    if (!_handleBackPress()) Navigator.pop(context);
                  }
                : null,
            subtitle: BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
              builder: (final context, final state) {
                if (state is CategoryServicesFetchSuccess) {
                  _lastServicesSuccess = state;
                }
                final CategoryServicesFetchSuccess? success =
                    _lastServicesSuccess;
                if (success == null) return const CustomSizedBox();
                final String? startingFrom = success.serviceMinPrice;
                return Row(
                  children: [
                    CustomText(
                      '${success.totalServices} ${'services'.translate(context: context)}',
                      maxLines: 1,
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                    if ((startingFrom ?? '0') != '0') ...[
                      const CustomSizedBox(width: 8),
                      CustomContainer(
                        height: 8,
                        width: 8,
                        shape: BoxShape.circle,
                        color: context.colors.backgroundTertiary,
                      ),
                      const CustomSizedBox(width: 8),
                      Flexible(
                        child: CustomText(
                          '${'startingFrom'.translate(context: context)} ${startingFrom!.countryPriceFormat(context)}',
                          maxLines: 1,
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            filterRow:
                BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
                  builder: (final context, final state) =>
                      _quickFilterRow(context.read<CategoryServicesCubit>()),
                ),
          ),
          body: CustomContainer(
            color: context.colors.backgroundSecondary,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _subCategoriesFuture,
                    builder: (final context, final snapshot) {
                      final List<SubCategory> subCategories =
                          (snapshot.data?['subCategoryList']
                              as List<SubCategory>?) ??
                          [];
                      return CategorySubCategoryRow(
                        subCategories: subCategories,
                        selectedSubCategoryId: _selectedLeafSubCategoryId,
                        onTapSubCategory: _onTapSubCategory,
                      );
                    },
                  ),
                ),
                Expanded(
                  child:
                      BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
                        builder: (final context, final state) {
                          if (state is CategoryServicesFetchFailure) {
                            return ErrorContainer(
                              errorMessage: state.errorMessage.translate(
                                context: context,
                              ),
                              showRetryButton: true,
                              onTapRetry: () => context
                                  .read<CategoryServicesCubit>()
                                  .fetchServices(
                                    categoryId: _effectiveCategoryId,
                                  ),
                            );
                          }
                          if (state is! CategoryServicesFetchSuccess) {
                            return Center(
                              child: CustomCircularProgressIndicator(
                                color: context.colors.iconBrand,
                              ),
                            );
                          }
                          if (state.services.isEmpty) {
                            return Center(
                              child: NoDataFoundWidget(
                                titleKey: "noServicesAvailable".translate(
                                  context: context,
                                ),
                                subtitleKey: "noServicesFoundSubTitle"
                                    .translate(context: context),
                              ),
                            );
                          }
                          return CustomRefreshIndicator(
                            displacment: 12,
                            onRefreshCallback: () => context
                                .read<CategoryServicesCubit>()
                                .fetchServices(
                                  categoryId: _effectiveCategoryId,
                                ),
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (final scrollInfo) {
                                if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                                  if (context
                                      .read<CategoryServicesCubit>()
                                      .hasMoreServices()) {
                                    context
                                        .read<CategoryServicesCubit>()
                                        .fetchMoreServices(
                                          categoryId: _effectiveCategoryId,
                                        );
                                  }
                                }
                                return true;
                              },
                              child: ListView(
                                padding: EdgeInsetsDirectional.only(
                                  top: 12,
                                  bottom: UiUtils.getScrollViewBottomPadding(
                                    context,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: CustomText(
                                      'recommendedForYou'.translate(
                                        context: context,
                                      ),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const CustomSizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: _cardList(
                                      context,
                                      state.services.map(_serviceItem).toList(),
                                    ),
                                  ),
                                  if (state.isLoadingMore)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: CustomCircularProgressIndicator(
                                          color: context.colors.iconBrand,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CartSubDetailsContainer(),
        ),
      ),
    ),
  );
}
