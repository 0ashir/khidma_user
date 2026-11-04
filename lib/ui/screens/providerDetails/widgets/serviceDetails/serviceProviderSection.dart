import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'serviceSectionTitle.dart';

class ServiceProviderSection extends StatelessWidget {
  const ServiceProviderSection({
    required this.provider,
    required this.providerId,
    super.key,
  });

  final ServiceDetailsProvider provider;
  final String providerId;

  @override
  Widget build(final BuildContext context) {
    final bool viewRating =
        double.tryParse(provider.averageRating ?? '0') != null &&
        double.parse(provider.averageRating!).toStringAsFixed(1) != '0.0';
    final bool canChat =
        provider.preBookingChatAllowed == '1' &&
        HiveRepository.getUserToken != '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceSectionTitle('provider'.translate(context: context)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 64,
              height: 64,
              borderRadius: UiUtils.borderRadiusOf12,
              color: context.colors.backgroundSecondary,
              clipBehavior: Clip.antiAlias,
              child: (provider.image ?? '').isEmpty
                  ? Icon(
                      Icons.storefront_outlined,
                      color: context.colors.iconPrimary,
                    )
                  : CustomCachedNetworkImage(
                      networkImageUrl: provider.image!,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
            ),
            const CustomSizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: CustomText(
                          provider.companyName ?? '',
                          maxLines: 1,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      if (provider.isVerified == '1') ...[
                        const CustomSizedBox(width: 4),
                        CustomSvgPicture(
                          avoideResponsive: true,
                          svgImage: AppAssets.verified,
                          height: 16,
                          width: 16,
                          color: context.colors.iconBrand,
                        ),
                      ],
                    ],
                  ),
                  const CustomSizedBox(height: 4),
                  Row(
                    children: [
                      if (viewRating) ...[
                        CustomSvgPicture(
                          avoideResponsive: true,
                          svgImage: AppAssets.icStar,
                          color: context.colors.iconWarning,
                          height: 14,
                          width: 14,
                        ),
                        const CustomSizedBox(width: 4),
                        CustomText(
                          double.parse(
                            provider.averageRating!,
                          ).toStringAsFixed(1),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textSecondary,
                        ),
                        const CustomSizedBox(width: 8),
                        CustomContainer(
                          height: 12,
                          width: 1,
                          color: context.colors.borderStrong,
                        ),
                        const CustomSizedBox(width: 8),
                      ],
                      CustomSvgPicture(
                        avoideResponsive: true,
                        svgImage: AppAssets.mapPinArea,
                        color: context.colors.iconSecondary,
                        height: 14,
                        width: 14,
                      ),
                      const CustomSizedBox(width: 4),
                      CustomText(
                        '${double.tryParse(provider.distance ?? '0')?.ceil() ?? 0} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                  const CustomSizedBox(height: 8),
                  CustomInkWellContainer(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        providerRoute,
                        arguments: {
                          "providerId": (provider.id ?? '').isNotEmpty
                              ? provider.id
                              : providerId,
                        },
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          'exploreAllServices'.translate(context: context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textBrand,
                        ),
                        const CustomSizedBox(width: 4),
                        CustomSvgPicture(
                          svgImage:
                              Directionality.of(context) == TextDirection.rtl
                              ? AppAssets.leftArrow
                              : AppAssets.rightArrow,
                          height: 14,
                          width: 14,
                          color: context.colors.iconBrand,
                          avoideResponsive: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (canChat) ...[
              const CustomSizedBox(width: 8),
              CustomInkWellContainer(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    chatMessages,
                    arguments: {
                      "chatUser": ChatUser(
                        id: provider.id ?? '',
                        name: provider.companyName ?? '',
                        translatedName: provider.companyName ?? '',
                        chatUserType: ChatUserType.providerEnquiry,
                        partnerId: provider.id ?? '',
                        unReadChats: 0,
                        profile: provider.image,
                      ),
                    },
                  );
                },
                child: CustomContainer(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: UiUtils.borderRadiusOf8,
                  child: CustomSvgPicture(
                    svgImage: AppAssets.chat,
                    height: 16,
                    width: 16,
                    color: context.colors.iconBrand,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
