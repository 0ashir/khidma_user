import 'package:flutter/material.dart';
import '../../../../app/generalImports.dart';

class MapTitleWidget extends StatelessWidget {
  final ValueNotifier<GoogleMapScreenType> currentScreenType;
  final bool showAddressForm;

  /// Address of the pin currently on the map (not yet confirmed).
  final ValueNotifier? selectedAddress;

  const MapTitleWidget({
    Key? key,
    this.selectedAddress,
    required this.currentScreenType,
    required this.showAddressForm,
  }) : super(key: key);

  static String? _pinName(final dynamic address) {
    final String name = address is Map
        ? (address['lineOneAddress']?.toString() ?? '').trim()
        : '';
    return name.isEmpty ? null : name;
  }

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<GoogleMapScreenType>(
    valueListenable: currentScreenType,
    builder: (context, screenType, _) {
      if (screenType == GoogleMapScreenType.providerOnMap) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'providersNearby'.translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
            MarqueeWidget(
              direction: Axis.horizontal,
              child: ValueListenableBuilder(
                valueListenable: Hive.box(
                  HiveRepository.userDetailBoxKey,
                ).listenable(),
                builder: (BuildContext context, Box box, _) => CustomText(
                  " ${HiveRepository.getLocationName ?? "selectYourLocation".translate(context: context)} ",
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showAddressForm
                ? CustomText(
                    'selectLocation'.translate(context: context),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  )
                : CustomText(
                    'yourLocation'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                  ),
            if (!showAddressForm)
              MarqueeWidget(
                direction: Axis.horizontal,
                child: ValueListenableBuilder(
                  valueListenable: selectedAddress ?? ValueNotifier(null),
                  builder: (BuildContext context, dynamic pinAddress, _) =>
                      CustomText(
                        " ${_pinName(pinAddress) ?? HiveRepository.getLocationName ?? "selectYourLocation".translate(context: context)} ",
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        maxLines: 1,
                      ),
                ),
              ),
          ],
        );
      }
    },
  );
}
