import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddToCartComtainer extends StatelessWidget {
  const AddToCartComtainer({super.key});

  void _continueToSchedule(BuildContext context, Cart cartData) {
    Navigator.pushNamed(
      context,
      scheduleScreenRoute,
      arguments: {
        "isFrom": "cart",
        "providerName": cartData.translatedProviderName ?? '',
        "providerId": cartData.providerId ?? "0",
        "companyName": cartData.translatedCompanyName ?? '',
        "providerAdvanceBookingDays": cartData.advanceBookingDays ?? '',
        "cartFromProvider": true,
      },
    );
  }

  Widget _avatarStack(BuildContext context, List<String> images) {
    const double size = 24;
    const double borderWidth = 1.5;
    const double imageSize = size - borderWidth * 2;
    const double overlapOffset = 16;
    return SizedBox(
      height: size,
      width: size + (images.length - 1) * overlapOffset,
      child: Stack(
        children: [
          for (int i = images.length - 1; i >= 0; i--)
            PositionedDirectional(
              start: i * overlapOffset,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.textInverseLight,
                    width: borderWidth,
                  ),
                ),
                child: CustomImageContainer(
                  borderRadius: imageSize / 2,
                  imageURL: images[i],
                  height: imageSize,
                  width: imageSize,
                  boxFit: BoxFit.cover,
                  boxShadow: const [],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, final CartState state) {
        if (state is! CartFetchSuccess) {
          return const CustomSizedBox();
        }
        final totalQty = int.tryParse(state.cartData.totalQuantity ?? '0') ?? 0;
        if (totalQty == 0 ||
            state.cartData.cartDetails == null ||
            state.cartData.cartDetails!.isEmpty) {
          return const CustomSizedBox();
        }

        final List<String> avatarImages = state.cartData.cartDetails!
            .map(
              (final detail) => detail.serviceDetails?.imageOfTheService ?? '',
            )
            .where((final url) => url.isNotEmpty)
            .take(3)
            .toList();

        return Container(
          width: double.infinity,
          color: context.colors.backgroundPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: CustomContainer(
              height: 48,
              width: double.infinity,
              color: context.colors.backgroundBrand,
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 8,
                children: [
                  if (avatarImages.isNotEmpty)
                    _avatarStack(context, avatarImages),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: CustomText(
                            '$totalQty ${(totalQty > 1 ? "services" : "service").translate(context: context)}',
                            maxLines: 1,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textInverseLight,
                          ),
                        ),
                        const CustomSizedBox(width: 4),
                        CustomContainer(
                          height: 4,
                          width: 4,
                          shape: BoxShape.circle,
                          color: context.colors.textInverseLight,
                        ),
                        const CustomSizedBox(width: 4),
                        CustomText(
                          (state.cartData.subTotal ?? '0').countryPriceFormat(
                            context,
                          ),
                          maxLines: 1,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textInverseLight,
                        ),
                      ],
                    ),
                  ),
                  CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _continueToSchedule(context, state.cartData),
                    child: CustomContainer(
                      color: context.colors.backgroundBrand,
                      borderRadius: 8,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          CustomText(
                            'continueText'.translate(context: context),
                            fontSize: 14,
                            color: context.colors.textInverseLight,
                          ),
                          CustomSvgPicture(
                            avoideResponsive: true,
                            svgImage:
                                Directionality.of(context).toString().contains(
                                  TextDirection.RTL.value.toLowerCase(),
                                )
                                ? AppAssets.backArrow
                                : AppAssets.backArrowLtr,
                            height: 18,
                            width: 18,
                            color: context.colors.iconInverseLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
