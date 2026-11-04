import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SectionDetailsScreen extends StatefulWidget {
  const SectionDetailsScreen({required this.sectionData, super.key});

  final Sections sectionData;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    final Sections sectionData = arguments['sectionData'] as Sections;
    final bool isProviderSection = sectionData.providers.isNotEmpty;
    return CupertinoPageRoute(
      builder: (final _) => isProviderSection
          ? BlocProvider<SearchProvidersResultCubit>(
              create: (final _) =>
                  SearchProvidersResultCubit(ProviderRepository()),
              child: SectionDetailsScreen(sectionData: sectionData),
            )
          : BlocProvider<CategoryServicesCubit>(
              create: (final _) => CategoryServicesCubit(ServiceRepository()),
              child: SectionDetailsScreen(sectionData: sectionData),
            ),
    );
  }

  @override
  State<SectionDetailsScreen> createState() => _SectionDetailsScreenState();
}

class _SectionDetailsScreenState extends State<SectionDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  bool get _isProviderSection => widget.sectionData.providers.isNotEmpty;
  bool get _isServiceSection => widget.sectionData.services.isNotEmpty;

  String? get _categoryWiseServiceCategoryId =>
      widget.sectionData.sectionType == 'category_wise_service'
      ? widget.sectionData.categoryId
      : null;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((final _) => _fetchInitial());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitial() {
    if (_isProviderSection) {
      final ProviderSortBy? sortBy =
          widget.sectionData.sectionType == 'top_rated_partner'
          ? ProviderSortBy.topRated
          : null;
      context.read<SearchProvidersResultCubit>().applyFilter(
        sortBy == null ? null : ProviderFilterModel(sortBy: sortBy),
      );
      return;
    }
    context.read<CategoryServicesCubit>().fetchServices(
      categoryId: _categoryWiseServiceCategoryId,
    );
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final String query = _searchController.text.trim();
      if (_isProviderSection) {
        context.read<SearchProvidersResultCubit>().search(query);
      } else {
        context.read<CategoryServicesCubit>().fetchServices(
          categoryId: _categoryWiseServiceCategoryId,
          search: query,
        );
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    if (_isProviderSection) {
      if (context.read<SearchProvidersResultCubit>().hasMore()) {
        context.read<SearchProvidersResultCubit>().fetchMore();
      }
    } else {
      if (context.read<CategoryServicesCubit>().hasMoreServices()) {
        context.read<CategoryServicesCubit>().fetchMoreServices(
          categoryId: _categoryWiseServiceCategoryId,
          search: _searchController.text.trim(),
        );
      }
    }
  }

  Future<void> _showProviderFilterBottomSheet(
    final BuildContext context,
  ) async {
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

  Future<void> _showServiceFilterBottomSheet(final BuildContext context) async {
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
        categoryId: _categoryWiseServiceCategoryId,
        search: _searchController.text.trim(),
        filter: result.isEmpty ? null : result,
      );
    }
  }

  Widget _searchFilterRow(final BuildContext context) => CustomContainer(
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
            color: context.colors.backgroundSecondary,
            borderRadius: UiUtils.borderRadiusOf8,
            border: Border.all(color: context.colors.borderDefault),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            avoideResponsive: true,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText:
                          (_isServiceSection
                                  ? 'searchServices'
                                  : 'searchProvider')
                              .translate(context: context),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: () => _isProviderSection
              ? _showProviderFilterBottomSheet(context)
              : _showServiceFilterBottomSheet(context),
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

  Widget _serviceItem(final BuildContext context, final Services service) {
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
        imageWidth: 55,
        imageHeight: 72,
        useDashedDivider: false,
        showBorder: false,
        addButtonBackgroundColor: context.colors.backgroundBrandSubtle,
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

  Widget _loadMoreIndicator(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: CustomCircularProgressIndicator(color: context.colors.iconBrand),
  );

  Widget _providerBody(final BuildContext context) =>
      BlocBuilder<SearchProvidersResultCubit, SearchProvidersResultState>(
        builder: (final context, final state) {
          if (state is SearchProvidersResultFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              showRetryButton: true,
              onTapRetry: _fetchInitial,
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
                titleKey: 'noProvidersFound'.translate(context: context),
              ),
            );
          }
          final String highlightStat =
              widget.sectionData.sectionType == 'top_rated_partner'
              ? 'rating'
              : 'distance';
          return ListView.separated(
            controller: _scrollController,
            padding: EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              top: 16,
              bottom: UiUtils.getScrollViewBottomPadding(context),
            ),
            itemCount:
                state.providerList.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (final _, final __) =>
                const CustomSizedBox(height: 12),
            itemBuilder: (final _, final index) {
              if (index >= state.providerList.length) {
                return _loadMoreIndicator(context);
              }
              return ProviderCard(
                providerDetails: state.providerList[index],
                width: 80,
                height: 80,
                highlightStat: highlightStat,
              );
            },
          );
        },
      );

  Widget _serviceBody(final BuildContext context) =>
      BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
        builder: (final context, final state) {
          if (state is CategoryServicesFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              showRetryButton: true,
              onTapRetry: _fetchInitial,
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
                titleKey: 'noServicesAvailable'.translate(context: context),
              ),
            );
          }
          return ListView.separated(
            controller: _scrollController,
            padding: EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              top: 16,
              bottom: UiUtils.getScrollViewBottomPadding(context),
            ),
            itemCount: state.services.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (final _, final __) =>
                const CustomSizedBox(height: 12),
            itemBuilder: (final _, final index) {
              if (index >= state.services.length) {
                return _loadMoreIndicator(context);
              }
              return _serviceItem(context, state.services[index]);
            },
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
              title: widget.sectionData.translatedTitle ?? '',
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(64.rh(context)),
                child: _searchFilterRow(context),
              ),
            ),
            body: CustomContainer(
              color: context.colors.backgroundSecondary,
              child: Column(
                children: [
                  Expanded(
                    child: _isProviderSection
                        ? _providerBody(context)
                        : _serviceBody(context),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _isServiceSection
                ? const CartSubDetailsContainer()
                : null,
          ),
        ),
      );
}
