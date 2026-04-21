import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../config.dart';

class CustomDateBottomSheet extends StatelessWidget {
  const CustomDateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Consumer<SlotBookingProvider>(builder: (context1, value, child) {
        // Get max booking days from app settings
        int maxBookingDays = 365;
        if (appSettingModel?.defaultCreationLimits?.maxBookingDays != null) {
          maxBookingDays = int.tryParse(
                  appSettingModel!.defaultCreationLimits!.maxBookingDays!) ??
              365;
        }

        final DateTime maxBookingDate =
            DateTime.now().add(Duration(days: maxBookingDays));
        final DateTime today = DateTime.now();

        // Ensure focusedDay is within valid range
        DateTime validFocusedDay = value.focusedDay.value;
        if (validFocusedDay.isBefore(today)) {
          validFocusedDay = today;
        } else if (validFocusedDay.isAfter(maxBookingDate)) {
          validFocusedDay = maxBookingDate;
        }

        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Stack(children: [
                  ListView(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language(context, translations!.selectDateOnly),
                              style: appCss.dmDenseMedium18
                                  .textColor(appColor(context).darkText)),
                          const Icon(CupertinoIcons.multiply)
                              .inkWell(onTap: () => route.pop(context))
                        ]).paddingSymmetric(horizontal: Insets.i20),
                    const VSpace(Sizes.s15),

                    // Calendar for multiple date selection
                    TableCalendar(
                      rowHeight: 55,
                      headerVisible: true,
                      daysOfWeekVisible: true,
                      focusedDay: validFocusedDay,
                      firstDay: today,
                      lastDay: maxBookingDate,
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) {
                        return value.customSelectedDates.any((selectedDate) =>
                            selectedDate.year == day.year &&
                            selectedDate.month == day.month &&
                            selectedDate.day == day.day);
                      },
                      enabledDayPredicate: (day) {
                        final todayStart =
                            DateTime(today.year, today.month, today.day);
                        final dayStart = DateTime(day.year, day.month, day.day);
                        final maxDate = DateTime(maxBookingDate.year,
                            maxBookingDate.month, maxBookingDate.day);

                        return (dayStart.isAtSameMomentAs(todayStart) ||
                                dayStart.isAfter(todayStart)) &&
                            (dayStart.isBefore(maxDate) ||
                                dayStart.isAtSameMomentAs(maxDate));
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        value.onCustomDateToggle(selectedDay);
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: appCss.dmDenseMedium16
                            .textColor(appColor(context).darkText),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        dowTextFormatter: (date, locale) =>
                            DateFormat.E(locale).format(date)[0],
                        weekdayStyle: appCss.dmDenseBold14
                            .textColor(appColor(context).primary),
                        weekendStyle: appCss.dmDenseBold14
                            .textColor(appColor(context).primary),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: appColor(context).primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: appCss.dmDenseMedium14
                            .textColor(appColor(context).whiteColor),
                        todayDecoration: BoxDecoration(
                          color: appColor(context).primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: appCss.dmDenseMedium14
                            .textColor(appColor(context).darkText),
                        defaultTextStyle: appCss.dmDenseLight14
                            .textColor(appColor(context).darkText),
                        weekendTextStyle: appCss.dmDenseLight14
                            .textColor(appColor(context).darkText),
                        disabledTextStyle: appCss.dmDenseLight14
                            .textColor(appColor(context).lightText),
                      ),
                    ).paddingAll(Insets.i20),

                    const VSpace(Sizes.s15),

                    // Show selected dates count
                    if (value.customSelectedDates.isNotEmpty)
                      Text(
                        '${value.customSelectedDates.length} ${language(context, translations!.selectDateOnly ?? "dates selected")}',
                        style: appCss.dmDenseMedium14
                            .textColor(appColor(context).primary),
                        textAlign: TextAlign.center,
                      ).paddingSymmetric(horizontal: Insets.i20),

                    const VSpace(Sizes.s80),
                  ]).paddingSymmetric(vertical: Insets.i20),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: BottomSheetButtonCommon(
                              textOne: translations!.clearAll,
                              textTwo: translations!.apply,
                              applyTap: () {
                                route.pop(context);
                              },
                              clearTap: () {
                                value.clearCustomDates();
                              })
                          .padding(horizontal: Sizes.s20, bottom: Sizes.s20)
                          .backgroundColor(appColor(context).whiteBg))
                ]).bottomSheetExtension(context);
              }),
        );
      });
    });
  }
}
