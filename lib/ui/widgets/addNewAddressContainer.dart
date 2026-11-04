import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddAddressContainer extends StatelessWidget {
  final Function()? onTap;

  const AddAddressContainer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: CustomContainer(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        color: context.colors.backgroundBrand,
        borderRadius: UiUtils.borderRadiusOf12,
        child: Center(
          child: CustomText(
            "addNewAddress".translate(context: context),
            color: context.colors.textInverseLight,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
