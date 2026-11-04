import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Cart services block of the checkout screen. [footerBuilder] supplies the
/// widgets shown under the service rows (add-more / instruction pills).
class CheckoutServicesCard extends StatelessWidget {
  const CheckoutServicesCard({
    required this.isFrom,
    required this.footerBuilder,
    super.key,
  });

  final String isFrom;
  final List<Widget> Function(String? providerId) footerBuilder;

  @override
  Widget build(final BuildContext context) => BlocBuilder<CartCubit, CartState>(
    builder: (final BuildContext context, final CartState state) {
      if (state is CartFetchSuccess) {
        if (state.cartData.cartDetails == null &&
            state.reOrderCartData?.cartDetails == null) {
          return const CustomSizedBox();
        }
        final List<CartDetails> source = isFrom == "cart"
            ? state.cartData.cartDetails ?? const []
            : isFrom == "customJobRequest"
            ? const []
            : state.reOrderCartData?.cartDetails ?? const [];

        // The cart API can return a service split across more than one
        // row (e.g. added in separate requests) — merge by serviceId so
        // the UI shows one row per service with the true total quantity,
        // instead of duplicate rows that each look like "1x".
        final List<CartDetails> rows = [];
        final Map<String, int> qtyByServiceId = {};
        for (final detail in source) {
          final String? id = detail.serviceId;
          final int qty = int.tryParse(detail.qty ?? '0') ?? 0;
          if (id != null && id.isNotEmpty) {
            if (qtyByServiceId.containsKey(id)) {
              qtyByServiceId[id] = qtyByServiceId[id]! + qty;
              continue;
            }
            qtyByServiceId[id] = qty;
          }
          rows.add(detail);
        }
        final int itemCount = rows.length;
        return CustomContainer(
          padding: const EdgeInsets.all(12),
          color: context.colors.surfacePrimary,
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: itemCount,
                separatorBuilder: (final context, final index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: context.colors.borderDefault,
                  ),
                ),
                itemBuilder: (final context, index) {
                  final CartDetails cartDetails = rows[index];
                  final int mergedQty =
                      qtyByServiceId[cartDetails.serviceId] ??
                      int.tryParse(cartDetails.qty ?? '0') ??
                      0;
                  final String? discountedPrice =
                      cartDetails.serviceDetails?.discountedPrice;
                  final bool hasDiscount =
                      discountedPrice != null &&
                      discountedPrice.isNotEmpty &&
                      discountedPrice != '0' &&
                      discountedPrice != '0.0' &&
                      discountedPrice != '0.00';
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomImageContainer(
                        borderRadius: 8.8,
                        imageURL:
                            cartDetails.serviceDetails?.imageOfTheService ?? '',
                        height: 44,
                        width: 44,
                        boxFit: BoxFit.cover,
                        boxShadow: const [],
                      ),
                      const CustomSizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              cartDetails.serviceDetails?.translatedTitle ?? '',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              maxLines: 2,
                              color: context.colors.textPrimary,
                            ),
                            const CustomSizedBox(height: 4),
                            CustomText(
                              (hasDiscount
                                      ? discountedPrice
                                      : cartDetails.serviceDetails?.price ??
                                            '0')
                                  .countryPriceFormat(context),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                      const CustomSizedBox(width: 10),
                      if (isFrom == "cart" &&
                          (cartDetails.serviceId?.isNotEmpty ?? false))
                        MultiBlocProvider(
                          // Scoped per row — a single shared cubit instance
                          // (as provided at the screen level) would make the
                          // in-progress shimmer show on every service row
                          // whenever any one of them was being mutated.
                          providers: [
                            BlocProvider<AddServiceIntoCartCubit>(
                              create: (final BuildContext context) =>
                                  AddServiceIntoCartCubit(CartRepository()),
                            ),
                            BlocProvider<RemoveServiceFromCartCubit>(
                              create: (final BuildContext context) =>
                                  RemoveServiceFromCartCubit(CartRepository()),
                            ),
                          ],
                          child: AddButton(
                            serviceId: cartDetails.serviceId!,
                            providerId: state.cartData.providerId ?? '',
                            serviceProviderName:
                                state.cartData.translatedProviderName ??
                                state.cartData.providerName,
                            alreadyAddedQuantity: mergedQty,
                            maximumAllowedQuantity:
                                int.tryParse(
                                  cartDetails
                                          .serviceDetails
                                          ?.maxQuantityAllowed ??
                                      '10',
                                ) ??
                                10,
                            backgroundColor:
                                context.colors.backgroundBrandSubtle,
                            height: 32,
                            padding: 8,
                            iconSize: 16,
                            countFontSize: 16,
                          ),
                        )
                      else
                        CustomContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: context.colors.backgroundBrandSubtle,
                          border: Border.all(color: context.colors.borderBrand),
                          borderRadius: 8,
                          child: CustomText(
                            '${mergedQty}x',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: context.colors.textBrand,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const CustomSizedBox(height: 12),
              ...footerBuilder(state.cartData.providerId),
            ],
          ),
        );
      }
      return const CustomSizedBox();
    },
  );
}
