import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// "Manage Location" sheet (checkout): pick the service address, edit or
/// delete saved ones, or add a new one (from the current location or a map
/// pin). Returns `{'selectedAddress': GetAddressModel}` when one is picked.
class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({
    super.key,
    required this.addresses,
    required this.defaultAddress,
  });
  final List<GetAddressModel> addresses;

  /// Address currently used by the booking (shown as selected).
  final GetAddressModel defaultAddress;
  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  String? _deletingAddressId;
  bool _locating = false;

  /// Address picked in the list; "Confirm Location" hands it to checkout.
  late String? _selectedId = widget.defaultAddress.id;

  void _confirm(final List<GetAddressModel> addresses) {
    final GetAddressModel? chosen = addresses
        .where((a) => a.id == _selectedId)
        .firstOrNull;
    if (chosen == null) return;
    Navigator.pop(context, {'selectedAddress': chosen});
  }

  /// Map + address form, starting at the given point (defaults to the
  /// current app location). Refreshes the list and closes the sheet after.
  void _openAddAddress({final String? latitude, final String? longitude}) {
    Navigator.pushNamed(
      context,
      googleMapRoute,
      arguments: {
        "defaultLatitude": latitude ?? HiveRepository.getLatitude,
        "defaultLongitude": longitude ?? HiveRepository.getLongitude,
        'showAddressForm': true,
        'screenType': GoogleMapScreenType.selectLocationOnMap,
      },
    ).then((final Object? value) {
      if (!mounted) return;
      context.read<GetAddressCubit>().fetchAddress();
      Navigator.pop(context);
    });
  }

  /// New address starting at the GPS position; without location access it
  /// starts at the current app location instead (pin can be moved there).
  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    final LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission == LocationPermission.deniedForever) {
      _openAddAddress();
      return;
    }
    setState(() => _locating = true);
    void open(final Position position) {
      if (!mounted) return;
      setState(() => _locating = false);
      _openAddAddress(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
    }

    void fallback() {
      if (!mounted) return;
      setState(() => _locating = false);
      _openAddAddress();
    }

    try {
      await LocationRepository.requestPermission(
        allowed: open,
        onGranted: open,
        onRejected: fallback,
      );
    } catch (_) {
      fallback();
    }
  }

  void _editAddress(final GetAddressModel address) {
    Navigator.pushNamed(
      context,
      googleMapRoute,
      arguments: {
        'screenType': GoogleMapScreenType.selectLocationOnMap,
        "defaultLatitude": address.lattitude?.toString() ?? '',
        "defaultLongitude": address.longitude?.toString() ?? '',
        'details': address,
        'showAddressForm': true,
      },
    ).then((final Object? value) {
      if (!mounted) return;
      if (value != null) context.read<GetAddressCubit>().fetchAddress();
    });
  }

  void _deleteAddress(final GetAddressModel address) {
    UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      child: DeleteAddressSheet(
        onConfirmButtonPressed: () {
          Navigator.pop(context);
          setState(() => _deletingAddressId = address.id);
          context.read<DeleteAddressCubit>().deleteAddress(address.id!);
        },
      ),
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
                'manageLocation'.translate(context: context),
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
                  'manageLocationSubtitle',
                  'Save, edit or remove your addresses.',
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

  // ------------------------------------------------------------ address card

  Widget _circleButton({
    required final Widget child,
    required final VoidCallback? onTap,
  }) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(100),
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.borderDefault),
      ),
      alignment: Alignment.center,
      child: child,
    ),
  );

  Widget _addressCard(final GetAddressModel address) {
    final bool selected = address.id != null && address.id == _selectedId;
    final bool isDefault = address.isDefault == '1';
    final bool deleting = _deletingAddressId == address.id;
    final String type = (address.type ?? '').trim();
    final String phone = (address.mobile ?? '').trim();
    final String region = address.regionAndCountry;

    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedId = address.id),
      child: Container(
        // Compact card: smaller paddings, icon tile and text.
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.backgroundBrandSubtle
              : context.colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? context.colors.borderBrand
                : context.colors.borderDefault,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection mark + default badge.
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: selected
                      ? context.colors.iconBrand
                      : context.colors.iconSecondary,
                ),
                const Spacer(),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? context.colors.backgroundPrimary
                          : context.colors.backgroundBrandSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: context.colors.iconBrand,
                        ),
                        const CustomSizedBox(width: 4),
                        CustomText(
                          'defaultAddress'.translate(context: context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textBrand,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const CustomSizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.backgroundPrimary
                        : context.colors.backgroundBrandSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: CustomSvgPicture(
                    svgImage: _iconFor(type),
                    width: 20,
                    height: 20,
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
                      const CustomSizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: context.colors.iconBrand,
                            ),
                          ),
                          const CustomSizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  address.address ?? '',
                                  fontSize: 13,
                                  color: context.colors.textPrimary,
                                  maxLines: 2,
                                ),
                                if (region.isNotEmpty)
                                  CustomText(
                                    region,
                                    fontSize: 12,
                                    color: context.colors.textSecondary,
                                    maxLines: 1,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (phone.isNotEmpty) ...[
                        const CustomSizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? context.colors.backgroundPrimary
                                : context.colors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomSvgPicture(
                                svgImage: AppAssets.phone,
                                height: 16,
                                width: 16,
                                color: context.colors.iconPrimary,
                                avoideResponsive: true,
                              ),
                              const CustomSizedBox(width: 6),
                              CustomText(
                                phone,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const CustomSizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _circleButton(
                        onTap: () => _editAddress(address),
                        child: CustomSvgPicture(
                          svgImage: AppAssets.edit,
                          color: context.colors.iconPrimary,
                          avoideResponsive: true,
                          height: 18,
                          width: 18,
                        ),
                      ),
                      const CustomSizedBox(width: 8),
                      _circleButton(
                        onTap: deleting ? null : () => _deleteAddress(address),
                        child: deleting
                            ? CustomCircularProgressIndicator(
                                color: context.colors.iconPrimary,
                                widthAndHeight: 18,
                                strokeWidth: 2,
                              )
                            : CustomSvgPicture(
                                svgImage: AppAssets.drDeleteAccount,
                                color: context.colors.iconPrimary,
                                avoideResponsive: true,
                                height: 18,
                                width: 18,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressList() => BlocBuilder<GetAddressCubit, GetAddressState>(
    builder: (context, state) {
      final List<GetAddressModel> addresses = state is GetAddressSuccess
          ? state.data
          : widget.addresses;
      if (addresses.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          for (int i = 0; i < addresses.length; i++) ...[
            if (i > 0) const CustomSizedBox(height: 12),
            _addressCard(addresses[i]),
          ],
        ],
      );
    },
  );

  // ---------------------------------------------------------------- actions

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

  /// Use Current Location (Add New Address below covers any other spot).
  Widget _locationOptions() => Container(
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

  Widget _addNewAddressButton() => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(12),
    onTap: _openAddAddress,
    child: Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderBrand),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded, size: 24, color: context.colors.iconBrand),
          const CustomSizedBox(width: 8),
          CustomText(
            'addNewAddress'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textBrand,
          ),
        ],
      ),
    ),
  );

  Widget _confirmButton(final List<GetAddressModel> addresses) {
    final bool enabled = addresses.any((a) => a.id == _selectedId);
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
  Widget build(final BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<AddAddressCubit, AddAddressState>(
        listener: (context, addAddressState) {
          if (addAddressState is AddAddressSuccess) {
            context.read<GetAddressCubit>().fetchAddress();
          }
        },
      ),
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
    child: CustomContainer(
      color: context.colors.backgroundPrimary,
      borderRadiusStyle: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: BlocBuilder<GetAddressCubit, GetAddressState>(
            builder: (context, state) {
              final List<GetAddressModel> addresses = state is GetAddressSuccess
                  ? state.data
                  : widget.addresses;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const CustomSizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _addressList(),
                          const CustomSizedBox(height: 12),
                          _locationOptions(),
                          const CustomSizedBox(height: 12),
                          _addNewAddressButton(),
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
    ),
  );
}
