import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalenderBottomSheet extends StatefulWidget {
  const CalenderBottomSheet({
    required this.providerId,
    required this.advanceBookingDays,
    final Key? key,
    this.selectedDate,
    this.selectedTime,
    this.orderId,
    this.customJobRequestId,
  }) : super(key: key);

  final String providerId;
  final String advanceBookingDays;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? orderId;
  final String? customJobRequestId;

  @override
  State<CalenderBottomSheet> createState() => _CalenderBottomSheetState();
}

class _CalenderBottomSheetState extends State<CalenderBottomSheet>
    with TickerProviderStateMixin {
  late DateTime selectedDate;
  String? selectedTime;
  String? message;
  final TextEditingController _customTimeController = TextEditingController();
  final FocusNode _customTimeFocusNode = FocusNode();
  String? _customTimeError;
  static final RegExp _customTimePattern = RegExp(
    r'^(0?[1-9]|1[0-2]):[0-5][0-9] (AM|PM)$',
  );
  List<String> listOfDay = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ];

  bool get _isTablet => ResponsiveHelper.isTabletDevice(context);

  void fetchTimeSlots() {
    context.read<TimeSlotCubit>().getTimeslotDetails(
      providerID: int.parse(widget.providerId),
      selectedDate: selectedDate,
      customJobRequestId: widget.customJobRequestId ?? '',
    );
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now();
    selectedTime = widget.selectedTime;
    if ((selectedTime ?? '').isNotEmpty) {
      _customTimeController.text = selectedTime!.formatTime();
    }
    _customTimeFocusNode.addListener(_onCustomTimeFocusChanged);
    ClarityService.logAction(ClarityActions.timeslotPickerOpened, {
      'provider_id': widget.providerId,
      'selected_date': selectedDate,
      'custom_job_request_id': widget.customJobRequestId ?? '',
    });

    Future.delayed(Duration.zero).then((final value) {
      fetchTimeSlots();
    });
  }

  void _onCustomTimeFocusChanged() {
    if (_customTimeFocusNode.hasFocus) return;
    final String text = _customTimeController.text.trim();
    if (text.isEmpty) {
      setState(() => _customTimeError = null);
      return;
    }
    final String? parsed = _parseCustomTime(text);
    setState(() {
      if (parsed == null) {
        _customTimeError = 'invalidTimeFormat'.translate(context: context);
      } else {
        _customTimeError = null;
        selectedTime = parsed;
        message = null;
      }
    });
  }

  String? _parseCustomTime(final String rawText) {
    final String normalized = rawText.trim().toUpperCase();
    if (!_customTimePattern.hasMatch(normalized)) return null;
    try {
      final DateTime parsed = DateFormat(
        "hh:mm a",
        "en",
      ).parseStrict(normalized);
      return DateFormat("HH:mm:ss").format(parsed);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _customTimeFocusNode.removeListener(_onCustomTimeFocusChanged);
    _customTimeFocusNode.dispose();
    _customTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) {
        return;
      } else {
        Navigator.of(context).pop({
          "selectedDate": DateFormat('yyyy-MM-dd').format(selectedDate),
          "selectedTime": selectedTime,
          "message": message,
          "isSaved": false,
        });
      }
    },
    child: SafeArea(
      top: false,
      child: StatefulBuilder(
        builder: (final BuildContext context, final setStater) =>
            CustomSizedBox(
              height: context.screenHeight * 0.85,
              child: CustomContainer(
                color: context.colors.surfacePrimary,
                borderRadiusStyle: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDateSection(setStater),
                            const CustomSizedBox(height: 16),
                            _buildCustomTimeInput(setStater),
                            const CustomSizedBox(height: 8),
                            _buildTimeSection(setStater),
                            const CustomSizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
      ),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        const CustomSizedBox(height: 8),
        Container(
          width: 40,
          height: 8,
          decoration: BoxDecoration(
            color: context.colors.backgroundTertiary,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const CustomSizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomText(
                'selectTimeSlot'.translate(context: context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const CustomSizedBox(height: 16),
        Divider(height: 1, color: context.colors.borderDefault),
      ],
    ),
  );

  Widget _buildDateChip({
    required final DateTime date,
    required final bool isSelected,
    required final VoidCallback onTap,
  }) {
    final String day = listOfDay[date.weekday - 1].translate(context: context);
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: isSelected
            ? context.colors.backgroundBrandSubtle
            : context.colors.surfacePrimary,
        border: Border.all(
          color: isSelected
              ? context.colors.borderBrand
              : context.colors.borderDefault,
        ),
        borderRadius: UiUtils.borderRadiusOf12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              "${date.day}/${date.month}",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? context.colors.textBrand
                  : context.colors.textPrimary,
            ),
            const CustomSizedBox(height: 4),
            CustomText(
              day.length > 3 ? day.substring(0, 3) : day,
              fontSize: 12,
              color: isSelected
                  ? context.colors.textBrand
                  : context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(final StateSetter setStater) {
    final int daysCount =
        (int.tryParse(widget.advanceBookingDays) != null &&
            (int.tryParse(widget.advanceBookingDays)! > 0))
        ? int.parse(widget.advanceBookingDays)
        : 30;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomText(
              'selectDateForService'.translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
          const CustomSizedBox(height: 8),
          SizedBox(
            // Chip text scales with rf() on tablets, so a fixed 80 overflows.
            height: 80.rf(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: daysCount,
              separatorBuilder: (final context, final index) =>
                  const CustomSizedBox(width: 10),
              itemBuilder: (final context, final index) {
                final DateTime date = DateTime.now().add(Duration(days: index));
                final bool isSelected =
                    DateFormat("yyyy-MM-dd").format(selectedDate) ==
                    DateFormat("yyyy-MM-dd").format(date);
                return _buildDateChip(
                  date: date,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      return;
                    }
                    selectedTime = null;
                    selectedDate = date;
                    _customTimeController.clear();
                    _customTimeError = null;
                    setStater(() {});
                    fetchTimeSlots();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTimeInput(final StateSetter setStater) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: _isTablet
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        CustomTextFormField(
          controller: _customTimeController,
          currentFocusNode: _customTimeFocusNode,
          forceUnFocus: true,
          labelText: 'enterYourPreferredTime',
          hintText: '11:00 AM',
          textInputAction: TextInputAction.done,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomSvgPicture(
              svgImage: AppAssets.clock,
              height: 16,
              width: 16,
              color: context.colors.iconPrimary,
              avoideResponsive: true,
            ),
          ),
          onChanged: (final value) {
            // Commit as soon as the text fully matches, don't wait for blur —
            // tapping Confirm doesn't unfocus this field on its own.
            final String? parsed = _parseCustomTime(value);
            setStater(() {
              if (parsed != null) {
                selectedTime = parsed;
                message = null;
              }
              _customTimeError = null;
            });
          },
          bottomPadding: 0,
        ),
        const CustomSizedBox(height: 4),
        CustomText(
          _customTimeError ??
              'customTimeHelperText'.translate(context: context),
          fontSize: 12,
          textAlign: TextAlign.end,
          color: _customTimeError != null
              ? context.colors.textError
              : context.colors.textTertiary,
        ),
      ],
    ),
  );

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

  Widget _buildTimeSection(final StateSetter setStater) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomText(
          'selectTimeForService'.translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.colors.textPrimary,
        ),
      ),
      const CustomSizedBox(height: 8),
      BlocConsumer<TimeSlotCubit, TimeSlotState>(
        listener: (final context, final state) {
          if (state is TimeSlotFetchSuccess) {
            if (state.isError) {
              UiUtils.showMessage(
                context,
                state.message,
                ToastificationType.warning,
              );
            }
          }
        },
        builder: (final context, final state) {
          if (state is TimeSlotFetchSuccess) {
            if (state.isError ||
                (state.slotsData.isEmpty && state.message.isNotEmpty)) {
              return SizedBox(
                height: 200,
                child: Center(child: CustomText(state.message)),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _isTablet ? 6 : 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
                childAspectRatio: 2.3,
              ),
              itemCount: state.slotsData.length,
              itemBuilder: (final context, final index) {
                final AllSlots slot = state.slotsData[index];
                final bool isAvailable = slot.isAvailable != 0;
                final bool isSelected =
                    slot.time != null && slot.time == selectedTime;
                return _buildTimeSlotChip(
                  title: (slot.time ?? '').formatTime(),
                  isAvailable: isAvailable,
                  isSelected: isSelected,
                  onTap: !isAvailable
                      ? null
                      : () {
                          ClarityService.logAction(
                            ClarityActions.timeslotSlotSelected,
                            {
                              'provider_id': widget.providerId,
                              'selected_date': selectedDate,
                              'slot_time': slot.time ?? '',
                              'custom_job_request_id':
                                  widget.customJobRequestId ?? '',
                            },
                          );
                          selectedTime = slot.time;
                          message = slot.message;
                          _customTimeController.text = (slot.time ?? '')
                              .formatTime();
                          _customTimeError = null;
                          setStater(() {});
                        },
                );
              },
            );
          }
          if (state is TimeSlotFetchFailure) {
            return SizedBox(
              height: 200,
              child: ErrorContainer(
                onTapRetry: () {
                  fetchTimeSlots();
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          return SizedBox(
            height: 200,
            child: Center(
              child: CustomCircularProgressIndicator(
                color: context.colors.iconBrand,
              ),
            ),
          );
        },
      ),
    ],
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
      padding: const EdgeInsets.all(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          offset: const Offset(0, -2),
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
                      ? selectedTime.toString().formatTime()
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
          Row(
            children: [
              Expanded(
                child: CustomInkWellContainer(
                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
                  onTap: () => Navigator.pop(context),
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: context.colors.backgroundBrandSubtle,
                    border: Border.all(color: context.colors.borderBrand),
                    borderRadius: UiUtils.borderRadiusOf12,
                    child: Center(
                      child: CustomText(
                        'close'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textBrand,
                      ),
                    ),
                  ),
                ),
              ),
              const CustomSizedBox(width: 16),
              Expanded(child: _buildConfirmButton()),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildConfirmButton() =>
      BlocConsumer<ValidateCustomTimeCubit, ValidateCustomTimeState>(
        listener:
            (
              final BuildContext context,
              final ValidateCustomTimeState validateCustomTimeState,
            ) {
              if (validateCustomTimeState is ValidateCustomTimeSuccess) {
                if (!validateCustomTimeState.error) {
                  Navigator.of(context).pop({
                    "selectedDate": DateFormat(
                      'yyyy-MM-dd',
                    ).format(selectedDate),
                    "selectedTime": selectedTime,
                    "message": message,
                    "isSaved": true,
                  });
                } else {
                  UiUtils.showMessage(
                    context,
                    validateCustomTimeState.message,
                    ToastificationType.error,
                  );
                }
              } else if (validateCustomTimeState is ValidateCustomTimeFailure) {
                UiUtils.showMessage(
                  context,
                  validateCustomTimeState.errorMessage,
                  ToastificationType.error,
                );
              }
            },
        builder: (final context, final validateCustomTimeState) {
          final bool isLoading =
              validateCustomTimeState is ValidateCustomTimeInProgress;
          return CustomInkWellContainer(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
            onTap: isLoading
                ? null
                : () {
                    // Field may still hold focus (tapping Confirm doesn't
                    // blur it), so selectedTime might not be committed yet.
                    selectedTime ??= _parseCustomTime(
                      _customTimeController.text,
                    );
                    if (selectedTime == null) {
                      ClarityService.logAction(
                        ClarityActions.timeslotValidationFailed,
                        {
                          'provider_id': widget.providerId,
                          'selected_date': selectedDate,
                          'reason': 'time_not_selected',
                          'custom_job_request_id':
                              widget.customJobRequestId ?? '',
                        },
                      );
                      UiUtils.showMessage(
                        context,
                        'pleaseSelectTime'.translate(context: context),
                        ToastificationType.warning,
                      );
                      return;
                    }
                    context.read<ValidateCustomTimeCubit>().validateCustomTime(
                      providerId: widget.providerId,
                      selectedDate: DateFormat(
                        'yyyy-MM-dd',
                      ).format(selectedDate),
                      selectedTime: selectedTime.toString(),
                      orderId: widget.orderId,
                      customJobRequestId: widget.customJobRequestId,
                    );
                  },
            child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: context.colors.backgroundBrand,
              borderRadius: UiUtils.borderRadiusOf12,
              child: Center(
                child: isLoading
                    ? CustomCircularProgressIndicator(
                        color: context.colors.textInverseLight,
                      )
                    : CustomText(
                        'confirm'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textInverseLight,
                      ),
              ),
            ),
          );
        },
      );
}
