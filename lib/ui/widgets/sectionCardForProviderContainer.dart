import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class SectionCardForProviderContainer extends StatelessWidget {
  const SectionCardForProviderContainer({
    required this.discount,
    required this.onTap,
    required this.imageHeight,
    required this.imageWidth,
    required this.cardHeight,
    required this.title,
    required this.image,
    required this.cardWidth,
    required this.bannerImage,
    required this.numberOfRating,
    required this.distance,
    required this.averageRating,
    required this.services,
    this.isVerified = false,
    final Key? key,
  }) : super(key: key);
  final String title,
      image,
      discount,
      bannerImage,
      numberOfRating,
      distance,
      averageRating,
      services;
  final double imageHeight, imageWidth, cardHeight, cardWidth;
  final VoidCallback onTap;
  final bool isVerified;

  @override
  Widget build(final BuildContext context) {
    return CustomInkWellContainer(
      onTap: onTap,
      child: Stack(
        children: [
          // The first container
          CustomContainer(
            margin: const EdgeInsetsDirectional.symmetric(
              vertical: 20,
              horizontal: 10,
            ),
            height: cardHeight,
            width: cardWidth,
            border: Border.all(color: context.colors.textPrimary, width: 0.2),
            borderRadius: UiUtils.borderRadiusOf8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UiUtils.borderRadiusOf8),
                    topRight: Radius.circular(UiUtils.borderRadiusOf8),
                  ),
                  child: CustomCachedNetworkImage(
                    networkImageUrl: bannerImage,
                    height: cardHeight / 1.7,
                    width: cardWidth,
                    fit: BoxFit.fill,
                  ),
                ),
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (averageRating != '0' && averageRating != '') ...[
                          Row(
                            children: [
                              CustomSvgPicture(
                                avoideResponsive: true,
                                svgImage: AppAssets.icStar,
                                height: 16,
                                width: 16,
                                color: context.colors.iconWarning,
                              ),
                              const CustomSizedBox(width: 5),
                              CustomText(
                                double.parse(averageRating).toStringAsFixed(1),
                                fontSize: 14,
                                color: context.colors.backgroundBrand,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const CustomSizedBox(width: 5),
                          const VerticalDivider(
                            color: Colors.black,
                            thickness: 0.2,
                          ),
                        ],
                        const CustomSizedBox(width: 5),
                        CustomSvgPicture(
                          avoideResponsive: true,
                          svgImage: AppAssets.icLocation,
                          height: 16,
                          width: 16,
                          color: context.colors.textBrand,
                        ),
                        const CustomSizedBox(width: 5),
                        CustomText(
                          "${double.parse(distance).ceil()} ${context.read<SystemSettingCubit>().systemDistanceUnit}",
                          fontSize: 14,
                          color: context.colors.backgroundBrand,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Centered container
          Positioned.directional(
            top: ((cardHeight - (cardHeight / 3)) / 1.3).rh(context),
            end: ((cardWidth - (cardWidth / 1.1)) / 1.1).rw(context),
            textDirection: Directionality.of(context),
            child: CustomContainer(
              padding: const EdgeInsetsDirectional.all(8),
              height: cardHeight / 3,
              width: cardWidth / 1.1,
              borderRadius: UiUtils.borderRadiusOf8,
              color: context.colors.surfaceElevated,
              boxShadow: [
                BoxShadow(
                  color: context.colors.textPrimary.withAlpha(20),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          title,
                          fontSize: 16,
                          maxLines: 1,
                          color: context.colors.textBrand,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          '$services ${services.convertToInt() > 1 ? 'services'.translate(context: context) : 'service'.translate(context: context)}',
                          fontSize: 12,
                          maxLines: 1,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(UiUtils.borderRadiusOf8),
                          ),
                          child: CustomCachedNetworkImage(
                            networkImageUrl: image,
                            width: 45,
                            height: 45,
                            fit: BoxFit.fill,
                          ),
                        ),
                        if (isVerified)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CustomSvgPicture(
                              avoideResponsive: true,
                              svgImage: AppAssets.verified,
                              width: 16,
                              height: 16,
                              color: context.colors.iconBrand,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
