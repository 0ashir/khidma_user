import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchResultMapScreen extends StatefulWidget {
  const SearchResultMapScreen({
    required this.showServices,
    required this.searchController,
    required this.onTapFilter,
    this.services = const [],
    this.providers = const [],
    super.key,
  });

  final bool showServices;
  final TextEditingController searchController;
  final VoidCallback onTapFilter;
  final List<Services> services;
  final List<Providers> providers;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => SearchResultMapScreen(
        showServices: arguments['showServices'] as bool? ?? true,
        searchController:
            arguments['searchController'] as TextEditingController,
        onTapFilter: arguments['onTapFilter'] as VoidCallback,
        services: (arguments['services'] as List<Services>?) ?? const [],
        providers: (arguments['providers'] as List<Providers>?) ?? const [],
      ),
    );
  }

  @override
  State<SearchResultMapScreen> createState() => _SearchResultMapScreenState();
}

class _SearchResultMapScreenState extends State<SearchResultMapScreen> {
  static const double _cardSpacing = 12;
  static const double _providerCardWidth = 320;
  static const double _serviceCardWidth = 300;

  final ScrollController _cardsScrollController = ScrollController();
  AppMapController? _mapController;
  late final AppLatLng _initialCenter;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    final double latitude =
        double.tryParse(HiveRepository.getLatitude ?? '0') ?? 0.0;
    final double longitude =
        double.tryParse(HiveRepository.getLongitude ?? '0') ?? 0.0;
    _initialCenter = AppLatLng(latitude, longitude);
    _setMapStyle();
  }

  @override
  void dispose() {
    _cardsScrollController.dispose();
    super.dispose();
  }

  Future<void> _setMapStyle() async {
    final String assetPath =
        context.read<AppThemeCubit>().state.appTheme == AppTheme.dark
        ? 'assets/mapTheme/darkMap.json'
        : 'assets/mapTheme/lightMap.json';
    final String style = await rootBundle.loadString(assetPath);
    if (!mounted) return;
    setState(() => _mapStyle = style);
  }

  void _focusItem(
    final int index,
    final double latitude,
    final double longitude,
    final double cardWidth,
  ) {
    _mapController?.animateTo(AppLatLng(latitude, longitude), zoom: 15);
    if (_cardsScrollController.hasClients) {
      _cardsScrollController.animateTo(
        (index * (cardWidth + _cardSpacing)).clamp(
          0,
          _cardsScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  AppMapMarker _pricePinMarker({
    required final String id,
    required final double latitude,
    required final double longitude,
    required final String price,
    required final VoidCallback onTap,
  }) => AppMapMarker(
    id: id,
    position: AppLatLng(latitude, longitude),
    googleIcon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
    infoWindowTitle: price,
    onTap: onTap,
    osmChild: _PricePin(price: price),
  );

  List<AppMapMarker> _providerMarkers(final List<Providers> providers) {
    final List<AppMapMarker> markers = [];
    for (int i = 0; i < providers.length; i++) {
      final Providers provider = providers[i];
      final double? latitude = double.tryParse(provider.latitude ?? '');
      final double? longitude = double.tryParse(provider.longitude ?? '');
      if (latitude == null || longitude == null) continue;
      markers.add(
        _pricePinMarker(
          id: 'provider_${provider.id}',
          latitude: latitude,
          longitude: longitude,
          price: (provider.startingPrice ?? '0').countryPriceFormat(context),
          onTap: () => _focusItem(i, latitude, longitude, _providerCardWidth),
        ),
      );
    }
    return markers;
  }

  List<AppMapMarker> _serviceMarkers(final List<Services> services) {
    final List<AppMapMarker> markers = [];
    for (int i = 0; i < services.length; i++) {
      final Services service = services[i];
      final double? latitude = double.tryParse(service.latitude ?? '');
      final double? longitude = double.tryParse(service.longitude ?? '');
      if (latitude == null || longitude == null) continue;
      final String price = (service.discountedPrice ?? service.price ?? '0')
          .countryPriceFormat(context);
      markers.add(
        _pricePinMarker(
          id: 'service_${service.id}',
          latitude: latitude,
          longitude: longitude,
          price: price,
          onTap: () => _focusItem(i, latitude, longitude, _serviceCardWidth),
        ),
      );
    }
    return markers;
  }

  Widget _listButton(final BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 16),
    child: CustomInkWellContainer(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.pop(context),
      child: CustomContainer(
        color: context.colors.backgroundSecondary,
        border: Border.all(color: context.colors.borderDefault),
        borderRadius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.list,
              height: 18,
              width: 18,
              color: context.colors.iconPrimary,
            ),
            CustomText(
              'list'.translate(context: context),
              fontSize: 14,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _quickFilterRow(final BuildContext context) => CustomContainer(
    width: double.infinity,
    color: context.colors.backgroundPrimary,
    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
    child: Row(
      spacing: 12,
      children: [
        Expanded(
          child: CustomContainer(
            height: 48,
            color: context.colors.backgroundSecondary,
            border: Border.all(color: context.colors.borderDefault),
            borderRadius: UiUtils.borderRadiusOf8,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            avoideResponsive: true,
            child: Row(
              spacing: 12,
              children: [
                CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: AppAssets.search,
                  height: 24,
                  width: 24,
                  color: context.colors.iconPrimary,
                ),
                Expanded(
                  child: TextField(
                    controller: widget.searchController,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: widget.showServices
                          ? 'searchServices'.translate(context: context)
                          : 'searchProviders'.translate(context: context),
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
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTapFilter,
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

  Widget _providerCarousel(final List<Providers> providers) {
    if (providers.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      controller: _cardsScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _cardSpacing,
          children: [
            for (final Providers provider in providers)
              SizedBox(
                width: _providerCardWidth,
                child: ProviderCard(providerDetails: provider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCarousel(final List<Services> services) {
    if (services.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      controller: _cardsScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _cardSpacing,
          children: [
            for (final Services service in services) _serviceCard(service),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(final Services service) {
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
        width: 324,
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

  @override
  Widget build(final BuildContext context) {
    final List<Providers> providerList = widget.providers;
    final List<Services> serviceList = widget.services;

    final List<AppMapMarker> markers = widget.showServices
        ? _serviceMarkers(serviceList)
        : _providerMarkers(providerList);

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
            elevation: 0,
            actions: [_listButton(context)],
          ),
          body: Stack(
            children: [
              AppMapView(
                googleMapStyle: _mapStyle,
                zoomControlsEnabled: false,
                markers: markers,
                initialCenter: _initialCenter,
                initialZoom: 13,
                onMapReady: (controller) => _mapController = controller,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: _quickFilterRow(context),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: UiUtils.getScrollViewBottomPadding(context),
                    ),
                    child: widget.showServices
                        ? _serviceCarousel(serviceList)
                        : _providerCarousel(providerList),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricePin extends StatelessWidget {
  const _PricePin({required this.price});

  final String price;

  @override
  Widget build(final BuildContext context) => OverflowBox(
    minWidth: 0,
    minHeight: 0,
    maxWidth: 100,
    maxHeight: 80,
    alignment: Alignment.bottomCenter,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          padding: const EdgeInsets.all(8),
          color: context.colors.backgroundBrand,
          shape: BoxShape.circle,
          child: const Icon(
            Icons.construction_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const CustomSizedBox(height: 4),
        CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: context.colors.backgroundPrimary,
          borderRadius: 8,
          boxShadow: [
            BoxShadow(
              color: context.colors.overlayHeaderShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          child: CustomText(
            price,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
