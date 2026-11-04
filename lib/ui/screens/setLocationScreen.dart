import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({final Key? key}) : super(key: key);

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(builder: (final _) => const SetLocationScreen());
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  final TextEditingController _searchLocation = TextEditingController();
  Timer? delayTimer;
  GooglePlaceAutocompleteCubit? cubitReference;
  int searchedTextLength = 0;
  ValueNotifier<int> previousSearchedTextLength = ValueNotifier(0);
  bool curruntlocationprogress = false;
  bool _isProcessingPlaceSelection = false;
  String? _deletingAddressId;

  void _requestLocationPermission() {
    setState(() {
      curruntlocationprogress = true;
    });
    LocationRepository.requestPermission(
      allowed: (final Position position) {
        setState(() {
          curruntlocationprogress = false;
        });
        Navigator.pop(context, {
          'navigateToMap': true,
          "latitude": position.latitude.toString(),
          "longitude": position.longitude.toString(),
        });
      },
      onRejected: () {
        setState(() {
          curruntlocationprogress = false;
        });
        UiUtils.showMessage(
          context,
          "pleaseAllowLocationPermission".translate(context: context),
          ToastificationType.warning,
        );
      },
      onGranted: (final Position position) async {
        setState(() {
          curruntlocationprogress = false;
        });
        Navigator.pop(context, {
          'navigateToMap': true,
          "latitude": position.latitude.toString(),
          "longitude": position.longitude.toString(),
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (HiveRepository.getUserToken != '') {
      context.read<GetAddressCubit>().fetchAddress();
    }
    _searchLocation.addListener(() {
      previousSearchedTextLength.value = _searchLocation.text.length;
      if (_searchLocation.text.isEmpty) {
        delayTimer?.cancel();
        cubitReference?.clearCubit();
      } else if (_searchLocation.text.length >= 3) {
        if (delayTimer?.isActive ?? false) delayTimer?.cancel();

        delayTimer = Timer(const Duration(milliseconds: 500), () {
          if (_searchLocation.text.isNotEmpty) {
            if (_searchLocation.text.length != searchedTextLength) {
              context
                  .read<GooglePlaceAutocompleteCubit>()
                  .searchLocationFromPlacesAPI(
                    text: Uri.encodeComponent(_searchLocation.text.trim()),
                  );
              searchedTextLength = Uri.encodeComponent(
                _searchLocation.text,
              ).length;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchLocation.dispose();
    delayTimer?.cancel();
    cubitReference?.clearCubit();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    cubitReference = context.read<GooglePlaceAutocompleteCubit>();
    super.didChangeDependencies();
  }

  Widget _buildSearchField() => CustomContainer(
    padding: const EdgeInsets.all(16),
    color: context.colors.backgroundPrimary,
    avoideResponsive: true,
    borderRadius: 12,
    child: Row(
      children: [
        CustomSvgPicture(
          svgImage: AppAssets.search,
          color: context.colors.iconSecondary,
        ),
        const CustomSizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _searchLocation,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'enterLocationAreaCity'.translate(context: context),
              hintStyle: TextStyle(
                fontSize: 14,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: previousSearchedTextLength,
          builder: (context, int value, child) => value >= 1
              ? CustomInkWellContainer(
                  onTap: () {
                    delayTimer?.cancel();
                    cubitReference?.clearCubit();
                    _searchLocation.clear();
                  },
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: context.colors.iconSecondary,
                  ),
                )
              : const CustomSizedBox(),
        ),
      ],
    ),
  );

  Widget _buildGpsButton() => CustomInkWellContainer(
    onTap: () {
      if (!curruntlocationprogress) {
        _requestLocationPermission();
      }
    },
    borderRadius: BorderRadius.circular(16),
    child: CustomContainer(
      avoideResponsive: true,
      padding: const EdgeInsets.all(12),
      color: context.colors.backgroundPrimary,
      borderRadius: 16,
      child: SizedBox(
        width: 32,
        height: 32,
        child: curruntlocationprogress
            ? CustomCircularProgressIndicator(
                strokeWidth: 2,
                widthAndHeight: 20,
                color: context.colors.iconBrand,
              )
            : Center(
                child: CustomSvgPicture(
                  svgImage: AppAssets.gps,
                  color: context.colors.iconBrand,
                ),
              ),
      ),
    ),
  );

  Widget _buildPlaceRow({
    required final bool isFromHistory,
    required final String placeName,
    required final String placeId,
    final String? latitude,
    final String? longitude,
  }) => CustomInkWellContainer(
    onTap: () async {
      // prevent double-tap/double-selection
      if (_isProcessingPlaceSelection || !mounted) return;

      setState(() {
        _isProcessingPlaceSelection = true;
      });

      try {
        dynamic coOrdinates;

        if (!isFromHistory) {
          coOrdinates = await GooglePlaceRepository()
              .getPlaceDetailsFromPlaceId(placeId);

          HiveRepository.storePlaceInHive(
            placeId: placeId,
            placeName: placeName,
            longitude: coOrdinates['lng'].toString(),
            latitude: coOrdinates['lat'].toString(),
          );
        }

        if (mounted && Navigator.canPop(context)) {
          final String finalLatitude =
              latitude ?? (coOrdinates?['lat']?.toString() ?? '');
          final String finalLongitude =
              longitude ?? (coOrdinates?['lng']?.toString() ?? '');

          Navigator.pop(context, {
            'navigateToMap': true,
            "latitude": finalLatitude,
            "longitude": finalLongitude,
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessingPlaceSelection = false;
          });
        }
      }
    },
    child: Row(
      children: [
        CustomContainer(
          padding: const EdgeInsets.all(8),
          color: context.colors.backgroundSecondary,
          borderRadius: 16,
          child: CustomSvgPicture(
            svgImage: AppAssets.mapPinArea,
            width: 20,
            height: 20,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ),
        const CustomSizedBox(width: 10),
        Expanded(
          child: CustomText(
            placeName,
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _buildResultsCard() =>
      BlocBuilder<GooglePlaceAutocompleteCubit, GooglePlaceAutocompleteState>(
        builder: (BuildContext context, googlePlaceState) {
          if (googlePlaceState is GooglePlaceAutocompleteInProgress) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(top: 24),
              child: Center(
                child: CustomCircularProgressIndicator(
                  color: context.colors.iconBrand,
                ),
              ),
            );
          }

          if (googlePlaceState is GooglePlaceAutocompleteSuccess) {
            final predictions =
                googlePlaceState.autocompleteResult.predictions ?? [];

            if (predictions.isEmpty) {
              return Center(
                child: NoDataFoundWidget(
                  titleKey: 'noLocationFound'.translate(context: context),
                  subtitleKey: 'noLocationFoundSubTitle'.translate(
                    context: context,
                  ),
                  imageHeight: 150,
                  imageWidth: 150,
                ),
              );
            }

            return _buildCard(
              label: 'searchResults'.translate(context: context),
              children: List.generate(predictions.length, (index) {
                final Prediction placeData = predictions[index];
                return _buildPlaceRow(
                  isFromHistory: false,
                  placeName: placeData.description ?? '',
                  placeId: placeData.placeId ?? '',
                );
              }),
            );
          }

          final List<Map> recentPlaces = HiveRepository.getStoredPlaces;
          if (recentPlaces.isEmpty) return const CustomSizedBox();

          return _buildCard(
            label: 'recentSearched'.translate(context: context),
            onClear: () {
              HiveRepository.clearStoredPlaces();
              setState(() {});
            },
            children: List.generate(
              recentPlaces.length,
              (index) => _buildPlaceRow(
                isFromHistory: true,
                longitude: recentPlaces[index]["longitude"],
                latitude: recentPlaces[index]["latitude"],
                placeName: recentPlaces[index]["name"],
                placeId: recentPlaces[index]["placeId"],
              ),
            ),
          );
        },
      );

  Widget _buildCard({
    required final String label,
    required final List<Widget> children,
    final VoidCallback? onClear,
  }) => CustomContainer(
    width: context.screenWidth,
    padding: const EdgeInsets.all(12),
    color: context.colors.backgroundPrimary,
    borderRadius: 8,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onClear != null)
          Row(
            children: [
              Expanded(
                child: CustomText(
                  label,
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              CustomInkWellContainer(
                onTap: onClear,
                child: CustomText(
                  'clear'.translate(context: context),
                  color: context.colors.textBrand,
                  fontSize: 14,
                ),
              ),
            ],
          )
        else
          CustomText(label, color: context.colors.textSecondary, fontSize: 12),
        const CustomSizedBox(height: 16),
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) ...[
            const CustomSizedBox(height: 12),
            CustomContainer(height: 1, color: context.colors.borderDefault),
            const CustomSizedBox(height: 12),
          ],
          children[i],
        ],
      ],
    ),
  );

  Widget _buildSavedAddressCard(final GetAddressModel addressData) =>
      AddressCard(
        title: addressData.type ?? '',
        subTitle: addressData.address ?? '',
        value: addressData.id ?? '',
        addressData: addressData,
        isDeleting: _deletingAddressId == addressData.id,
        onDeleteTap: () {
          setState(() => _deletingAddressId = addressData.id);
          context.read<DeleteAddressCubit>().deleteAddress(addressData.id!);
        },
        onChanged: (_) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, {
              'navigateToMap': true,
              "latitude": addressData.lattitude ?? '',
              "longitude": addressData.longitude ?? '',
            });
          }
        },
      );

  Widget _buildSavedAddressesSection() {
    if (HiveRepository.getUserToken == '') return const CustomSizedBox();

    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteAddressCubit, DeleteAddressState>(
          listener: (context, deleteAddressState) {
            if (deleteAddressState is DeleteAddressSuccess) {
              setState(() => _deletingAddressId = null);
              context.read<GetAddressCubit>().fetchAddress();
            } else if (deleteAddressState is DeleteAddressFail) {
              setState(() => _deletingAddressId = null);
            }
          },
        ),
      ],
      child: BlocBuilder<GetAddressCubit, GetAddressState>(
        builder: (context, getAddressState) {
          if (getAddressState is! GetAddressSuccess ||
              getAddressState.data.isEmpty) {
            return const CustomSizedBox();
          }

          final List<GetAddressModel> addresses = getAddressState.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomSizedBox(height: 16),
              CustomText(
                'savedAddresses'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(height: 16),
              if (ResponsiveHelper.isTabletDevice(context))
                EqualHeightGrid(
                  children: addresses.map(_buildSavedAddressCard).toList(),
                )
              else
                for (int i = 0; i < addresses.length; i++) ...[
                  if (i > 0) const CustomSizedBox(height: 12),
                  _buildSavedAddressCard(addresses[i]),
                ],
            ],
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
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'setLocation'.translate(context: context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSearchField()),
                const CustomSizedBox(width: 8),
                _buildGpsButton(),
              ],
            ),
            const CustomSizedBox(height: 24),
            _buildResultsCard(),
            _buildSavedAddressesSection(),
          ],
        ),
      ),
    ),
  );
}
