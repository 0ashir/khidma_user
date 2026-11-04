import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderDistanceBanner extends StatelessWidget {
  const ProviderDistanceBanner({
    super.key,
    required this.distanceInKm,
    required this.providerAddress,
    required this.providerLatitude,
    required this.providerLongitude,
  });

  final double distanceInKm;
  final String providerAddress;
  final double providerLatitude;
  final double providerLongitude;

  @override
  Widget build(final BuildContext context) => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    color: context.colors.backgroundWarningSubtle,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CustomText(
            "${'providersAddressIs'.translate(context: context)} "
            "${distanceInKm.toStringAsFixed(1)} "
            "${context.read<SystemSettingCubit>().systemDistanceUnit.toLowerCase()} "
            "${'fromYourLocation'.translate(context: context)}",
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.colors.textPrimary,
          ),
        ),
        const CustomSizedBox(width: 8),
        CustomInkWellContainer(
          onTap: () => UiUtils.openMap(
            context,
            latitude: providerLatitude,
            longitude: providerLongitude,
          ),
          child: CustomText(
            'getDirection'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.colors.textPrimary,
            showUnderline: true,
          ),
        ),
      ],
    ),
  );
}
