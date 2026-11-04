import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryProvidersScreen extends StatefulWidget {
  const CategoryProvidersScreen({
    required this.categoryId,
    required this.categoryName,
    super.key,
  });

  final String categoryId;
  final String categoryName;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => BlocProvider<SubCategoryAndProviderCubit>(
        create: (final _) => SubCategoryAndProviderCubit(
          subCategoryRepository: SubCategoryRepository(),
          providerRepository: ProviderRepository(),
        ),
        child: CategoryProvidersScreen(
          categoryId: arguments['categoryId']?.toString() ?? '',
          categoryName: arguments['categoryName']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  State<CategoryProvidersScreen> createState() =>
      _CategoryProvidersScreenState();
}

class _CategoryProvidersScreenState extends State<CategoryProvidersScreen> {
  final TextEditingController _mapSearchController = TextEditingController();
  ProviderFilterModel? _filter;
  bool _availableTodayOnly = false;
  bool _under1HourOnly = false;

  final List<SubCategory> _drillPath = [];

  String? _selectedLeafSubCategoryId;
  SubCategoryAndProviderFetchSuccess? _lastProvidersSuccess;

  String get _appBarTitle =>
      _drillPath.isEmpty ? widget.categoryName : _drillPath.last.name ?? '';

  String get _currentContainerId =>
      _drillPath.isEmpty ? widget.categoryId : _drillPath.last.id ?? '';

  String get _effectiveCategoryId =>
      _selectedLeafSubCategoryId ?? _currentContainerId;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _mapSearchController.dispose();
    super.dispose();
  }

  void _openMap() {
    final SubCategoryAndProviderState state = context
        .read<SubCategoryAndProviderCubit>()
        .state;
    Navigator.pushNamed(
      context,
      searchResultMapScreen,
      arguments: {
        'showServices': false,
        'searchController': _mapSearchController,
        'onTapFilter': _showFilterBottomSheet,
        'providers': state is SubCategoryAndProviderFetchSuccess
            ? state.providerList
            : <Providers>[],
      },
    );
  }

  void _fetch() {
    final SubCategoryAndProviderCubit cubit = context
        .read<SubCategoryAndProviderCubit>();
    if (_selectedLeafSubCategoryId != null) {
      cubit.fetchProvidersForSubCategory(
        categoryID: _effectiveCategoryId,
        availableToday: _availableTodayOnly ? 1 : null,
        maxDuration: _under1HourOnly ? 60 : null,
        sortBy: _filter?.apiSortBy,
        ratingMin: _filter?.apiRatingMin,
        providerType: _filter?.apiProviderType,
        priceMax: _filter?.apiPriceMax,
      );
    } else {
      cubit.getSubCategoriesAndProviderList(
        categoryID: _effectiveCategoryId,
        availableToday: _availableTodayOnly ? 1 : null,
        maxDuration: _under1HourOnly ? 60 : null,
        sortBy: _filter?.apiSortBy,
        ratingMin: _filter?.apiRatingMin,
        providerType: _filter?.apiProviderType,
        priceMax: _filter?.apiPriceMax,
      );
    }
  }

  void _onTapSubCategory(final SubCategory subCategory) {
    if (subCategory.childrenCount != '0') {
      setState(() {
        _drillPath.add(subCategory);
        _selectedLeafSubCategoryId = null;
      });
    } else {
      final bool isDeselecting = _selectedLeafSubCategoryId == subCategory.id;
      setState(() {
        _selectedLeafSubCategoryId = isDeselecting ? null : subCategory.id;
      });
    }
    _fetch();
  }

  bool _handleBackPress() {
    if (_drillPath.isEmpty) return false;
    setState(() {
      _drillPath.removeLast();
      _selectedLeafSubCategoryId = null;
    });
    _fetch();
    return true;
  }

  Future<void> _showFilterBottomSheet() async {
    final SubCategoryAndProviderCubit cubit = context
        .read<SubCategoryAndProviderCubit>();
    final SubCategoryAndProviderState cubitState = cubit.state;
    final double maxPrice = cubitState is SubCategoryAndProviderFetchSuccess
        ? (double.tryParse(cubitState.serviceMaxPrice ?? '') ?? 2000.0)
        : 2000.0;
    final double minPrice = cubitState is SubCategoryAndProviderFetchSuccess
        ? (double.tryParse(cubitState.serviceMinPrice ?? '') ?? 0.0)
        : 0.0;

    final Object? result = await UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: ProviderFilterBottomSheet(
        maxPrice: maxPrice,
        minPrice: minPrice,
        currentFilter: _filter,
      ),
    );

    if (result is ProviderFilterModel && mounted) {
      setState(() => _filter = result.isEmpty ? null : result);
      _fetch();
    }
  }

  void _toggleTopRated() {
    final bool isActive = _filter?.sortBy == ProviderSortBy.topRated;
    setState(() {
      _filter = (_filter ?? const ProviderFilterModel()).copyWith(
        sortBy: isActive ? null : ProviderSortBy.topRated,
        clearSort: isActive,
      );
    });
    _fetch();
  }

  Widget _quickFilterRow() {
    final bool isFilterActive = _filter != null && !_filter!.isEmpty;
    final bool isTopRated = _filter?.sortBy == ProviderSortBy.topRated;

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
          isSelected: _availableTodayOnly,
          onTap: () {
            setState(() => _availableTodayOnly = !_availableTodayOnly);
            _fetch();
          },
        ),
        CategoryQuickFilterChip(
          label: "topRated".translate(context: context),
          isSelected: isTopRated,
          onTap: _toggleTopRated,
        ),
        CategoryQuickFilterChip(
          label: "under1Hour".translate(context: context),
          isSelected: _under1HourOnly,
          onTap: () {
            setState(() => _under1HourOnly = !_under1HourOnly);
            _fetch();
          },
        ),
      ],
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
            subtitle:
                BlocBuilder<
                  SubCategoryAndProviderCubit,
                  SubCategoryAndProviderState
                >(
                  builder: (final context, final state) {
                    if (state is SubCategoryAndProviderFetchSuccess) {
                      _lastProvidersSuccess = state;
                    }
                    final SubCategoryAndProviderFetchSuccess? success =
                        _lastProvidersSuccess;
                    if (success == null) return const CustomSizedBox();
                    final String? startingFrom = success.serviceMinPrice;
                    return Row(
                      children: [
                        CustomText(
                          '${success.totalProviders} ${'providers'.translate(context: context)}',
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
            filterRow: _quickFilterRow(),
          ),
          body: CustomContainer(
            color: context.colors.backgroundSecondary,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child:
                      BlocBuilder<
                        SubCategoryAndProviderCubit,
                        SubCategoryAndProviderState
                      >(
                        builder: (final context, final state) {
                          if (state is SubCategoryAndProviderFetchSuccess) {
                            _lastProvidersSuccess = state;
                          }
                          return CategorySubCategoryRow(
                            subCategories:
                                _lastProvidersSuccess?.subCategoryList ?? [],
                            selectedSubCategoryId: _selectedLeafSubCategoryId,
                            onTapSubCategory: _onTapSubCategory,
                          );
                        },
                      ),
                ),
                Expanded(
                  child:
                      BlocBuilder<
                        SubCategoryAndProviderCubit,
                        SubCategoryAndProviderState
                      >(
                        builder: (final context, final state) {
                          if (state is SubCategoryAndProviderFetchFailure) {
                            return ErrorContainer(
                              errorMessage: state.errorMessage.translate(
                                context: context,
                              ),
                              showRetryButton: true,
                              onTapRetry: _fetch,
                            );
                          }
                          if (state is! SubCategoryAndProviderFetchSuccess) {
                            return Center(
                              child: CustomCircularProgressIndicator(
                                color: context.colors.iconBrand,
                              ),
                            );
                          }
                          if (state.providerList.isEmpty) {
                            return Center(
                              child: NoDataFoundWidget(
                                titleKey: 'noProvidersFound'.translate(
                                  context: context,
                                ),
                                subtitleKey: 'noProvidersFoundSubTitle'
                                    .translate(context: context),
                              ),
                            );
                          }
                          return CustomRefreshIndicator(
                            displacment: 12,
                            onRefreshCallback: () async => _fetch(),
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
                                    state.providerList
                                        .map(
                                          (final provider) => ProviderCard(
                                            providerDetails: provider,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
