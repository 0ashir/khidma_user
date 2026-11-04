import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AboutProviderContainer extends StatelessWidget {
  const AboutProviderContainer({super.key, required this.providerDetails});

  final Providers providerDetails;

  static const List<String> _dayOrder = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static int? _minutesSinceMidnight(String raw) {
    final List<String> parts = raw.split(':');
    if (parts.length < 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  bool get _isOpenNow {
    final String todayKey = _dayOrder[DateTime.now().weekday - 1];
    final DayShifts? today = providerDetails.shiftsByDay[todayKey];
    if (today == null) return false;
    final DateTime now = DateTime.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    for (final ProviderShift shift in today.activeShifts) {
      final int? open = _minutesSinceMidnight(shift.openingTime);
      final int? close = _minutesSinceMidnight(shift.closingTime);
      if (open == null || close == null) continue;
      if (close > open) {
        if (nowMinutes >= open && nowMinutes < close) return true;
      } else if (nowMinutes >= open || nowMinutes < close) {
        return true;
      }
    }
    return false;
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    Widget? trailing,
    required Widget child,
    bool isShowDivider = true,
  }) {
    return CustomContainer(
      width: double.infinity,
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (isShowDivider)
            CustomContainer(height: 1, color: context.colors.borderMuted),
          child,
        ],
      ),
    );
  }

  Widget _openNowPill(BuildContext context) {
    return CustomContainer(
      color: context.colors.backgroundBrandSubtle,
      borderRadius: 4,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          CustomContainer(
            height: 8,
            width: 8,
            shape: BoxShape.circle,
            color: context.colors.textBrand,
          ),
          CustomText(
            'openNow'.translate(context: context),
            fontSize: 12,
            color: context.colors.textBrand,
          ),
        ],
      ),
    );
  }

  Widget _aboutCard(BuildContext context) {
    return _sectionCard(
      context: context,
      title: 'aboutProvider'.translate(context: context),
      child: ReadMoreText(
        providerDetails.translatedAbout ?? '',
        trimLines: 3,
        trimMode: TrimMode.Line,
        style: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          color: context.colors.textSecondary,
        ),
        trimCollapsedText: 'readMore'.translate(context: context),
        trimExpandedText: 'showLess'.translate(context: context),
        moreStyle: TextStyle(fontSize: 14, color: context.colors.textBrand),
        lessStyle: TextStyle(fontSize: 14, color: context.colors.textBrand),
      ),
    );
  }

  Widget _shiftTime(BuildContext context, ProviderShift shift) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.clock,
          height: 16,
          width: 16,
          color: context.colors.iconPrimary,
        ),
        // Flexible so a narrow tablet grid cell wraps instead of overflowing.
        Flexible(
          child: CustomText(
            '${shift.openingTime.formatTime()} - ${shift.closingTime.formatTime()}',
            fontSize: 12,
            color: context.colors.textPrimary,
            showLineThrough: shift.onLeave,
          ),
        ),
      ],
    );
  }

  Widget _dayShiftsCard(BuildContext context, String day, DayShifts shifts) {
    final List<Widget> times = shifts.shifts
        .map((final shift) => _shiftTime(context, shift))
        .toList();

    return CustomContainer(
      width: double.infinity,
      color: context.colors.backgroundSecondary,
      borderRadius: UiUtils.borderRadiusOf8,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          CustomText(
            day.translate(context: context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          CustomContainer(
            width: double.infinity,
            color: context.colors.backgroundPrimary,
            borderRadius: UiUtils.borderRadiusOf8,
            padding: const EdgeInsets.all(8),
            child: ResponsiveHelper.isTabletDevice(context)
                ? EqualHeightGrid(columns: 4, spacing: 8, children: times)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: times,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _closedDayRow(BuildContext context, String day) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            day.translate(context: context),
            fontSize: 14,
            color: context.colors.textPrimary,
          ),
        ),
        CustomText(
          'closed'.translate(context: context),
          fontSize: 14,
          color: context.colors.textError,
        ),
      ],
    );
  }

  Widget _businessHoursCard(BuildContext context, List<String> days) {
    return _sectionCard(
      context: context,
      title: 'businessHours'.translate(context: context),
      trailing: _isOpenNow ? _openNowPill(context) : null,
      isShowDivider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < days.length; i++) ...[
            if (i != 0) ...[
              const CustomSizedBox(height: 16),
              CustomSizedBox(
                height: 1,
                width: double.infinity,
                child: DashedRect(
                  color: context.colors.borderStrong,
                  strokeWidth: 1,
                  gap: 4,
                ),
              ),
              const CustomSizedBox(height: 16),
            ],
            Builder(
              builder: (final _) {
                final DayShifts shifts = providerDetails.shiftsByDay[days[i]]!;
                final bool hasShifts =
                    shifts.isOpen && shifts.shifts.isNotEmpty;
                return hasShifts
                    ? _dayShiftsCard(context, days[i], shifts)
                    : _closedDayRow(context, days[i]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _locationCard(BuildContext context) {
    final String rawAddress = providerDetails.address ?? '';
    final int commaIndex = rawAddress.indexOf(',');
    final String addressLine1 = commaIndex == -1
        ? rawAddress
        : rawAddress.substring(0, commaIndex).trim();
    final String addressLine2 = commaIndex == -1
        ? ''
        : rawAddress.substring(commaIndex + 1).trim();
    final double latitude =
        double.tryParse(providerDetails.latitude ?? '') ?? 0.0;
    final double longitude =
        double.tryParse(providerDetails.longitude ?? '') ?? 0.0;

    return _sectionCard(
      context: context,
      title: 'location'.translate(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            child: Stack(
              children: [
                CustomSizedBox(
                  height: 200,
                  width: double.infinity,
                  child: AppMapView(
                    initialCenter: AppLatLng(latitude, longitude),
                    initialZoom: 12,
                    zoomControlsEnabled: false,
                    liteMode: Platform.isAndroid,
                    scrollGesturesEnabled: false,
                    markers: [
                      AppMapMarker(
                        id: providerDetails.id.toString(),
                        position: AppLatLng(latitude, longitude),
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      ClarityService.logAction(
                        ClarityActions.serviceDetailContactTapped,
                        {
                          'provider_id': providerDetails.id ?? '',
                          'provider_name':
                              providerDetails.translatedCompanyName ??
                              providerDetails.companyName ??
                              '',
                          'action_type': 'open_map',
                        },
                      );
                      UiUtils.openMap(
                        context,
                        latitude: latitude,
                        longitude: longitude,
                      );
                    },
                    child: CustomContainer(
                      shape: BoxShape.circle,
                      color: context.colors.backgroundInverse,
                      padding: const EdgeInsets.all(8),
                      child: CustomSvgPicture(
                        avoideResponsive: true,
                        svgImage: AppAssets.arrowsOutSimple,
                        height: 20,
                        width: 20,
                        color: context.colors.textInverseLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              CustomContainer(
                shape: BoxShape.circle,
                color: context.colors.backgroundBrandSubtle,
                padding: const EdgeInsets.all(8),
                child: CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: AppAssets.mapPinArea,
                  height: 24,
                  width: 24,
                  color: context.colors.iconBrand,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    CustomText(
                      addressLine1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      color: context.colors.textPrimary,
                    ),
                    if (addressLine2.isNotEmpty)
                      CustomText(
                        addressLine2,
                        fontSize: 12,
                        maxLines: 1,
                        color: context.colors.textTertiary,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAddress = (providerDetails.address ?? '').isNotEmpty;
    final List<String> daysWithData = _dayOrder
        .where(providerDetails.shiftsByDay.containsKey)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(
        top: 16.rh(context),
        start: 16.rw(context),
        end: 16.rw(context),
        bottom:
            MediaQuery.viewPaddingOf(context).bottom +
            (context.read<CartCubit>().getProviderIDFromCartData() == '0'
                ? 36.rh(context)
                : kBottomNavigationBarHeight.rh(context) + 36.rh(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          if ((providerDetails.translatedAbout ?? '').isNotEmpty)
            _aboutCard(context),
          if (daysWithData.isNotEmpty)
            _businessHoursCard(context, daysWithData),
          if (hasAddress) _locationCard(context),
        ],
      ),
    );
  }
}
