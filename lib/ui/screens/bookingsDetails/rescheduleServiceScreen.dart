import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RescheduleServiceScreen extends StatefulWidget {
  const RescheduleServiceScreen({
    super.key,
    required this.bookingDetails,
    this.initialSelectedDate,
    this.initialSelectedTime,
  });

  final BookingDetailModel bookingDetails;
  final DateTime? initialSelectedDate;
  final String? initialSelectedTime;

  static Route route(final RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => TimeSlotCubit(CartRepository())),
          BlocProvider(
            create: (context) =>
                ValidateCustomTimeCubit(cartRepository: CartRepository()),
          ),
        ],
        child: RescheduleServiceScreen(
          bookingDetails: parameters["bookingDetails"],
          initialSelectedDate: parameters["selectedDate"],
          initialSelectedTime: parameters["selectedTime"],
        ),
      ),
    );
  }

  @override
  State<RescheduleServiceScreen> createState() =>
      _RescheduleServiceScreenState();
}

class _RescheduleServiceScreenState extends State<RescheduleServiceScreen> {
  late DateTime selectedDate;
  String? selectedTime;
  String? message;

  late DateTime _displayedMonth;
  late DateTime _minDate;
  late DateTime _maxDate;

  static const List<String> _weekdayKeys = [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
  ];

  String get _providerId =>
      widget.bookingDetails.provider?.providerId?.toString() ?? '';

  String? get _customJobRequestId => widget.bookingDetails.customJobRequest?.id;

  int get _advanceBookingDays {
    final int? parsed = int.tryParse(
      widget.bookingDetails.provider?.advanceBookingDays ?? '',
    );
    return (parsed != null && parsed > 0) ? parsed : 30;
  }

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _minDate = DateTime(now.year, now.month, now.day);
    _maxDate = _minDate.add(Duration(days: _advanceBookingDays - 1));
    selectedDate = widget.initialSelectedDate ?? _minDate;
    selectedTime = widget.initialSelectedTime;
    _displayedMonth = DateTime(selectedDate.year, selectedDate.month);

    ClarityService.logAction(ClarityActions.timeslotPickerOpened, {
      'provider_id': _providerId,
      'selected_date': selectedDate,
      'custom_job_request_id': _customJobRequestId ?? '',
    });

