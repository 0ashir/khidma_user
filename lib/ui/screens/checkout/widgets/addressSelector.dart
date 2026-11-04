import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressSelector extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onEditButtonSelected;
  final VoidCallback? onDeleteButtonSelected;
  final String address,
      mobileNumber,
      addressPincodeAndCountry,
      addressAreaAndCity,
      addressType;
  final bool isAddressSelected;

  const AddressSelector({
    super.key,
    this.onTap,
    required this.address,
    required this.mobileNumber,
    required this.addressPincodeAndCountry,
    required this.addressAreaAndCity,
    this.onEditButtonSelected,
    this.onDeleteButtonSelected,
    required this.addressType,
    required this.isAddressSelected,
  });

  BoxDecoration selectedItemBorderStyle({required BuildContext context}) =>
      BoxDecoration(
        boxShadow: [
          BoxShadow(color: context.colors.borderDefault, blurRadius: 3),
        ],
        border: Border.all(color: context.colors.textPrimary),
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      );

  BoxDecoration normalBoxDecoration({required BuildContext context}) =>
      BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      );

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsetsDirectional.only(start: 10),
        padding: const EdgeInsets.all(10),
        width: 250,
        decoration: (isAddressSelected
            ? selectedItemBorderStyle(context: context)
            : normalBoxDecoration(context: context)),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          mobileNumber,
                          color: context.colors.textPrimary,
                          maxLines: 1,
                        ),
                        CustomText(
                          filterAddressString(address),
                          color: context.colors.textPrimary,
                          maxLines: 2,
                        ),
                        CustomText(
                          filterAddressString(addressAreaAndCity),
                          color: context.colors.textPrimary,
                          maxLines: 1,
                        ),
                        CustomText(
                          filterAddressString(addressPincodeAndCountry),
                          color: context.colors.textPrimary,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomContainer(
                      height: 20,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<int>(
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                          color: context.colors.backgroundBrand,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.only(
                              topStart: Radius.circular(
                                UiUtils.borderRadiusOf10,
                              ),
                              bottomEnd: Radius.circular(
                                UiUtils.borderRadiusOf10,
                              ),
                              bottomStart: Radius.circular(
                                UiUtils.borderRadiusOf10,
                              ),
                            ),
                          ),
                          position: PopupMenuPosition.over,
                          onSelected: (final selected) {
                            if (selected == 1) {
                              onEditButtonSelected?.call();
                            }

                            if (selected == 2) {
                              onDeleteButtonSelected?.call();
                            }
                          },
                          itemBuilder: (final BuildContext context) => [
                            // popupmenu item 1
                            PopupMenuItem(
                              value: 1,
                              // row has two child icon and text.
                              child: CustomText(
                                "edit".translate(context: context),
                                color: context.colors.textInverseLight,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                              ),
                            ),
                            // popupmenu item 2
                            PopupMenuItem(
                              value: 2,
                              // row has two child icon and text
                              child: CustomText(
                                "delete".translate(context: context),
                                color: context.colors.textInverseLight,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          offset: const Offset(0, 24),
                          elevation: 2,
                          child: Icon(
                            Icons.more_vert,
                            color: context.colors.textBrand,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  CustomText(
                    addressType,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                  const Spacer(),
                  if (isAddressSelected)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          'serviceAddress'.translate(context: context),
                          color: context.colors.textPrimary,
                        ),
                        const CustomSizedBox(width: 3),
                        CustomContainer(
                          width: 25,
                          height: 25,
                          color: context.colors.backgroundBrand,
                          borderRadius: UiUtils.borderRadiusOf50,
                          child: Icon(
                            Icons.done,
                            color: context.colors.textInverseLight,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
