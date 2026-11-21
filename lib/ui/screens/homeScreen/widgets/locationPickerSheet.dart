import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// What the home screen should do after the location sheet closes.
enum LocationPickerAction {
  /// A saved address was applied; home data already refreshing.
  applied,

  /// Open the centre-pin map at [LocationPickerResult.latitude]/longitude.
  openMap,

  /// Open the place search screen.
  search,

  /// Open the map + address form to add a new address.
  addAddress,
}

class LocationPickerResult {
  const LocationPickerResult(this.action, {this.latitude, this.longitude});

  final LocationPickerAction action;
  final String? latitude;
  final String? longitude;
}

/// "Service Location" sheet on the home screen: pick a saved address and
/// confirm it, use the current location, pick a spot on the map, or add a
/// new address.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  /// Short header label for a saved address: "Apartment · Marina Tower, Apt 304".
  static String labelFor(
    final BuildContext context,
    final GetAddressModel address,
  ) {
    final String type = (address.type ?? '').trim();
    final String typeLabel = type.isEmpty
        ? ''
        : trOr(context, type.toLowerCase(), type).capitalize();
    final String short = (address.address ?? '')
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && p.toLowerCase() != 'null')
        .take(2)
        .join(', ');
    return [typeLabel, short].where((s) => s.isNotEmpty).join(' · ');
  }

  /// Makes [address] the current location and refreshes location-scoped data
  /// (home and cart), like confirming a pin on the map does.
  static void applySavedAddress(
    final BuildContext context,
    final GetAddressModel address,
  ) {
    final String latitude = address.lattitude ?? '';
    final String longitude = address.longitude ?? '';
    HiveRepository.setLatitude = latitude;
    HiveRepository.setLongitude = longitude;
    HiveRepository.setLocationName = address.address ?? '';
    HiveRepository.setLocationArea = '';
    HiveRepository.setSelectedAddress = {
      'id': address.id ?? '',
      'label': labelFor(context, address),
      'latitude': latitude,
      'longitude': longitude,
    };
    context.read<HomeScreenCubit>().fetchHomeScreenData();
    if (HiveRepository.getUserToken != '') {
      context.read<CartCubit>().getCartDetails(isReorderCart: false);
    }
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  bool _locating = false;

  /// Address chosen in the list; applied by "Confirm Location".
  String? _chosenId = HiveRepository.getSelectedAddress?['id'];

  bool get _isLoggedIn => HiveRepository.getUserToken != '';

  @override
  void initState() {
    super.initState();
    if (_isLoggedIn) context.read<GetAddressCubit>().fetchAddress();
  }

  /// Opens the centre-pin map at the GPS position. Without location access
  /// (denied, or GPS fails) it opens the map at the current app location, so
  /// guests can always set a location by dragging the pin or searching.
  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    final LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission == LocationPermission.deniedForever) {
      _pickOnMap();
      return;
    }
    setState(() => _locating = true);
    void openMap(final Position position) {
      if (!mounted) return;
      Navigator.pop(
        context,
        LocationPickerResult(
          LocationPickerAction.openMap,
          latitude: position.latitude.toString(),
          longitude: position.longitude.toString(),
        ),
      );
    }

    try {
      await LocationRepository.requestPermission(
        allowed: openMap,
        onGranted: openMap,
        onRejected: () {
          if (mounted) _pickOnMap();
        },
      );
    } catch (_) {
      if (mounted) _pickOnMap();
    }
  }

  /// Centre-pin map at the current app location (fallback when there is no
  /// location access; the map has its own search box).
  void _pickOnMap() => Navigator.pop(
    context,
    LocationPickerResult(
      LocationPickerAction.openMap,
      latitude: HiveRepository.getLatitude,
      longitude: HiveRepository.getLongitude,
    ),
  );

  void _addNewAddress() {
    if (!_isLoggedIn) {
      Navigator.pop(context);
      UiUtils.showBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        child: const LoginRequiredBottomSheet(),
      );
      return;
    }
    Navigator.pop(
      context,
      const LocationPickerResult(LocationPickerAction.addAddress),
    );
  }

  void _confirm(final List<GetAddressModel> addresses) {
    final GetAddressModel? chosen = addresses
        .where((a) => a.id == _chosenId)
        .firstOrNull;
    if (chosen == null ||
        (chosen.lattitude ?? '').isEmpty ||
        (chosen.longitude ?? '').isEmpty) {
      return;
    }
    LocationPickerSheet.applySavedAddress(context, chosen);
    Navigator.pop(
      context,
      const LocationPickerResult(LocationPickerAction.applied),
    );
  }

  String _iconFor(final String? type) => switch ((type ?? '').toLowerCase()) {
    'home' || 'villa' => AppAssets.homeAdd,
    'apartment' => AppAssets.apartmentAdd,
    'other' => AppAssets.icLocation,
    _ => AppAssets.officeAdd,
  };

  // ---------------------------------------------------------------- header

  /// Icon + heading at the start, close button at the end (mirrors in RTL).
  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: context.colors.backgroundBrandSubtle,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.location_on_rounded,
          size: 26,
          color: context.colors.iconBrand,
        ),
      ),
      const CustomSizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                trOr(context, 'serviceLocation', 'Service Location'),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
                maxLines: 1,
                // Tight line height so the subtitle sits right under it.
                height: 1.1,
              ),
              CustomText(
                trOr(
                  context,
                  'serviceLocationSubtitle',
                  'Choose a saved address or add new',
                ),
                fontSize: 13,
                letterSpacing: -0.3,
                color: context.colors.textSecondary,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      const CustomSizedBox(width: 12),
      CustomInkWellContainer(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.colors.backgroundSecondary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: context.colors.iconPrimary,
          ),
        ),
      ),
    ],
  );

  // -------------------------------------------------------- saved addresses

  Widget _addressCard(final GetAddressModel address) {
    final bool chosen = address.id != null && address.id == _chosenId;
    final String type = (address.type ?? '').trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomInkWellContainer(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _chosenId = address.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Compact card: smaller paddings and icon tile keep it short.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: chosen
                ? context.colors.backgroundBrandSubtle
                : context.colors.backgroundPrimary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: chosen
                  ? context.colors.borderBrand
                  : context.colors.borderDefault,
              width: chosen ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: chosen
                      ? context.colors.backgroundPrimary
                      : context.colors.backgroundBrandSubtle,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: CustomSvgPicture(
                  svgImage: _iconFor(type),
                  width: 18,
                  height: 18,
                  color: context.colors.iconBrand,
                  avoideResponsive: true,
                ),
              ),
              const CustomSizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      type.isEmpty
                          ? ''
                          : trOr(
                              context,
                              type.toLowerCase(),
                              type,
                            ).capitalize(),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      maxLines: 1,
                    ),
                    const CustomSizedBox(height: 1),
                    CustomText(
                      address.address ?? '',
                      fontSize: 12,
                      color: context.colors.textSecondary,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const CustomSizedBox(width: 8),
              chosen
                  ? Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: context.colors.iconBrand,
                    )
                  : Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 22,
                      color: context.colors.iconSecondary,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<GetAddressModel> _addressesOf(final GetAddressState state) =>
      state is GetAddressSuccess ? state.data : const [];

  Widget _savedAddresses(final GetAddressState state) {
    if (!_isLoggedIn) return const SizedBox.shrink();
    if (state is GetAddressInProgress) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CustomCircularProgressIndicator()),
      );
    }
    final List<GetAddressModel> addresses = _addressesOf(state);
    if (addresses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'savedAddresses'.translate(context: context),
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
        const CustomSizedBox(height: 10),
        for (final GetAddressModel address in addresses) _addressCard(address),
      ],
    );
  }

  // ---------------------------------------------------------------- actions

  Widget _outlinedButton({
    required final Widget icon,
    required final String label,
    required final VoidCallback onTap,
    final bool brandBorder = false,
  }) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: brandBorder
              ? context.colors.borderBrand
              : context.colors.borderDefault,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const CustomSizedBox(width: 8),
          Flexible(
            child: CustomText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: brandBorder
                  ? context.colors.textBrand
                  : context.colors.textPrimary,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _optionRow({
    required final Widget icon,
    required final String label,
    required final VoidCallback onTap,
  }) => CustomInkWellContainer(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: Center(child: icon)),
          const CustomSizedBox(width: 12),
          Expanded(
            child: CustomText(
              label,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              maxLines: 1,
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: context.colors.iconSecondary,
          ),
        ],
      ),
    ),
  );

  /// Use Current Location (the map it opens covers picking any spot).
  Widget _quickActions() => Container(
    decoration: BoxDecoration(
      color: context.colors.backgroundPrimary,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colors.borderDefault),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        _optionRow(
          icon: _locating
              ? CustomCircularProgressIndicator(
                  strokeWidth: 2,
                  widthAndHeight: 18,
                  color: context.colors.iconBrand,
                )
              : Icon(
                  Icons.my_location_rounded,
                  size: 22,
                  color: context.colors.iconBrand,
                ),
          label: trOr(
            context,
            'useCurrentLocationShort',
            'Use Current Location',
          ),
          onTap: _useCurrentLocation,
        ),
      ],
    ),
  );

  Widget _confirmButton(final List<GetAddressModel> addresses) {
    final bool enabled = addresses.any((a) => a.id == _chosenId);
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? () => _confirm(addresses) : null,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: enabled
              ? context.colors.backgroundBrand
              : context.colors.backgroundBrandDisabled,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              trOr(context, 'confirmLocation', 'Confirm Location'),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textInverseLight,
            ),
            const CustomSizedBox(width: 8),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_forward_rounded,
              size: 20,
              color: context.colors.textInverseLight,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.backgroundPrimary,
    borderRadiusStyle: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: BlocBuilder<GetAddressCubit, GetAddressState>(
          builder: (context, state) {
            final List<GetAddressModel> addresses = _isLoggedIn
                ? _addressesOf(state)
                : const [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const CustomSizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _savedAddresses(state),
                        const CustomSizedBox(height: 6),
                        _quickActions(),
                        const CustomSizedBox(height: 12),
                        _outlinedButton(
                          icon: Icon(
                            Icons.add_rounded,
                            size: 24,
                            color: context.colors.iconBrand,
                          ),
                          label: 'addNewAddress'.translate(context: context),
                          onTap: _addNewAddress,
                          brandBorder: true,
                        ),
                      ],
                    ),
                  ),
                ),
                if (addresses.isNotEmpty) ...[
                  const CustomSizedBox(height: 12),
                  _confirmButton(addresses),
                ],
              ],
            );
          },
        ),
      ),
    ),
  );
}
