import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final String title;
  final String value;
  final String subTitle;
  final Function(Object?)? onChanged;
  final GetAddressModel? addressData;
  final bool isDeleting;
  final VoidCallback? onDeleteTap;

  const AddressCard({
    super.key,
    required this.title,
    required this.value,
    required this.subTitle,
    this.onChanged,
    this.addressData,
    this.isDeleting = false,
    this.onDeleteTap,
  });

  String get _typeIcon {
    switch (title.toLowerCase()) {
      case 'home':
        return AppAssets.homeAdd;
      case 'office':
        return AppAssets.officeAdd;
      default:
        return AppAssets.icLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDefault = addressData?.isDefault == '1';
    final String? phone = addressData?.mobile;
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: () => onChanged?.call(value),
      child: CustomContainer(
        padding: const EdgeInsets.all(12),
        color: context.colors.surfacePrimary,
        border: Border.all(color: context.colors.borderDefault),
        borderRadius: UiUtils.borderRadiusOf12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomContainer(
                  padding: const EdgeInsets.all(8),
                  color: context.colors.backgroundSecondary,
                  borderRadius: UiUtils.borderRadiusOf8,
                  child: CustomSvgPicture(
                    svgImage: _typeIcon,
                    height: 24,
                    width: 24,
                    color: context.colors.iconPrimary,
                    avoideResponsive: true,
                  ),
                ),
                const CustomSizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        title.toLowerCase().translate(context: context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        color: context.colors.textPrimary,
                      ),
                      if (isDefault) ...[
                        const CustomSizedBox(height: 4),
                        CustomText(
                          'defaultAddress'.translate(context: context),
                          fontSize: 11,
                          color: context.colors.textBrand,
                        ),
                      ],
                    ],
                  ),
                ),
                if (addressData != null) ...[
                  const CustomSizedBox(width: 12),
                  CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(
                      UiUtils.borderRadiusOf50,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        googleMapRoute,
                        arguments: {
                          'screenType': GoogleMapScreenType.selectLocationOnMap,
                          "defaultLatitude":
                              addressData!.lattitude?.toString() ?? '',
                          "defaultLongitude":
                              addressData!.longitude?.toString() ?? '',
                          'details': addressData,
                          'showAddressForm': true,
                        },
                      ).then((final Object? value) {
                        if (!context.mounted) return;
                        if (value != null) {
                          context.read<GetAddressCubit>().fetchAddress();
                        }
                      });
                    },
                    child: CustomContainer(
                      color: context.colors.backgroundSecondary,
                      borderRadius: 100,
                      padding: const EdgeInsets.all(8),
                      child: CustomSvgPicture(
                        svgImage: AppAssets.edit,
                        color: context.colors.iconPrimary,
                        avoideResponsive: true,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                  const CustomSizedBox(width: 12),
                  CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(100),
                    onTap: isDeleting
                        ? null
                        : () {
                            UiUtils.showBottomSheet(
                              context: context,
                              enableDrag: true,
                              isScrollControlled: true,
                              child: DeleteAddressSheet(
                                onConfirmButtonPressed: () {
                                  Navigator.pop(context);
                                  onDeleteTap?.call();
                                },
                              ),
                            );
                          },
                    child: CustomContainer(
                      color: context.colors.backgroundSecondary,
                      borderRadius: 100,
                      padding: const EdgeInsets.all(8),
                      child: isDeleting
                          ? CustomCircularProgressIndicator(
                              color: context.colors.iconPrimary,
                              widthAndHeight: 20,
                            )
                          : CustomSvgPicture(
                              svgImage: AppAssets.drDeleteAccount,
                              color: context.colors.iconPrimary,
                              avoideResponsive: true,
                              height: 20,
                              width: 20,
                            ),
                    ),
                  ),
                ],
              ],
            ),
            const CustomSizedBox(height: 12),
            CustomSizedBox(
              height: 1,
              width: double.infinity,
              child: DashedRect(
                color: context.colors.borderDefault,
                strokeWidth: 1,
                gap: 4,
              ),
            ),
            const CustomSizedBox(height: 12),
            CustomText(
              subTitle,
              fontSize: 12,
              maxLines: 2,
              color: context.colors.textSecondary,
            ),
            if ((addressData?.regionAndCountry ?? '').isNotEmpty) ...[
              const CustomSizedBox(height: 4),
              CustomText(
                addressData!.regionAndCountry,
                fontSize: 12,
                maxLines: 1,
                color: context.colors.textSecondary,
              ),
            ],
            if (phone != null && phone.isNotEmpty) ...[
              const CustomSizedBox(height: 8),
              CustomContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: context.colors.backgroundSecondary,
                borderRadius: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgPicture(
                      svgImage: AppAssets.phone,
                      height: 20,
                      width: 20,
                      color: context.colors.iconPrimary,
                      avoideResponsive: true,
                    ),
                    const CustomSizedBox(width: 8),
                    CustomText(
                      phone,
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
