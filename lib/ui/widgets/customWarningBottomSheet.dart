import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomWarningBottomSheet extends StatelessWidget {
  const CustomWarningBottomSheet({
    super.key,
    required this.conformText,
    required this.onTapConformText,
    required this.closeText,
    required this.onTapCloseText,
    required this.detailsWarningMessage,
    this.conformButtonColor,
  });
  final String conformText;
  final VoidCallback onTapConformText;
  final String closeText;
  final VoidCallback onTapCloseText;
  final String detailsWarningMessage;
  final Color? conformButtonColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgPicture(
            svgImage: AppAssets.confirmUser,
            boxFit: BoxFit.fill,
            colorMapper: IllustrationBrandColorMapper(
              primaryColor: context.colors.iconBrand,
              primaryLightColor: context.colors.backgroundBrandSubtle,
            ),
          ),
          const CustomSizedBox(height: 20),
          Text(
            "areYouSure".translate(context: context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const CustomSizedBox(height: 10),
          Text(
            detailsWarningMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
          ),
          const CustomSizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomRoundedButton(
                  onTap: onTapConformText,
                  widthPercentage: 1,
                  backgroundColor:
                      conformButtonColor ?? context.colors.backgroundBrand,
                  showBorder: false,
                  borderColor:
                      conformButtonColor ?? context.colors.backgroundBrand,
                  buttonTitle: conformText,
                  titleColor: context.colors.textInverseLight,
                ),
              ),
              const CustomSizedBox(width: 10),
              Expanded(
                child: CustomRoundedButton(
                  onTap: onTapCloseText,
                  widthPercentage: 1,
                  backgroundColor: context.colors.surfaceElevated,
                  showBorder: true,
                  borderColor: context.colors.textPrimary,
                  buttonTitle: closeText,
                  titleColor: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
