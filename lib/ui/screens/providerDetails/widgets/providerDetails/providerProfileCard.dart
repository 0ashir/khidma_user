import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:e_demand/ui/widgets/SliderPromoCode.dart';
import 'package:e_demand/ui/widgets/animation/slide_animation.dart';

class ProviderProfileCard extends StatelessWidget {
  const ProviderProfileCard({
    required this.state,
    required this.promocodeList,
    required this.cardKey,
    required this.cardWidth,
    super.key,
  });

  final ProviderDetailsAndServiceFetchSuccess state;
  final List<Promocode> promocodeList;

  /// Lets the parent measure the card height after layout.
  final GlobalKey cardKey;
  final double? cardWidth;

  Widget _infoChip(
    final BuildContext context, {
    required String icon,
    required String label,
  }) {
    return CustomContainer(
      padding: const EdgeInsetsDirectional.all(8),
      color: context.colors.backgroundSecondary,
      borderRadius: UiUtils.borderRadiusOf8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgPicture(
            avoideResponsive: true,
            svgImage: icon,
            height: 16,
            width: 16,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(width: 4),
          CustomText(
            label,
            fontSize: 12,
            maxLines: 1,
            color: context.colors.textPrimary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return SlideAnimationScope(
      builder: (context, controller) => SlideAnimation(
        position: 0,
        itemCount: 1,
        slideDirection: SlideDirection.fromBottom,
        animationController: controller,
        child: CustomContainer(
          key: cardKey,
          width: cardWidth,
          // cardWidth is already an absolute screen-derived value; letting
          // CustomContainer scale it with rw() pushes it past the screen on
          // tablets, so the side margin disappears.
          avoideResponsive: true,
          padding: const EdgeInsetsDirectional.all(12),
          color: context.colors.backgroundPrimary,
          borderRadius: UiUtils.borderRadiusOf12,
          clipBehavior: Clip.antiAlias,
          boxShadow: [
            BoxShadow(
              color: context.colors.overlayFooterShadow,
              blurRadius: 24,
              offset: const Offset(0, 3),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageContainer(
                    borderRadius: 4.8,
                    imageURL: state.providerDetails.image!,
                    height: 48,
                    width: 48,
                    boxFit: BoxFit.cover,
                    boxShadow: const [],
                  ),
                  CustomSizedBox(width: 12.rw(context)),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: CustomText(
                                      state
                                          .providerDetails
                                          .translatedCompanyName!,
                                      fontSize: 16,
                                      maxLines: 1,
                                      color: context.colors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (state.providerDetails.isVerified ==
                                      true) ...[
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
                              if (state.providerDetails.ratings! != '0.0') ...[
                                const CustomSizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      reviewScreen,
                                      arguments: {
                                        'providerDetails':
                                            state.providerDetails,
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CustomSvgPicture(
                                        avoideResponsive: true,
                                        svgImage: AppAssets.icStar,
                                        height: 20,
                                        width: 20,
                                        color: context.colors.iconWarning,
                                      ),
                                      const CustomSizedBox(width: 4),
                                      CustomText(
                                        double.parse(
                                          state.providerDetails.ratings!,
                                        ).toString(),
                                        fontSize: 14,
                                        color: context.colors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      const CustomSizedBox(width: 4),
                                      CustomText(
                                        '(${state.providerDetails.numberOfRatings} ${"reviews".translate(context: context)})',
                                        fontSize: 12,
                                        color: context.colors.textTertiary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        BlocBuilder<UserDetailsCubit, UserDetailsState>(
                          builder: (context, userDetails) {
                            final token = HiveRepository.getUserToken;
                            if (state.providerDetails.isPreBookingChatAllowed !=
                                    "1" ||
                                token == '') {
                              return const CustomSizedBox();
                            }
                            return CustomInkWellContainer(
                              borderRadius: BorderRadius.circular(
                                UiUtils.borderRadiusOf8,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  chatMessages,
                                  arguments: {
                                    "chatUser": ChatUser(
                                      id:
                                          state.providerDetails.providerId ??
                                          "",
                                      name: state
                                          .providerDetails
                                          .translatedCompanyName
                                          .toString(),
                                      translatedName: state
                                          .providerDetails
                                          .translatedCompanyName
                                          .toString(),
                                      chatUserType:
                                          ChatUserType.providerEnquiry,
                                      partnerId:
                                          state.providerDetails.providerId ??
                                          "",
                                      unReadChats: 0,
                                      profile: state.providerDetails.image,
                                    ),
                                  },
                                );
                              },
                              child: CustomContainer(
                                padding: const EdgeInsetsDirectional.all(8),
                                color: context.colors.backgroundBrandSubtle,
                                borderRadius: UiUtils.borderRadiusOf8,
                                child: CustomSvgPicture(
                                  svgImage: AppAssets.chat,
                                  color: context.colors.textBrand,
                                  avoideResponsive: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              CustomSizedBox(height: 8.rh(context)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _infoChip(
                      context,
                      icon: AppAssets.mapPinArea,
                      label:
                          '${double.parse(state.providerDetails.distance ?? '0').ceil()} ${context.read<SystemSettingCubit>().systemDistanceUnit} ${"distance".translate(context: context)}',
                    ),
                    if ((state.providerDetails.providerType ?? '')
                        .isNotEmpty) ...[
                      const CustomSizedBox(width: 8),
                      _infoChip(
                        context,
                        icon: AppAssets.users,
                        label: state.providerDetails.providerType!,
                      ),
                    ],
                    if (state.providerDetails.isAtStoreAvailable == "1" ||
                        state.providerDetails.isAtDoorstepAvailable == "1") ...[
                      const CustomSizedBox(width: 8),
                      _infoChip(
                        context,
                        icon: AppAssets.storeOutline,
                        label:
                            state.providerDetails.isAtStoreAvailable == "1" &&
                                state.providerDetails.isAtDoorstepAvailable ==
                                    "1"
                            ? "storeAndDoorstepAllowed".translate(
                                context: context,
                              )
                            : state.providerDetails.isAtStoreAvailable == "1"
                            ? "atStoreAllowed".translate(context: context)
                            : "doorstepAllowed".translate(context: context),
                      ),
                    ],
                    if ((state.providerDetails.numberOfOrders ?? '0') !=
                        '0') ...[
                      const CustomSizedBox(width: 8),
                      _infoChip(
                        context,
                        icon: AppAssets.checkCircle,
                        label:
                            '${state.providerDetails.numberOfOrders}+ ${"bookingCompleted".translate(context: context)}',
                      ),
                    ],
                  ],
                ),
              ),
              if (promocodeList.isNotEmpty) ...[
                CustomSizedBox(height: 12.rh(context)),
                CustomSizedBox(
                  height: 1,
                  width: double.infinity,
                  child: DashedRect(
                    color: context.colors.borderStrong,
                    strokeWidth: 1,
                    gap: 4,
                  ),
                ),
                CustomSizedBox(height: 6.rh(context)),
                SliderPromocode(
                  height: 50.rh(context),
                  promocode: promocodeList,
                  calculatedWidth: (cardWidth ?? 0) - 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
