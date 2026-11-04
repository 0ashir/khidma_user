import 'package:e_demand/app/generalImports.dart';

import 'package:flutter/material.dart';

class PromocodeDetailsBottomSheet extends StatelessWidget {
  final Promocode promocodeDetails;

  const PromocodeDetailsBottomSheet({
    super.key,
    required this.promocodeDetails,
  });

  Widget getMessageContainer({
    required final BuildContext context,
    required final String message,
    required int delay,
  }) => AnimationFromBottomSide(
    delay: delay,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: CustomContainer(
              height: 4,
              width: 4,
              shape: BoxShape.circle,
              color: context.colors.iconSecondary,
            ),
          ),
          const CustomSizedBox(width: 8),
          Expanded(
            child: CustomText(
              message,
              fontSize: 12,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = (promocodeDetails.discount ?? '').isNotEmpty;
    final String discountSuffix = promocodeDetails.discountType == "percentage"
        ? '%'
        : promocodeDetails.discountType == "amount"
        ? context.read<SystemSettingCubit>().systemCurrency
        : (promocodeDetails.discountType ?? '');

    return Container(
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.borderDefault,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const CustomSizedBox(height: 16),
            CustomContainer(
              width: double.infinity,
              color: context.colors.backgroundPrimary,
              borderRadius: UiUtils.borderRadiusOf12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          UiUtils.borderRadiusOf10,
                        ),
                        child: CustomCachedNetworkImage(
                          networkImageUrl: promocodeDetails.image ?? '',
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const CustomSizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            CustomText(
                              promocodeDetails.promoCode ?? '',
                              maxLines: 1,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: context.colors.textPrimary,
                            ),
                            if (hasDiscount)
                              CustomContainer(
                                color: context.colors.backgroundBrandSubtle,
                                borderRadius: 4,
                                padding: const EdgeInsets.all(4),
                                child: CustomText(
                                  '${promocodeDetails.discount}$discountSuffix '
                                  '${'off'.translate(context: context)}',
                                  fontSize: 11,
                                  color: context.colors.textBrand,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  CustomContainer(height: 1, color: context.colors.borderMuted),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getMessageContainer(
                        context: context,
                        message: promocodeDetails.message ?? '',
                        delay: 50,
                      ),
                      getMessageContainer(
                        context: context,
                        message:
                            "${'offerIsApplicableOnMinimumValueOf'.translate(context: context)} ${promocodeDetails.minimumOrderAmount!.priceFormat(context)}",
                        delay: 60,
                      ),
                      getMessageContainer(
                        context: context,
                        message:
                            "${'maximumInstantDiscountOf'.translate(context: context)} ${promocodeDetails.maxDiscountAmount!.priceFormat(context)}",
                        delay: 70,
                      ),
                      getMessageContainer(
                        context: context,
                        message:
                            "${'offerValidFrom'.translate(context: context)} ${promocodeDetails.startDate.toString().formatDate()} ${'to'.translate(context: context)} ${promocodeDetails.endDate.toString().formatDate()}",
                        delay: 80,
                      ),
                      if (int.parse(promocodeDetails.noOfRepeatUsage!) > 1)
                        getMessageContainer(
                          context: context,
                          message:
                              "${"applicableMaximum".translate(context: context)} ${promocodeDetails.noOfRepeatUsage} ${"timesDuringCampaignPeriod".translate(context: context)}",
                          delay: 90,
                        ),
                      if (int.parse(promocodeDetails.noOfRepeatUsage!) == 1)
                        getMessageContainer(
                          context: context,
                          message:
                              'offerValidOncePerCustomerDuringCampaignPeriod'
                                  .translate(context: context),
                          delay: 100,
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
