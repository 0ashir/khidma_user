import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProviderServiceSearchScreen extends StatefulWidget {
  const ProviderServiceSearchScreen({
    super.key,
    required this.providerId,
    required this.type,
    required this.isProviderAvailableAtLocation,
  });

  final String providerId;
  final ProviderDetailsParamType type;
  final String isProviderAvailableAtLocation;

  @override
  State<ProviderServiceSearchScreen> createState() =>
      _ProviderServiceSearchScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) =>
          BlocProvider<SearchProviderServicesCubit>.value(
            value: arguments['searchCubit'] as SearchProviderServicesCubit,
            child: ProviderServiceSearchScreen(
              providerId: arguments['providerId'] as String,
              type: arguments['type'] as ProviderDetailsParamType,
              isProviderAvailableAtLocation:
                  arguments['isProviderAvailableAtLocation'] as String? ?? '1',
            ),
          ),
    );
  }
}

class _ProviderServiceSearchScreenState
    extends State<ProviderServiceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  late final SearchProviderServicesCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchProviderServicesCubit>();
    WidgetsBinding.instance.addPostFrameCallback(
      (final _) => _searchFocusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCubit.resetSearch();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(final String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {});
    final String query = value.trim();
    if (query.isEmpty) {
      context.read<SearchProviderServicesCubit>().resetSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchProviderServicesCubit>().searchServices(
        providerId: widget.providerId,
        search: query,
        type: widget.type,
      );
    });
  }

  Widget _searchField(final BuildContext context) => CustomContainer(
    color: context.colors.backgroundSecondary,
    borderRadius: UiUtils.borderRadiusOf8,
    border: Border.all(color: context.colors.borderBrand),
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.search,
          height: 24,
          width: 24,
          color: context.colors.iconSecondary,
        ),
        const CustomSizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'searchServices'.translate(context: context),
              hintStyle: TextStyle(
                fontSize: 14,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          CustomInkWellContainer(
            onTap: () {
              _searchController.clear();
              _onSearchChanged('');
            },
            child: Icon(
              Icons.close,
              size: 24,
              color: context.colors.iconSecondary,
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
    return ServiceCard(
      serviceId: service.id ?? '',
      providerId: widget.providerId,
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
      isProviderAvailableAtLocation: widget.isProviderAvailableAtLocation,
      description: service.translatedDescription,
      companyName: service.companyName,
      showProviderName: false,
      isProviderVerified: service.isProviderVerified ?? false,
      isBookmarked: service.isBookmarked,
      serviceProviderName: serviceProviderName,
      showRatingAsBadge: true,
      imageHeight: 110,
      imageWidth: 80,
      onTap: () {
        Navigator.pushNamed(
          context,
          providerServiceDetails,
          arguments: {
            'serviceDetails': service,
            'serviceId': service.id ?? '',
            'providerId': widget.providerId,
            'isProviderAvailableAtLocation':
                widget.isProviderAvailableAtLocation,
          },
        );
      },
    );
  }

  Widget _resultsList(
    final BuildContext context,
    final SearchProviderServicesSuccess state,
  ) {
    final List<Services> services = state.serviceCategories
        .expand((final group) => group.services)
        .toList();
    final bool hasMore = context.read<SearchProviderServicesCubit>().hasMore();
    // Tablet shows 2-column cards (20 gap, same as the provider services tab);
    // phone keeps the single column. Each list row holds one grid row.
    final bool isTablet = ResponsiveHelper.isTabletDevice(context);
    final int columns = isTablet ? 2 : 1;
    final int rowCount = (services.length / columns).ceil();
    return NotificationListener<ScrollNotification>(
      onNotification: (final ScrollNotification scrollInfo) {
        if (hasMore &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          context.read<SearchProviderServicesCubit>().loadMore();
        }
        return true;
      },
      child: ListView.separated(
        padding: EdgeInsetsDirectional.only(
          top: 16.rh(context),
          start: 16.rw(context),
          end: 16.rw(context),
          bottom: UiUtils.getScrollViewBottomPadding(context),
        ),
        itemCount: rowCount + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (final _, final __) =>
            CustomSizedBox(height: isTablet ? 20 : 12.rh(context)),
        itemBuilder: (final BuildContext context, final int index) {
          if (index >= rowCount) {
            return Center(
              child: CustomCircularProgressIndicator(
                color: context.colors.iconBrand,
              ),
            );
          }
          if (!isTablet) return _serviceItem(context, services[index]);
          return EqualHeightGrid(
            spacing: 20,
            children: services
                .skip(index * columns)
                .take(columns)
                .map((final service) => _serviceItem(context, service))
                .toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: AppBar(
        systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
        surfaceTintColor: context.colors.backgroundPrimary,
        backgroundColor: context.colors.backgroundPrimary,
        shadowColor: context.colors.overlayHeaderShadow,
        elevation: 0,
        leading: UiUtils.getBackArrow(
          context,
          backgroundColor: context.colors.backgroundSecondary,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(64.rh(context)),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.backgroundPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayHeaderShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsetsDirectional.fromSTEB(
              16.rw(context),
              8.rh(context),
              16.rw(context),
              16.rh(context),
            ),
            child: _searchField(context),
          ),
        ),
      ),
      body:
          BlocBuilder<SearchProviderServicesCubit, SearchProviderServicesState>(
            builder:
                (
                  final BuildContext context,
                  final SearchProviderServicesState state,
                ) {
                  if (state is SearchProviderServicesInProgress) {
                    return Center(
                      child: CustomCircularProgressIndicator(
                        color: context.colors.iconBrand,
                      ),
                    );
                  }
                  if (state is SearchProviderServicesFailure) {
                    return Center(
                      child: ErrorContainer(
                        errorMessage: state.errorMessage.translate(
                          context: context,
                        ),
                        showRetryButton: true,
                        onTapRetry: () => context
                            .read<SearchProviderServicesCubit>()
                            .searchServices(
                              providerId: widget.providerId,
                              search: _searchController.text.trim(),
                              type: widget.type,
                            ),
                      ),
                    );
                  }
                  if (state is SearchProviderServicesSuccess) {
                    if (state.loadedServicesCount == 0) {
                      return Center(
                        child: NoDataFoundWidget(
                          titleKey: 'noResultFound'.translate(context: context),
                          subtitleKey: 'noServicesFoundSubTitle'.translate(
                            context: context,
                          ),
                        ),
                      );
                    }
                    return _resultsList(context, state);
                  }
                  return Center(
                    child: NoDataFoundWidget(
                      titleKey: 'typeToSearch'.translate(context: context),
                      subtitleKey: 'startTyping'.translate(context: context),
                    ),
                  );
                },
          ),
    ),
  );
}
