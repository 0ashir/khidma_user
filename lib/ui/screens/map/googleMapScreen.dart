import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/fetchMapProviderCubit.dart';
import 'package:e_demand/cubits/fetchUserCurrentLocationCubit.dart';
import 'package:e_demand/ui/screens/map/widgets/mapSearchContainer.dart';
import 'package:e_demand/ui/screens/map/widgets/providerSlider.dart';
import 'package:e_demand/ui/screens/map/widgets/mapTitleWidget.dart';
import 'package:e_demand/ui/screens/map/widgets/serviceNotAvailableView.dart';
import 'package:e_demand/ui/screens/map/widgets/areaRequestSubmittedView.dart';
import 'package:e_demand/ui/screens/map/widgets/confirmAddressCard.dart';
import 'package:e_demand/ui/screens/map/utils/map_utils.dart';
import 'package:e_demand/ui/widgets/tooltipShapeBorder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

enum GoogleMapScreenType {
  providerOnMap,
  selectLocationOnMap;

  String get titleKey {
    switch (this) {
      case providerOnMap:
        return 'providerOnMap';
      case selectLocationOnMap:
        return 'selectLocationOnMap';
    }
  }
}

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({
    final Key? key,
    required this.showAddressForm,
    this.addressDetails,
    required this.defaultLatitude,
    required this.defaultLongitude,
    this.screenType = GoogleMapScreenType.selectLocationOnMap,
  }) : super(key: key);

  final bool showAddressForm;
  final GetAddressModel? addressDetails;
  final String defaultLatitude;
  final String defaultLongitude;
  final GoogleMapScreenType screenType;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map argument = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AddAddressCubit()),
          BlocProvider(create: (context) => FetchUserCurrentLocationCubit()),
          BlocProvider(
            create: (final context) => RequestAreaCoverageCubit(
              providerRepository: ProviderRepository(),
            ),
          ),
          BlocProvider(
            create: (final context) => CheckProviderAvailabilityCubit(
              providerRepository: ProviderRepository(),
            ),
          ),
          BlocProvider(
            create: (final context) =>
                FetchMapProviderCubit(ProviderRepository()),
          ),
          BlocProvider(create: (_) => GetCustomFieldsCubit()),
        ],
        child: Builder(
          builder: (context) => GoogleMapScreen(
            showAddressForm: argument['showAddressForm'] ?? false,
            addressDetails: argument['details'],
            defaultLatitude: argument["defaultLatitude"] ?? "0.0",
            defaultLongitude: argument["defaultLongitude"] ?? "0.0",
            screenType:
                argument["screenType"] ??
                GoogleMapScreenType.selectLocationOnMap,
          ),
        ),
      ),
    );
  }
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  //String lineOneAddress = '', lineTwoAddress = '';
  late AppLatLng initialCenter;

  ValueNotifier selectedAddress = ValueNotifier({
    "lineOneAddress": '',
    "lineTwoAddress": '',
    "selectedCity": '',
  });

  double? selectedLatitude, selectedLongitude;
  bool _areaRequestSubmitted = false;
  final ValueNotifier<bool> isResolvingAddress = ValueNotifier(false);
  //bumped on every createAddressFromCoOrdinates call so a slower, older
  //request can't overwrite a newer one that already resolved first
  int _addressRequestId = 0;

  late AppMapMarker initialLocation;

  final ValueNotifier<List<AppMapMarker>> mapMarkers = ValueNotifier([]);
  AppMapController? _mapController;
  bool _isOsm = false;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  String? mapStyle;

  final ValueNotifier<String> searchText = ValueNotifier('');

  // New ValueNotifiers for provider map functionality
  final ValueNotifier<GoogleMapScreenType> currentScreenType = ValueNotifier(
    GoogleMapScreenType.selectLocationOnMap,
  );
  final ValueNotifier<int> selectedProviderIndex = ValueNotifier(0);
  final CarouselSliderController providerCarouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    currentScreenType.value = widget.screenType;
    _isOsm = context.read<SystemSettingCubit>().isOpenStreetMap;
    setMapStyle();
    if (widget.screenType == GoogleMapScreenType.selectLocationOnMap) {
      // Warm the country list so the address sheet's picker fills instantly.
      AddressRepository().fetchCountries().ignore();
    }

    if (currentScreenType.value == GoogleMapScreenType.providerOnMap) {
      _initializeProvidersMap();
    } else {
      _initializeLocationMap();
    }

    // Fetch custom fields when the sheet opens
    context.read<GetCustomFieldsCubit>().fetchCustomFields(
      addressId: widget.addressDetails?.id,
    );

    searchText.addListener(() {
      context.read<FetchMapProviderCubit>().applySearchText(
        searchText.value.trim(),
      );
    });
  }

  void _initializeProvidersMap() {
    context.read<FetchMapProviderCubit>().fetchMapProviders(
      latitude: widget.defaultLatitude,
      longitude: widget.defaultLongitude,
    );

    selectedLatitude = double.parse(widget.defaultLatitude);
    selectedLongitude = double.parse(widget.defaultLongitude);

    // Set initial camera position to selected location
    initialCenter = AppLatLng(selectedLatitude!, selectedLongitude!);

    // Add listener to zoom to first provider when data loads
    context.read<FetchMapProviderCubit>().stream.listen((state) {
      if (state is FetchMapProviderFetchSuccess &&
          state.filteredProviderList.isNotEmpty) {
        // Zoom to first provider location
        final firstProvider = state.filteredProviderList.first;
        final double? latitude = double.tryParse(firstProvider.latitude ?? '');
        final double? longitude = double.tryParse(
          firstProvider.longitude ?? '',
        );
        if (latitude != null && longitude != null) {
          _zoomToProviderLocation(latitude, longitude);
        }
      }
    });
  }

  void _initializeLocationMap() {
    selectedLatitude = double.parse(widget.defaultLatitude);
    selectedLongitude = double.parse(widget.defaultLongitude);

    initialLocation = MapUtils.createLocationMarker(
      selectedLatitude!,
      selectedLongitude!,
    );

    checkProviderAvailability(
      latitude: widget.defaultLatitude,
      longitude: widget.defaultLongitude,
    );

    mapMarkers.value = [initialLocation];

    initialCenter = AppLatLng(selectedLatitude!, selectedLongitude!);

    createAddressFromCoOrdinates(selectedLatitude!, selectedLongitude!);

    // Ensure we zoom to the marker location after initialization
    Future.delayed(const Duration(milliseconds: 100), () {
      _zoomToMarkerLocation();
    });
  }

  void _updateProviderMarkers({required List<Providers> providers}) {
    mapMarkers.value = MapUtils.updateProviderMarkers(
      providers,
      mapMarkers.value,
      selectedProviderIndex,
      providerCarouselController,
    );
  }

  Future<void> _zoomToMarkerLocation() async {
    if (selectedLatitude == null || selectedLongitude == null) return;
    try {
      await _mapController?.animateTo(
        AppLatLng(selectedLatitude!, selectedLongitude!),
        zoom: 17,
      );
    } catch (_) {
      //the map can be unmounted mid-flight (e.g. swapped out for the
      //"service not available" view) — the map that replaces it re-zooms
      //itself via onMapReady, so a stale controller here is a no-op
    }
  }

  Future<void> _zoomToProviderLocation(
    double latitude,
    double longitude,
  ) async =>
      _mapController?.animateTo(AppLatLng(latitude, longitude), zoom: 14);

  Future<void> setMapStyle() async {
    if (context.read<AppThemeCubit>().state.appTheme == AppTheme.dark) {
      mapStyle = await rootBundle.loadString('assets/mapTheme/darkMap.json');
    } else {
      mapStyle = await rootBundle.loadString('assets/mapTheme/lightMap.json');
    }
  }

  Future<void> createAddressFromCoOrdinates(
    final double latitude,
    final double longitude,
  ) async {
    final int requestId = ++_addressRequestId;
    isResolvingAddress.value = true;
    try {
      _customInfoWindowController.hideInfoWindow?.call();
      final newAddress = await MapUtils.createAddressFromCoordinates(
        latitude,
        longitude,
      );
      //a newer call already started (and maybe already finished) while this
      //one was in flight — this result is stale, drop it
      if (requestId != _addressRequestId) return;
      selectedAddress.value = newAddress;
    } finally {
      //always clear, even if hideInfoWindow or geocoding throws — otherwise
      //the address card is stuck showing its loading shimmer forever
      if (requestId == _addressRequestId) {
        isResolvingAddress.value = false;
      }
    }
  }

  Future<void> checkProviderAvailability({
    required final String latitude,
    required final String longitude,
  }) async {
    //a fresh location check means any earlier "area request submitted"
    //confirmation no longer applies
    if (_areaRequestSubmitted) {
      setState(() => _areaRequestSubmitted = false);
    }
    context.read<CheckProviderAvailabilityCubit>().checkProviderAvailability(
      isAuthTokenRequired: false,
      checkingAtCheckOut: "0",
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> _placeMarkerOnLatitudeAndLongitude({
    required final double latitude,
    required final double longitude,
  }) async {
    selectedLatitude = latitude;
    selectedLongitude = longitude;

    final marker = MapUtils.createLocationMarker(
      latitude,
      longitude,
      onTap: _isOsm
          ? null
          : () => _customInfoWindowController.addInfoWindow!(
              _infoWindowContainer(),
              LatLng(latitude, longitude),
            ),
    );

    // Clear existing location markers first, then add the new red marker
    final otherMarkers = mapMarkers.value
        .where((existingMarker) => existingMarker.id != "1")
        .toList();
    mapMarkers.value = [...otherMarkers, marker];

    // Zoom to red marker location (queued automatically if the map isn't ready yet)
    await _zoomToMarkerLocation();

    await checkProviderAvailability(
      latitude: selectedLatitude.toString(),
      longitude: selectedLongitude.toString(),
    );
    await createAddressFromCoOrdinates(selectedLatitude!, selectedLongitude!);
  }

  void _switchToLocationSelectionMode() {
    currentScreenType.value = GoogleMapScreenType.selectLocationOnMap;
    _initializeLocationMap();
  }

  Container _infoWindowContainer() => Container(
    decoration: ShapeDecoration(
      color: context.colors.textPrimary,
      shape: const TooltipShapeBorder(radius: 10),
      shadows: const [
        BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(2, 2)),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          'yourServiceWillHere'.translate(context: context),
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: context.colors.surfaceElevated,
        ),
        CustomText(
          'movePinToLocation'.translate(context: context),
          fontSize: 10,
          color: context.colors.textSecondary,
        ),
      ],
    ),
  );

  void _showAddressSheet(final BuildContext context) {
    UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: CustomContainer(
        padding: EdgeInsetsDirectional.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AddAddressCubit>()),
            BlocProvider.value(value: context.read<GetCustomFieldsCubit>()),
          ],
          child: Builder(
            builder: (final context) {
              final String userMobileNumber =
                  "${HiveRepository.getUserMobileNumber}";
              return AddressSheet(
                addressDataModel: AddressModel(
                  latitude: selectedLatitude.toString(),
                  longitude: selectedLongitude.toString(),
                  addressId: widget.addressDetails?.id,
                  address: widget.addressDetails?.address,
                  mobile: widget.addressDetails?.mobile ?? userMobileNumber,
                  type: widget.addressDetails?.type ?? '',
                  isDefault: widget.addressDetails?.isDefault ?? "0",
                  countryId: widget.addressDetails?.countryId,
                  regionId: widget.addressDetails?.regionId,
                ),
                isUpdateAddress: widget.addressDetails == null ? false : true,
                addressId: widget.addressDetails == null
                    ? null
                    : widget.addressDetails!.id,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        backgroundColor: context.colors.backgroundPrimary,
        titleWidget: MapTitleWidget(
          currentScreenType: currentScreenType,
          showAddressForm: widget.showAddressForm,
        ),
        actions: currentScreenType.value == GoogleMapScreenType.providerOnMap
            ? [
                CustomInkWellContainer(
                  onTap: () {
                    Navigator.pushNamed(context, setLocationRoute).then((
                      final result,
                    ) {
                      final Map? value = result as Map?;
                      if (value != null) {
                        if (currentScreenType.value ==
                            GoogleMapScreenType.providerOnMap) {
                          _switchToLocationSelectionMode();
                        }
                        setState(() {
                          currentScreenType.value =
                              GoogleMapScreenType.selectLocationOnMap;
                        });

                        // Place marker at the new location and update address
                        final newLatitude = double.parse(
                          value['latitude'].toString(),
                        );
                        final newLongitude = double.parse(
                          value['longitude'].toString(),
                        );
                        _placeMarkerOnLatitudeAndLongitude(
                          latitude: newLatitude,
                          longitude: newLongitude,
                        );
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: CustomText(
                      'change'.translate(context: context),
                      color: context.colors.textBrand,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          } else {
            Future.delayed(const Duration(milliseconds: 1000)).then((
              final value,
            ) {
              if (!context.mounted) return;
              Navigator.pop(context);
            });
          }
        },
        child: ValueListenableBuilder<GoogleMapScreenType>(
          valueListenable: currentScreenType,
          builder: (context, screenType, _) {
            if (screenType == GoogleMapScreenType.providerOnMap) {
              return _buildProviderMapView();
            } else {
              return _buildLocationSelectionView();
            }
          },
        ),
      ),
    ),
  );

  Widget _buildProviderMapView() {
    return ValueListenableBuilder<List<AppMapMarker>>(
      valueListenable: mapMarkers,
      builder: (context, data, _) => Stack(
        children: [
          AppMapView(
            googleMapStyle: mapStyle,
            zoomControlsEnabled: false,
            markers: data,
            initialCenter: initialCenter,
            initialZoom: 14,
            onMapReady: (controller) {
              _mapController = controller;
              if (!_isOsm) {
                _customInfoWindowController.googleMapController =
                    controller.googleController;
              }
            },
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProviderSlider(
                    providerCarouselController: providerCarouselController,
                    selectedProviderIndex: selectedProviderIndex,
                    onProvidersUpdate: (providers) =>
                        _updateProviderMarkers(providers: providers),
                    onProviderSelected: (latitude, longitude) =>
                        _zoomToProviderLocation(latitude, longitude),
                  ),
                  CustomSizedBox(
                    height: 16 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: MapSearchContainer(
              hint: 'searchProviders'.translate(context: context),
              onTap:
                  context.watch<FetchMapProviderCubit>().state
                      is FetchMapProviderFetchSuccess
                  ? null
                  : () {},
              onSearchTextChanged: (value) {
                searchText.value = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openSetLocationSearch() {
    Navigator.pushNamed(context, setLocationRoute).then((final result) {
      final Map? value = result as Map?;
      if (value != null) {
        if (currentScreenType.value == GoogleMapScreenType.providerOnMap) {
          _switchToLocationSelectionMode();
        }
        setState(() {
          currentScreenType.value = GoogleMapScreenType.selectLocationOnMap;
        });
        final newLatitude = double.parse(value['latitude'].toString());
        final newLongitude = double.parse(value['longitude'].toString());
        _placeMarkerOnLatitudeAndLongitude(
          latitude: newLatitude,
          longitude: newLongitude,
        );
      }
    });
  }

  Widget _buildServiceNotAvailableView(
    final CheckProviderAvailabilityFetchFailure state,
  ) => ServiceNotAvailableView(
    selectedAddress: selectedAddress,
    isResolvingAddress: isResolvingAddress,
    selectedLatitude: selectedLatitude,
    selectedLongitude: selectedLongitude,
    onEditLocation: _openSetLocationSearch,
    onAreaRequestSubmitted: () => setState(() => _areaRequestSubmitted = true),
  );

  Widget _buildAreaRequestSubmittedView() => AreaRequestSubmittedView(
    selectedAddress: selectedAddress,
    onChangeLocation: _openSetLocationSearch,
  );

  Widget _buildLocationSelectionView() {
    return BlocBuilder<
      CheckProviderAvailabilityCubit,
      CheckProviderAvailabilityState
    >(
      builder: (context, checkProviderAvailabilityState) {
        if (checkProviderAvailabilityState
            is CheckProviderAvailabilityFetchFailure) {
          return _areaRequestSubmitted
              ? _buildAreaRequestSubmittedView()
              : _buildServiceNotAvailableView(checkProviderAvailabilityState);
        }
        return _buildMapWithOverlays();
      },
    );
  }

  Widget _buildMapWithOverlays() {
    return ValueListenableBuilder<List<AppMapMarker>>(
      valueListenable: mapMarkers,
      builder: (context, data, _) =>
          BlocListener<AddAddressCubit, AddAddressState>(
            listener: (final BuildContext context, AddAddressState state) {
              if (state is AddAddressSuccess) {
                if (data.isNotEmpty) {
                  final position = data.first.position;

                  HiveRepository.setLongitude = position.longitude;
                  HiveRepository.setLatitude = position.latitude;
                }
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pop(widget.addressDetails == null ? null : true);
              }
            },
            child: Stack(
              children: [
                AppMapView(
                  googleMapStyle: mapStyle,
                  zoomControlsEnabled: false,
                  markers: data.isEmpty ? [initialLocation] : data,
                  initialCenter: initialCenter,
                  initialZoom: 16,
                  onTap: (latitude, longitude) =>
                      _placeMarkerOnLatitudeAndLongitude(
                        latitude: latitude,
                        longitude: longitude,
                      ),
                  onCameraMove: _isOsm
                      ? null
                      : () => _customInfoWindowController.onCameraMove!(),
                  onMapReady: (controller) {
                    _mapController = controller;
                    if (!_isOsm) {
                      _customInfoWindowController.googleMapController =
                          controller.googleController;
                    }
                    // Auto-zoom to marker location when map is created
                    _zoomToMarkerLocation();
                  },
                ),
                if (!_isOsm)
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 60,
                    width: 185,
                    offset: 48,
                  ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewPaddingOf(context).bottom,
                      ),
                      child: ConfirmAddressCard(
                        selectedAddress: selectedAddress,
                        isResolvingAddress: isResolvingAddress,
                        showAddressForm: widget.showAddressForm,
                        onConfirm: (final Map value) {
                          if (widget.showAddressForm) {
                            //complete address button click
                            _showAddressSheet(context);
                          } else {
                            //confirm address button click
                            HiveRepository.setLocationName =
                                value["lineOneAddress"];
                            HiveRepository.setLocationArea =
                                value["lineTwoAddress"];
                            HiveRepository.setLongitude = selectedLongitude;
                            HiveRepository.setLatitude = selectedLatitude;

                            Future.delayed(Duration.zero, () {
                              if (!context.mounted) return;
                              context
                                  .read<HomeScreenCubit>()
                                  .fetchHomeScreenData();
                              // Cart is location-scoped: refetch so providers
                              // unavailable at the new location drop out.
                              if (HiveRepository.getUserToken != '') {
                                context.read<CartCubit>().getCartDetails(
                                  isReorderCart: false,
                                );
                              }

                              if (Routes.previousRoute ==
                                  allowLocationScreenRoute) {
                                Navigator.popUntil(
                                  context,
                                  (final Route route) => route.isFirst,
                                );
                              } else {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  navigationRoute,
                                  (final route) => false,
                                );
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MapSearchContainer(
                          hint: 'searchLocation'.translate(context: context),
                          margin: const EdgeInsetsDirectional.only(
                            start: 15,
                            top: 15,
                            bottom: 15,
                            end: 8,
                          ),
                          onTap: _openSetLocationSearch,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: 15,
                          top: 15,
                        ),
                        child:
                            BlocConsumer<
                              FetchUserCurrentLocationCubit,
                              FetchUserCurrentLocationState
                            >(
                              listener: (context, state) {
                                if (state is FetchUserCurrentLocationSuccess) {
                                  _placeMarkerOnLatitudeAndLongitude(
                                    latitude: state.position.latitude,
                                    longitude: state.position.longitude,
                                  );
                                } else if (state
                                    is FetchUserCurrentLocationFailure) {
                                  UiUtils.showMessage(
                                    context,
                                    state.errorMessage,
                                    ToastificationType.error,
                                  );
                                }
                              },
                              builder: (context, state) {
                                final isLoading =
                                    state is FetchUserCurrentLocationInProgress;
                                return CustomInkWellContainer(
                                  onTap: isLoading
                                      ? null
                                      : () => context
                                            .read<
                                              FetchUserCurrentLocationCubit
                                            >()
                                            .fetchUserCurrentLocation(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: CustomContainer(
                                    color: context.colors.backgroundPrimary,
                                    borderRadius: 16,
                                    alignment: Alignment.center,
                                    width: 48,
                                    height: 48,
                                    avoideResponsive: true,
                                    child: isLoading
                                        ? CustomCircularProgressIndicator(
                                            color: context.colors.iconBrand,
                                            strokeWidth: 2,
                                          )
                                        : CustomSvgPicture(
                                            svgImage: AppAssets.gps,
                                            width: 24,
                                            height: 24,
                                            color: context.colors.iconPrimary,
                                            avoideResponsive: true,
                                          ),
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    mapMarkers.dispose();
    searchText.dispose();
    currentScreenType.dispose();
    selectedProviderIndex.dispose();
    isResolvingAddress.dispose();
    // CarouselSliderController doesn't need to be disposed
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
