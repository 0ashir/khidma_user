import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AccountDeactivatedBanner extends StatelessWidget {
  const AccountDeactivatedBanner({super.key});

  @override
  Widget build(final BuildContext context) => CustomContainer(
    width: double.maxFinite,
    avoideResponsive: true,
    color: context.colors.backgroundErrorSubtle,
    borderRadius: UiUtils.borderRadiusOf8,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.warning,
              height: 16,
              width: 16,
              color: context.colors.iconError,
            ),
            const CustomSizedBox(width: 8),
            Expanded(
              child: CustomText(
                'accountDeactivated'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textError,
              ),
            ),
          ],
        ),
        const CustomSizedBox(height: 4),
        CustomText(
          'yourAccountIsDeActive'.translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textSecondary,
        ),
      ],
    ),
  );
}
