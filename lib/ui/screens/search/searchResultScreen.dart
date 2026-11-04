import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({required this.initialSearch, super.key});

  final String initialSearch;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => MultiBlocProvider(
        providers: [
          BlocProvider<CategoryServicesCubit>(
            create: (final _) => CategoryServicesCubit(ServiceRepository()),
          ),
          BlocProvider<SearchProvidersResultCubit>(
            create: (final _) =>
                SearchProvidersResultCubit(ProviderRepository()),
          ),
        ],
        child: SearchResultScreen(
          initialSearch: arguments['search']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialSearch,
  );
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  final ScrollController _servicesScrollController = ScrollController();
  final ScrollController _providersScrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search(widget.initialSearch);
    _tabController.addListener(() => setState(() {}));
    _servicesScrollController.addListener(_fetchMoreServicesOnScroll);
    _providersScrollController.addListener(_fetchMoreProvidersOnScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _servicesScrollController.removeListener(_fetchMoreServicesOnScroll);
    _servicesScrollController.dispose();
    _providersScrollController.removeListener(_fetchMoreProvidersOnScroll);
    _providersScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool get _isTablet => ResponsiveHelper.isTabletDevice(context);

  // Tablet shows 2-column cards (20 gap) from Figma; phone keeps the
  // single-column list.
  Widget _cardList(final List<Widget> cards) => _isTablet
      ? EqualHeightGrid(spacing: 20, children: cards)
      : Column(spacing: 12, children: cards);

  void _search(final String query) {
    context.read<CategoryServicesCubit>().fetchServices(search: query);
    context.read<SearchProvidersResultCubit>().search(query);
  }

  List<Services> _currentServices() {
    final CategoryServicesState state = context
        .read<CategoryServicesCubit>()
        .state;
    return state is CategoryServicesFetchSuccess ? state.services : [];
  }

  List<Providers> _currentProviders() {
    final SearchProvidersResultState state = context
        .read<SearchProvidersResultCubit>()
        .state;
    return state is SearchProvidersResultFetchSuccess ? state.providerList : [];
  }

  void _onSearchChanged() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      HiveRepository.addRecentCategorySearch(_searchController.text.trim());
      _search(_searchController.text.trim());
    });
  }

  void _fetchMoreServicesOnScroll() {
    if (!context.read<CategoryServicesCubit>().hasMoreServices()) return;
    if (!_servicesScrollController.hasClients) return;
    if (_servicesScrollController.position.pixels >=
        _servicesScrollController.position.maxScrollExtent - 200) {
      context.read<CategoryServicesCubit>().fetchMoreServices(
        search: _searchController.text.trim(),
      );
    }
  }

  void _fetchMoreProvidersOnScroll() {
    if (!context.read<SearchProvidersResultCubit>().hasMore()) return;
    if (!_providersScrollController.hasClients) return;
    if (_providersScrollController.position.pixels >=
        _providersScrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvidersResultCubit>().fetchMore();
    }
  }

  Future<void> _showFilterBottomSheet() async {
    if (_tabController.index == 0) {
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
          search: _searchController.text.trim(),
          filter: result.isEmpty ? null : result,
        );
      }
    } else {
      final SearchProvidersResultCubit cubit = context
          .read<SearchProvidersResultCubit>();
      final SearchProvidersResultState cubitState = cubit.state;
      final double maxPrice = cubitState is SearchProvidersResultFetchSuccess
          ? (double.tryParse(cubitState.serviceMaxPrice ?? '') ?? 2000.0)
          : 2000.0;
      final double minPrice = cubitState is SearchProvidersResultFetchSuccess
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
          currentFilter: cubit.currentFilter,
        ),
      );
      if (result is ProviderFilterModel && mounted) {
        await cubit.applyFilter(result.isEmpty ? null : result);
      }
    }
  }

  Widget _searchAndFilterRow() => CustomContainer(
    color: context.colors.backgroundPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    boxShadow: [
      BoxShadow(
        color: context.colors.overlayHeaderShadow,
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
    child: Row(
      spacing: 12,
      children: [
        Expanded(
          child: CustomContainer(
            height: 48,
            avoideResponsive: true,
            color: context.colors.backgroundSecondary,
            borderRadius: UiUtils.borderRadiusOf8,
            border: Border.all(color: context.colors.borderBrand),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: AppAssets.search,
                  height: 24,
                  width: 24,
                  color: context.colors.iconPrimary,
                ),
                const CustomSizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: widget.initialSearch.isEmpty,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'startTyping'.translate(context: context),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  CustomInkWellContainer(
                    onTap: () => _searchController.clear(),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: context.colors.iconSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(12),
          onTap: _showFilterBottomSheet,
          child: CustomContainer(
            color: context.colors.backgroundSecondary,
            border: Border.all(color: context.colors.borderDefault),
            borderRadius: UiUtils.borderRadiusOf12,
            padding: const EdgeInsets.all(12),
            child: CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.sortFilter,
              height: 24,
              width: 24,
              color: context.colors.iconPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tabBar() => TopRoundedUnderlineTabBar(
    controller: _tabController,
    tabHeight: 40,
    boxShadow: [
      BoxShadow(
        blurRadius: 16,
        offset: const Offset(0, 8),
        color: context.colors.overlayHeaderShadow,
      ),
    ],
    border: Border(
      bottom: BorderSide(color: context.colors.borderMuted, width: 1.5),
    ),
    tabs: [
      Text('services'.translate(context: context)),
      Text('providers'.translate(context: context)),
    ],
  );

  Widget _serviceItem(final Services service) {
    final String? serviceProviderName =
        (service.translatedPartnerName ?? '').isNotEmpty
        ? service.translatedPartnerName
        : ((service.companyName ?? '').isNotEmpty
              ? service.companyName
              : service.partnerName);
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

  Widget _servicesTab() =>
      BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
        builder: (final context, final state) {
          if (state is CategoryServicesFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              showRetryButton: true,
              onTapRetry: () => _search(_searchController.text.trim()),
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
                titleKey: 'noResultFound'.translate(context: context),
                subtitleKey: 'noServicesFoundSubTitle'.translate(
                  context: context,
                ),
              ),
            );
          }
          return CustomRefreshIndicator(
            displacment: 12,
            onRefreshCallback: () async =>
                _search(_searchController.text.trim()),
            child: ListView(
              controller: _servicesScrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                UiUtils.getScrollViewBottomPadding(context),
              ),
              children: [
                CustomText(
                  'exploreServices'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 12),
                _cardList(state.services.map(_serviceItem).toList()),
                if (state.isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CustomCircularProgressIndicator(
                        color: context.colors.iconBrand,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );

  Widget _providersTab() =>
      BlocBuilder<SearchProvidersResultCubit, SearchProvidersResultState>(
        builder: (final context, final state) {
          if (state is SearchProvidersResultFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              showRetryButton: true,
              onTapRetry: () => _search(_searchController.text.trim()),
            );
          }
          if (state is! SearchProvidersResultFetchSuccess) {
            return Center(
              child: CustomCircularProgressIndicator(
                color: context.colors.iconBrand,
              ),
            );
          }
          if (state.providerList.isEmpty) {
            return Center(
              child: NoDataFoundWidget(
                titleKey: 'noResultFound'.translate(context: context),
                subtitleKey: 'noProvidersFoundSubTitle'.translate(
                  context: context,
                ),
              ),
            );
          }
          return CustomRefreshIndicator(
            displacment: 12,
            onRefreshCallback: () async =>
                _search(_searchController.text.trim()),
            child: ListView(
              controller: _providersScrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                UiUtils.getScrollViewBottomPadding(context),
              ),
              children: [
                CustomText(
                  'exploreProviders'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 12),
                _cardList(
                  state.providerList
                      .map(
                        (final provider) =>
                            ProviderCard(providerDetails: provider),
                      )
                      .toList(),
                ),
                if (state.isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CustomCircularProgressIndicator(
                        color: context.colors.iconBrand,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );

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
              title: 'explore'.translate(context: context),
              fontWeight: FontWeight.w500,
              fontSize: 16,
              actions: [
                CategoryDetailsAppBar.mapButton(
                  context,
                  onTap: () => Navigator.pushNamed(
                    context,
                    searchResultMapScreen,
                    arguments: {
                      'showServices': _tabController.index == 0,
                      'searchController': _searchController,
                      'onTapFilter': _showFilterBottomSheet,
                      'services': _currentServices(),
                      'providers': _currentProviders(),
                    },
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(115),
                child: Column(children: [_searchAndFilterRow(), _tabBar()]),
              ),
            ),
            body: CustomContainer(
              color: context.colors.backgroundSecondary,
              child: TabBarView(
                controller: _tabController,
                children: [_servicesTab(), _providersTab()],
              ),
            ),
            bottomNavigationBar: const CartSubDetailsContainer(),
          ),
        ),
      );
}
