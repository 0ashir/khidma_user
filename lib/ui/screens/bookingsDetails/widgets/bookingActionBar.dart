import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingActionBar extends StatelessWidget {
  const BookingActionBar({
    required this.booking,
    required this.isBookingCompleted,
    required this.showReorder,
    required this.canReschedule,
    required this.isBookingCancelable,
    required this.hasUnpaidAdditionalCharges,
    required this.totalAdditionalCharge,
    required this.onReschedule,
    required this.onPayAdditionalCharges,
    required this.onCancel,
    super.key,
  });

  final BookingDetailModel booking;
  final bool isBookingCompleted;

  /// Show the re-order button next to the invoice button.
  final bool showReorder;
  final bool canReschedule;
  final bool isBookingCancelable;
  final bool hasUnpaidAdditionalCharges;
  final String totalAdditionalCharge;
  final VoidCallback onReschedule;
  final VoidCallback onPayAdditionalCharges;
  final VoidCallback onCancel;

  @override
  Widget build(final BuildContext context) {
    Widget content;
    if (isBookingCompleted) {
      content = Row(
        children: [
          Expanded(
            child: DownloadInvoiceButton(
              bookingId: booking.id ?? '',
              buttonScreenName: "bookingDetails",
              large: true,
            ),
          ),
          if (showReorder) ...[
            const CustomSizedBox(width: 12),
            Expanded(
              child: ReOrderButton(
                bookingId: booking.id ?? '0',
                detailBooking: booking,
                isReorderFrom: "bookingDetails",
                large: true,
              ),
            ),
          ],
        ],
      );
    } else {
      final List<Widget> secondaryActions = [
        if (canReschedule)
          Expanded(
            child: _buildLargeOutlineActionButton(
              context,
              label: 'reschedule',
              onTap: onReschedule,
            ),
          ),
        if (canReschedule && isBookingCancelable)
          const CustomSizedBox(width: 12),
        if (isBookingCancelable) Expanded(child: _buildCancelButton(context)),
      ];
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUnpaidAdditionalCharges) ...[
            _buildLargeBrandActionButton(
              context,
              label: 'payAdditionalCharges',
              onTap: onPayAdditionalCharges,
              trailingText: totalAdditionalCharge.priceFormat(
                context,
                currencySymbol: booking.currencySymbol,
                decimalPlaces: booking.currencyDecimalPlaces,
              ),
            ),
            if (secondaryActions.isNotEmpty) const CustomSizedBox(height: 12),
          ],
          if (secondaryActions.isNotEmpty) Row(children: secondaryActions),
        ],
      );
    }

    return ClipShadowBottom(
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
        boxShadow: [
          BoxShadow(
            color: context.colors.overlayFooterShadow,
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
        child: content,
      ),
    );
  }

  Widget _buildLargeOutlineActionButton(
    final BuildContext context, {
    required final String label,
    required final VoidCallback onTap,
  }) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        padding: const EdgeInsets.all(12),
        color: context.colors.backgroundBrandSubtle,
        border: Border.all(color: context.colors.borderBrand),
        borderRadius: UiUtils.borderRadiusOf12,
        alignment: Alignment.center,
        child: CustomText(
          label.translate(context: context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: context.colors.textBrand,
        ),
      ),
    );
  }

  Widget _buildLargeBrandActionButton(
    final BuildContext context, {
    required final String label,
    required final VoidCallback onTap,
    final String? trailingText,
  }) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: context.colors.backgroundBrand,
        borderRadius: UiUtils.borderRadiusOf12,
        alignment: Alignment.center,
        child: CustomText(
          trailingText == null
              ? label.translate(context: context)
              : '${label.translate(context: context)} ($trailingText)',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: context.colors.textInverseLight,
        ),
      ),
    );
  }

  Widget _buildCancelButton(context) {
    return BlocBuilder<ChangeBookingStatusCubit, ChangeBookingStatusState>(
      builder:
          (final BuildContext context, final ChangeBookingStatusState state) {
            final bool isCancelling =
                state is ChangeBookingStatusInProgress &&
                state.pressedButtonName == 'cancelBooking' &&
                state.bookingId == booking.id;

            return CustomInkWellContainer(
              onTap: isCancelling ? null : onCancel,
              borderRadius: BorderRadius.circular(12),
              child: CustomContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: context.colors.backgroundErrorSubtle,
                border: Border.all(color: context.colors.borderError),
                borderRadius: 12,
                child: Center(
                  child: isCancelling
                      ? CustomCircularProgressIndicator(
                          color: context.colors.iconError,
                        )
                      : CustomText(
                          'cancel'.translate(context: context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textError,
                        ),
                ),
              ),
            );
          },
    );
  }
}
