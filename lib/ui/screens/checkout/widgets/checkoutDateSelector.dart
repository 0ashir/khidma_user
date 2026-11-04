import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CheckoutDateSelector extends StatelessWidget {
  const CheckoutDateSelector({
    required this.selectedDate,
    required this.selectedTime,
    required this.message,
    required this.isFrom,
    required this.providerId,
    required this.providerAdvanceBookingDays,
    required this.orderId,
    required this.customJobRequestId,
    required this.onSaved,
    super.key,
  });

  final dynamic selectedDate;
  final dynamic selectedTime;
  final String? message;
  final String isFrom;
  final String providerId;
  final String providerAdvanceBookingDays;
  final String? orderId;
  final String? customJobRequestId;

  final void Function(String date, dynamic time, String? message) onSaved;

  @override
  Widget build(final BuildContext context) {
    final bool hasDateTimeSelection =
        selectedDate != null && selectedTime != null;
    void onDateSelectorTap() {
      UiUtils.removeFocus();
      final cartState = context.read<CartCubit>().state;
      final String advanceDays =
          (isFrom == "cart" && cartState is CartFetchSuccess)
          ? ((cartState.cartData.advanceBookingDays?.isNotEmpty ?? false)
                ? cartState.cartData.advanceBookingDays!
                : providerAdvanceBookingDays)
          : providerAdvanceBookingDays;
      final String currentProviderId =
          (isFrom == "cart" && cartState is CartFetchSuccess)
          ? ((cartState.cartData.providerId?.isNotEmpty ?? false)
                ? cartState.cartData.providerId!
                : providerId)
          : providerId;

      UiUtils.showBottomSheet(
        enableDrag: true,
        context: context,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ValidateCustomTimeCubit>(
              create: (context) =>
                  ValidateCustomTimeCubit(cartRepository: CartRepository()),
            ),
            BlocProvider(
              create: (final BuildContext context) =>
                  TimeSlotCubit(CartRepository()),
            ),
          ],
          child: CalenderBottomSheet(
            orderId: orderId,
            customJobRequestId: customJobRequestId,
            advanceBookingDays: advanceDays,
            providerId: currentProviderId,
            selectedDate: selectedDate == null
                ? null
                : DateTime.parse(selectedDate),
            selectedTime: selectedTime,
          ),
        ),
      ).then((final value) {
        if (value != null) {
          if (value["isSaved"]) {
            onSaved(
              intl.DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.parse("${value['selectedDate']}")),
              value["selectedTime"],
              value["message"],
            );
          }
        }
      });
    }

    return CustomContainer(
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomContainer(
                padding: const EdgeInsets.all(8),
                color: context.colors.backgroundSecondary,
                borderRadius: 12,
                child: CustomSvgPicture(
                  svgImage: AppAssets.calendar,
                  height: 16,
                  width: 16,
                  color: context.colors.iconPrimary,
                  avoideResponsive: true,
                ),
              ),
              const CustomSizedBox(width: 8),
              Expanded(
                child: CustomText(
                  'selectDateAndTime'.translate(context: context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  color: context.colors.textPrimary,
                ),
              ),
              CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: onDateSelectorTap,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        'viewAll'.translate(context: context),
                        fontSize: 14,
                        color: context.colors.textBrand,
                      ),
                      const CustomSizedBox(width: 4),
                      CustomSvgPicture(
                        svgImage:
                            Directionality.of(context) == TextDirection.rtl
                            ? AppAssets.backArrow
                            : AppAssets.backArrowLtr,
                        height: 20,
                        width: 20,
                        color: context.colors.iconBrand,
                        avoideResponsive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const CustomSizedBox(height: 12),
          Divider(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: CustomContainer(
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundSecondary,
              border: Border.all(color: context.colors.borderDefault),
              borderRadius: 8,
              child: CustomText(
                hasDateTimeSelection
                    ? '${selectedDate.toString().formatDate()}, ${selectedTime.toString().formatTime()}'
                    : 'pleaseSelectDateAndTime'.translate(context: context),
                fontSize: 12,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          if (hasDateTimeSelection && message != null && message != '') ...[
            const CustomSizedBox(height: 4),
            CustomText(
              'orderWillBeScheduledForTheMultipleDays'.translate(
                context: context,
              ),
              fontSize: 11,
              color: context.colors.textBrand,
            ),
          ],
        ],
      ),
    );
  }
}