    Future.delayed(Duration.zero).then((final value) {
      fetchTimeSlots();
    });
  }

  void fetchTimeSlots() {
    context.read<TimeSlotCubit>().getTimeslotDetails(
      providerID: int.tryParse(_providerId) ?? 0,
      selectedDate: selectedDate,
      customJobRequestId: _customJobRequestId ?? '',
    );
  }

  void _selectDate(final DateTime date) {
    if (_isSameDay(date, selectedDate)) return;
    setState(() {
      selectedDate = date;
      selectedTime = null;
      message = null;
    });
    fetchTimeSlots();
  }

  bool _isSameDay(final DateTime a, final DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        titleWidget: CustomText(
          'rescheduleService'.translate(context: context),
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopCard(),
                  const CustomSizedBox(height: 24),
                  _buildDateAndTimeSections(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    ),
  );

  Widget _buildSectionHeading(final String key) => CustomText(
    key.translate(context: context),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: context.colors.textPrimary,
  );

  Widget _buildSection(final String headingKey, final Widget content) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [_buildSectionHeading(headingKey), content],
  );

  // Tablet places date and time side by side; phone stacks them.
  Widget _buildDateAndTimeSections() {
    final Widget dateSection = _buildSection(
      'selectDateOfService',
      _buildCalendarCard(),
    );
    final Widget timeSection = _buildSection(
      'selectTimeOfService',
      _buildTimeSection(),
    );
    if (ResponsiveHelper.isTabletDevice(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          Expanded(child: dateSection),
          Expanded(child: timeSection),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [dateSection, timeSection],
    );
  }

  Widget _buildIconRow({
    required final String icon,
    required final String text,
    final double fontSize = 14,
    final FontWeight fontWeight = FontWeight.w400,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSvgPicture(
        svgImage: icon,
        height: 20,
        width: 20,
        color: context.colors.iconPrimary,
        avoideResponsive: true,
      ),
      const CustomSizedBox(width: 8),
      Expanded(
        child: CustomText(
          text,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: context.colors.textPrimary,
          maxLines: 1,
        ),
      ),
    ],
  );

  Widget _buildTopCard() {
    final booking = widget.bookingDetails;
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildIconRow(
                  icon: AppAssets.calendar,
                  text: booking.date ?? '',
                ),
              ),
              Expanded(
                child: _buildIconRow(
                  icon: AppAssets.clock,
                  text:
                      '${(booking.startTime ?? '').localeFormatTime()} ${'to'.translate(context: context)} ${(booking.endTime ?? '').localeFormatTime()}',
                ),
              ),
            ],
          ),
          const CustomSizedBox(height: 16),
          _buildIconRow(
            icon: AppAssets.mapPinArea,
            text: booking.address ?? '',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    color: context.colors.surfacePrimary,
    borderRadius: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMonthNavRow(),
        const CustomSizedBox(height: 16),
        Divider(height: 1, color: context.colors.borderDefault),
        const CustomSizedBox(height: 12),
        _buildWeekdayHeaderRow(),
        const CustomSizedBox(height: 12),
        for (final week in _buildWeeks()) ...[
          Row(spacing: 8, children: week.map(_buildDayCell).toList()),
          const CustomSizedBox(height: 12),
        ],
      ],
    ),
  );

  bool get _canGoPrevMonth {
    final DateTime prevMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
    );
    return !prevMonth.isBefore(DateTime(_minDate.year, _minDate.month));
  }

  bool get _canGoNextMonth {
    final DateTime nextMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
    );
    return !nextMonth.isAfter(DateTime(_maxDate.year, _maxDate.month));
  }

  Widget _buildMonthNavChip({
    required final String label,
    required final IconData icon,
    required final bool enabled,
    required final VoidCallback onTap,
    required final bool iconFirst,
  }) => Opacity(
    opacity: enabled ? 1 : 0.4,
    child: CustomInkWellContainer(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
      child: CustomContainer(
        padding: const EdgeInsets.all(8),
        border: Border.all(color: context.colors.borderDefault),
        borderRadius: UiUtils.borderRadiusOf8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (iconFirst)
              Icon(icon, size: 16, color: context.colors.textPrimary),
            CustomText(label, fontSize: 12, color: context.colors.textPrimary),
            if (!iconFirst)
              Icon(icon, size: 16, color: context.colors.textPrimary),
          ],
        ),
      ),
    ),
  );

  Widget _buildMonthNavRow() {
    final DateTime prevMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
    );
    final DateTime nextMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
    );
    return Row(
      children: [
        _buildMonthNavChip(
          label: DateFormat('MMM').format(prevMonth),
          icon: Icons.chevron_left,
          iconFirst: true,
          enabled: _canGoPrevMonth,
          onTap: () => setState(() => _displayedMonth = prevMonth),
        ),
        Expanded(
          child: CustomText(
            DateFormat('MMM yyyy').format(_displayedMonth),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
            textAlign: TextAlign.center,
          ),
        ),
        _buildMonthNavChip(
          label: DateFormat('MMM').format(nextMonth),
          icon: Icons.chevron_right,
          iconFirst: false,
          enabled: _canGoNextMonth,
          onTap: () => setState(() => _displayedMonth = nextMonth),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaderRow() => Row(
    spacing: 8,
    children: _weekdayKeys
        .map(
          (final key) => Expanded(
            child: Center(
              child: CustomText(
                key.translate(context: context).substring(0, 3),
                fontSize: 12,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        )
        .toList(),
  );

  List<List<DateTime>> _buildWeeks() {
    final DateTime firstOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final int leadingOffset = firstOfMonth.weekday % 7;
    final DateTime firstCell = firstOfMonth.subtract(
      Duration(days: leadingOffset),
    );
    final int daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final int totalCells = leadingOffset + daysInMonth;
    final int weekCount = (totalCells / 7).ceil();
    return List.generate(
      weekCount,
      (final week) => List.generate(
        7,
        (final day) => firstCell.add(Duration(days: week * 7 + day)),
      ),
    );
  }

  Widget _buildDayCell(final DateTime cell) {
    final bool isCurrentMonth = cell.month == _displayedMonth.month;
    final DateTime lastOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );
    if (!isCurrentMonth && cell.isAfter(lastOfMonth)) {
      return const Expanded(child: SizedBox.shrink());
    }

    final bool inRange = !cell.isBefore(_minDate) && !cell.isAfter(_maxDate);
    final bool isSelectable = isCurrentMonth && inRange;
    final bool isSelected = isSelectable && _isSameDay(cell, selectedDate);

    final Color background = isSelected
        ? context.colors.backgroundBrandSubtle
        : isSelectable
        ? context.colors.backgroundSecondary
        : Colors.transparent;
    final Color textColor = isSelected
        ? context.colors.textBrand
        : isSelectable
        ? context.colors.textSecondary
        : context.colors.textTertiary;
    final Border? border = isSelected
        ? Border.all(color: context.colors.borderBrand)
        : !isSelectable
        ? Border.all(color: context.colors.borderDefault)
        : null;

    return Expanded(
      child: CustomInkWellContainer(
        onTap: isSelectable ? () => _selectDate(cell) : null,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
        child: CustomContainer(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: background,
          border: border,
          borderRadius: UiUtils.borderRadiusOf8,
          alignment: Alignment.center,
          child: CustomText(
            '${cell.day}',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotChip({
    required final String title,
    required final bool isAvailable,
    required final bool isSelected,
    required final VoidCallback? onTap,
  }) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
    onTap: onTap,
    child: CustomContainer(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: !isAvailable
          ? context.colors.backgroundBrandDisabled
          : isSelected
          ? context.colors.backgroundBrandSubtle
          : context.colors.backgroundSecondary,
      border: isSelected ? Border.all(color: context.colors.borderBrand) : null,
      borderRadius: UiUtils.borderRadiusOf8,
      child: Center(
        child: CustomText(
          title,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: !isAvailable
              ? context.colors.textSecondary
              : isSelected
              ? context.colors.textBrand
              : context.colors.textPrimary,
        ),
      ),
    ),
  );

  Widget _buildTimeSection() => BlocConsumer<TimeSlotCubit, TimeSlotState>(
    listener: (final context, final state) {
      if (state is TimeSlotFetchSuccess && state.isError) {
        UiUtils.showMessage(context, state.message, ToastificationType.warning);
      }
    },
    builder: (final context, final state) {
      if (state is TimeSlotFetchSuccess) {
        if (state.isError ||
            (state.slotsData.isEmpty && state.message.isNotEmpty)) {
          return Center(child: CustomText(state.message));
        }
        return CustomContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: context.colors.surfacePrimary,
          borderRadius: 12,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              // Tablet shows the time card beside the calendar (half width),
              // so it keeps the same 4 columns as phone.
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: state.slotsData.length,
            itemBuilder: (final context, final index) {
              final AllSlots slot = state.slotsData[index];
              final bool isAvailable = slot.isAvailable != 0;
              final bool isSelected =
                  slot.time != null && slot.time == selectedTime;
              return _buildTimeSlotChip(
                title: (slot.time ?? '').localeFormatTime(),
                isAvailable: isAvailable,
                isSelected: isSelected,
                onTap: !isAvailable
                    ? null
                    : () {
                        ClarityService.logAction(
                          ClarityActions.timeslotSlotSelected,
                          {
                            'provider_id': _providerId,
                            'selected_date': selectedDate,
                            'slot_time': slot.time ?? '',
                            'custom_job_request_id': _customJobRequestId ?? '',
                          },
                        );
                        setState(() {
                          selectedTime = slot.time;
                          message = slot.message;
                        });
                      },
              );
            },
          ),
        );
      }
      if (state is TimeSlotFetchFailure) {
        return ErrorContainer(
          onTapRetry: fetchTimeSlots,
          errorMessage: state.errorMessage.translate(context: context),
        );
      }
      return Center(
        child: CustomCircularProgressIndicator(color: context.colors.iconBrand),
      );
    },
  );

  Widget _buildInfoTile({
    required final String icon,
    required final String label,
    required final String value,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomContainer(
        padding: const EdgeInsets.all(9),
        color: context.colors.backgroundSecondary,
        borderRadius: UiUtils.borderRadiusOf50,
        child: CustomSvgPicture(
          svgImage: icon,
          height: 20,
          width: 20,
          color: context.colors.iconPrimary,
          avoideResponsive: true,
        ),
      ),
      const CustomSizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              label,
              fontSize: 12,
              color: context.colors.textSecondary,
            ),
            const CustomSizedBox(height: 4),
            CustomText(
              value,
              fontSize: 14,
              maxLines: 1,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildBottomBar() => ClipShadowBottom(
    child: CustomContainer(
      color: context.colors.surfacePrimary,
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          offset: const Offset(0, 2),
          color: context.colors.overlayFooterShadow,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: AppAssets.calendar,
                  label: 'selectedDate'.translate(context: context),
                  value: selectedDate.toString().formatDate(),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: context.colors.borderBlack,
              ),
              Expanded(
                child: _buildInfoTile(
                  icon: AppAssets.clock,
                  label: 'selectedTime'.translate(context: context),
                  value: selectedTime != null
                      ? selectedTime.toString().localeFormatTime()
                      : '-',
                ),
              ),
            ],
          ),
          if (message != null && message!.isNotEmpty) ...[
            const CustomSizedBox(height: 8),
            CustomText(
              'orderWillBeScheduledForTheMultipleDays'.translate(
                context: context,
              ),
              fontSize: 11,
              color: context.colors.textBrand,
            ),
          ],
          const CustomSizedBox(height: 16),
          _buildRescheduleButton(),
        ],
      ),
    ),
  );

  Widget _buildRescheduleButton() =>
      BlocConsumer<ValidateCustomTimeCubit, ValidateCustomTimeState>(
        listener: (final context, final state) {
          if (state is ValidateCustomTimeSuccess) {
            if (!state.error) {
              Navigator.of(context).pop({
                "selectedDate": DateFormat('yyyy-MM-dd').format(selectedDate),
                "selectedTime": selectedTime,
                "message": message,
                "isSaved": true,
              });
            } else {
              UiUtils.showMessage(
                context,
                state.message,
                ToastificationType.error,
              );
            }
          } else if (state is ValidateCustomTimeFailure) {
            UiUtils.showMessage(
              context,
              state.errorMessage,
              ToastificationType.error,
            );
          }
        },
        builder: (final context, final state) {
          final bool isLoading = state is ValidateCustomTimeInProgress;
          return CustomInkWellContainer(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
            onTap: isLoading ? null : _onRescheduleTap,
            child: CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: context.colors.backgroundBrand,
              borderRadius: UiUtils.borderRadiusOf12,
              child: Center(
                child: isLoading
                    ? CustomCircularProgressIndicator(
                        color: context.colors.textInverseLight,
                      )
                    : CustomText(
                        'reschedule'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textInverseLight,
                      ),
              ),
            ),
          );
        },
      );

  void _onRescheduleTap() {
    if (selectedTime == null) {
      ClarityService.logAction(ClarityActions.timeslotValidationFailed, {
        'provider_id': _providerId,
        'selected_date': selectedDate,
        'reason': 'time_not_selected',
        'custom_job_request_id': _customJobRequestId ?? '',
      });
      UiUtils.showMessage(
        context,
        'pleaseSelectTime'.translate(context: context),
        ToastificationType.warning,
      );
      return;
    }
    context.read<ValidateCustomTimeCubit>().validateCustomTime(
      providerId: _providerId,
      selectedDate: DateFormat('yyyy-MM-dd').format(selectedDate),
      selectedTime: selectedTime.toString(),
      orderId: widget.bookingDetails.id.toString(),
      customJobRequestId: _customJobRequestId,
    );
  }
}
