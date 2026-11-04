import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ReOrderButton extends StatelessWidget {
  final String bookingId;
  final String isReorderFrom;
  final BookingListItem? listBooking;
  final BookingDetailModel? detailBooking;
  final double? textSize;
  final String cardFrom;
  final bool compact;
  final bool large;

  const ReOrderButton({
    super.key,
    required this.bookingId,
    required this.isReorderFrom,
    this.listBooking,
    this.detailBooking,
    this.textSize,
    this.cardFrom = 'booking',
    this.compact = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (final BuildContext context, CartState state) {
        if (state is CartFetchFailure) {
          //sss
          UiUtils.showMessage(
            context,
            state.errorMessage,
            ToastificationType.error,
          );
        } else if (state is CartFetchSuccess) {
          if (state.isReorderCart &&
              state.reOrderId == bookingId &&
              (listBooking != null
                  ? listBooking == state.listBooking
                  : detailBooking == state.detailBooking) &&
              isReorderFrom == state.isReorderFrom) {
            //
            context.read<GetAllPromocodesCubit>().getAllPromocodes(
              providerIdOrSlug: state.reOrderCartData?.providerId ?? "0",
            );
            //
            Navigator.pushNamed(
              context,
              scheduleScreenRoute,
              arguments: {
                "isFrom": "reBooking",
                "providerName": state.reOrderCartData?.translatedProviderName,
                "providerId": state.reOrderCartData?.providerId,
                "companyName": state.reOrderCartData?.translatedCompanyName,
                "providerAdvanceBookingDays":
                    state.reOrderCartData?.advanceBookingDays,
                "orderID": state.reOrderId,
              },
            );
          }
        }
      },
      builder: (final BuildContext context, final CartState state) {
        Widget? child;
        if (state is CartFetchInProgress) {
          if (state.reOrderId == bookingId)
            child = CustomCircularProgressIndicator(
              color: context.colors.textInverseLight,
            );
        }
        //
        final VoidCallback onTap = () {
          if (state is CartFetchInProgress) {
            return;
          }
          context.read<CartCubit>().getCartDetails(
            isReorderFrom: isReorderFrom,
            listBooking: listBooking,
            detailBooking: detailBooking,
            reOrderId: bookingId,
            isReorderCart: true,
          );
        };

        if (large) {
          return CustomInkWellContainer(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
            onTap: onTap,
            child: CustomContainer(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              color: context.colors.backgroundBrand,
              borderRadius: UiUtils.borderRadiusOf12,
              alignment: Alignment.center,
              child: child != null
                  ? CustomCircularProgressIndicator(
                      color: context.colors.textInverseLight,
                    )
                  : CustomText(
                      'reBooking'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textInverseLight,
                    ),
            ),
          );
        }

        if (compact) {
          return CustomInkWellContainer(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            onTap: onTap,
            child: CustomContainer(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              color: context.colors.backgroundBrand,
              borderRadius: UiUtils.borderRadiusOf8,
              alignment: Alignment.center,
              child: child != null
                  ? CustomCircularProgressIndicator(
                      color: context.colors.textInverseLight,
                      widthAndHeight: 20,
                    )
                  : CustomText(
                      'reBooking'.translate(context: context),
                      fontSize: 14,
                      color: context.colors.textInverseLight,
                    ),
            ),
          );
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomRoundedButton(
            onTap: onTap,
            backgroundColor: cardFrom == 'home'
                ? context.colors.backgroundBrand
                : context.colors.backgroundBrandSubtle,
            buttonTitle: 'reBooking'.translate(context: context),
            showBorder: false,
            widthPercentage: 0.9,
            fontWeight: FontWeight.w400,
            radius: UiUtils.borderRadiusOf5,
            titleColor: cardFrom == 'home'
                ? context.colors.textInverseLight
                : context.colors.textBrand,
            shadowColor: context.colors.backgroundBrandSubtle,
            textSize: textSize,
            child: child,
          ),
        );
      },
    );
  }
}
