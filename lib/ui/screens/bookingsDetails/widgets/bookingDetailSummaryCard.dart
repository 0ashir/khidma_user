import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingDetailSummaryCard extends StatelessWidget {
  const BookingDetailSummaryCard({
    super.key,
    required this.bookingDetails,
    this.isOTPSystemEnabled = false,
    this.serviceName,
    this.serviceCategory,
    this.servicePrice,
  });

  final BookingDetailModel bookingDetails;
  final bool isOTPSystemEnabled;
  final String? serviceName;
  final String? serviceCategory;
  final String? servicePrice;

  bool get _hasServiceDetails => (serviceName ?? '').isNotEmpty;

  bool get _isAtStore => bookingDetails.bookingType == 'at_store';

  bool get _shouldShowOTP =>
      isOTPSystemEnabled &&
      (bookingDetails.otp ?? '').isNotEmpty &&
      bookingDetails.status != 'cancelled' &&
      bookingDetails.status != 'completed';

  MultipleDaysBookingRange? get _multipleDaysBooking =>
      bookingDetails.multipleDaysBooking;

  bool get _isCancelled => bookingDetails.status == 'cancelled';

  bool get _isPaymentFailedCancellation {
    final String status = (bookingDetails.paymentStatus ?? '').toLowerCase();
    return status == 'failed' || status == '2';
  }

  bool get _hasCancelReason =>
      (bookingDetails.cancellation?.cancelReason ?? '').isNotEmpty;

  bool get _showCancellationInfo =>
      _isCancelled && (_isPaymentFailedCancellation || _hasCancelReason);

  // multi-day booking times arrive as "HH:mm:ssZ"; localeFormatTime()
  // expects a plain "HH:mm" string.
  String _hhmmOf(final String? time) =>
      (time ?? '').length >= 5 ? time!.substring(0, 5) : (time ?? '');

  void _openMap(final BuildContext context) {
    if (!_isAtStore) return;
    UiUtils.openMap(
      context,
      latitude: bookingDetails.provider?.latitude,
      longitude: bookingDetails.provider?.longitude,
    );
  }

  Widget _buildIconRow(
    final BuildContext context, {
    required final String icon,
    required final String text,
    final int maxLines = 1,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomSvgPicture(
        svgImage: icon,
        height: 20,
        width: 20,
        color: context.colors.iconPrimary,
        avoideResponsive: true,
      ),
      const CustomSizedBox(width: 4),
      Flexible(
        child: CustomText(
          text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: context.colors.textPrimary,
          maxLines: maxLines,
        ),
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    color: context.colors.surfacePrimary,
    borderRadius: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    'invoiceNumber'.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                  ),
                  const CustomSizedBox(height: 4),
                  CustomText(
                    '#${bookingDetails.id ?? ''}',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
            ),
            BookingStatusChip(status: bookingDetails.status ?? ''),
          ],
        ),
        const CustomSizedBox(height: 12),

        CustomContainer(height: 1, color: context.colors.borderDefault),
        const CustomSizedBox(height: 16),
        if (_hasServiceDetails) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                serviceName!,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
              if ((serviceCategory ?? '').isNotEmpty) ...[
                const CustomSizedBox(height: 4),
                CustomText(
                  serviceCategory!,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textBrand,
                ),
              ],
              const CustomSizedBox(height: 12),
              CustomText(
                (servicePrice ?? '0').priceFormat(
                  context,
                  currencySymbol: bookingDetails.currencySymbol,
                  decimalPlaces: bookingDetails.currencyDecimalPlaces,
                ),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ],
          ),
          const CustomSizedBox(height: 16),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 16),
        ],
        if (_shouldShowOTP) ...[
          CustomContainer(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: context.colors.backgroundBrandSubtle,
            borderRadius: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                CustomText(
                  'otp'.translate(context: context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
                CustomText(
                  bookingDetails.otp ?? '',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ],
            ),
          ),
          const CustomSizedBox(height: 16),
        ],
        if (_multipleDaysBooking == null)
          Row(
            children: [
              Expanded(
                child: _buildIconRow(
                  context,
                  icon: AppAssets.calendar,
                  text: (bookingDetails.date ?? '').formatDate(),
                ),
              ),
              Expanded(
                child: _buildIconRow(
                  context,
                  icon: AppAssets.clock,
                  text:
                      '${bookingDetails.startTime!.localeFormatTime()} ${'to'.translate(context: context)} ${bookingDetails.endTime!.localeFormatTime()}',
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildIconRow(
                  context,
                  icon: AppAssets.calendar,
                  maxLines: 2,
                  text:
                      '${(_multipleDaysBooking!.startDate ?? '').formatDate()} ${'to'.translate(context: context)} ${(_multipleDaysBooking!.endDate ?? '').formatDate()}',
                ),
              ),
              Expanded(
                child: _buildIconRow(
                  context,
                  icon: AppAssets.clock,
                  maxLines: 2,
                  text:
                      '${_hhmmOf(_multipleDaysBooking!.startTime).localeFormatTime()} ${'to'.translate(context: context)} ${_hhmmOf(_multipleDaysBooking!.endTime).localeFormatTime()}',
                ),
              ),
            ],
          ),
        const CustomSizedBox(height: 12),
        CustomInkWellContainer(
          showRippleEffect: false,
          onTap: () => _openMap(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSvgPicture(
                svgImage: AppAssets.mapPinArea,
                height: 20,
                width: 20,
                color: context.colors.iconPrimary,
                avoideResponsive: true,
              ),
              const CustomSizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      (_isAtStore ? 'atStore' : 'atHome').translate(
                        context: context,
                      ),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textBrand,
                    ),
                    const CustomSizedBox(height: 4),
                    CustomText(
                      bookingDetails.address ?? '',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showCancellationInfo) ...[
          const CustomSizedBox(height: 16),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 16),
          _buildCancellationInfoBox(context),
        ],
      ],
    ),
  );

  Widget _buildCancellationInfoBox(final BuildContext context) {
    if (_isPaymentFailedCancellation) {
      return CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: context.colors.backgroundErrorSubtle,
        borderRadius: 8,
        child: CustomText(
          'bookingCancelledPaymentFailed'.translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textError,
        ),
      );
    }
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: context.colors.backgroundErrorSubtle,
      borderRadius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'cancellationReason'.translate(context: context),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
          ),
          const CustomSizedBox(height: 4),
          CustomText(
            bookingDetails.cancellation?.cancelReason ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ],
      ),
    );
  }
}
