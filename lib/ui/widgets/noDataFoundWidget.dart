import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/enumForWarningMessage.dart';
import 'package:flutter/material.dart';

class NoDataFoundWidget extends StatelessWidget {
  final Color? textColor;
  final String titleKey;
  final String? imagePath;
  final Function? onTapRetry;
  final bool showRetryButton;
  final Color? retryButtonBackgroundColor;
  final Color? retryButtonTextColor;
  final String? buttonName;
  final String? subtitleKey;
  final Color? imageColor;
  final double? imageHeight;
  final double? imageWidth;

  const NoDataFoundWidget({
    required this.titleKey,
    final Key? key,
    this.imagePath,
    this.textColor,
    this.onTapRetry,
    this.showRetryButton = false,
    this.retryButtonBackgroundColor,
    this.retryButtonTextColor,
    this.buttonName,
    this.subtitleKey,
    this.imageColor,
    this.imageHeight,
    this.imageWidth,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final String resolvedImagePath =
        imagePath ?? MessageType.getImageFromMessage(titleKey);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CustomSvgPicture(
            svgImage: resolvedImagePath,
            color: imageColor,
            height: imageHeight,
            width: imageWidth,
            colorMapper: IllustrationBrandColorMapper(
              primaryColor: context.colors.iconBrand,
              primaryLightColor: context.colors.backgroundBrandSubtle,
            ),
          ),
        ),
        const CustomSizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CustomText(
            titleKey,
            textAlign: TextAlign.center,
            color: context.colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitleKey != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomText(
              subtitleKey!,
              textAlign: TextAlign.center,
              color: context.colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        const CustomSizedBox(height: 15),
        if (showRetryButton)
          CustomRoundedButton(
            height: 40,
            widthPercentage: 0.6,
            backgroundColor:
                retryButtonBackgroundColor ?? context.colors.backgroundBrand,
            onTap: () {
              onTapRetry?.call();
            },
            titleColor: retryButtonTextColor ?? context.colors.textInverseLight,
            buttonTitle: (buttonName ?? 'retry').translate(context: context),
            showBorder: false,
          ),
      ],
    );
  }
}
