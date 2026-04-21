import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../config.dart';

class CustomTableDateRange extends StatelessWidget {
  final bool isOffer;
  const CustomTableDateRange({super.key, this.isOffer = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SlotBookingProvider>(builder: (context1, value, child) {
      // Get max booking days from app settings
      int maxBookingDays = 365; // Default fallback
      if (appSettingModel?.defaultCreationLimits?.maxBookingDays != null) {
        maxBookingDays = int.tryParse(appSettingModel!.defaultCreationLimits!.maxBookingDays!) ?? 365;
      }
      
      // Calculate the last allowed booking date
      final DateTime maxBookingDate = DateTime.now().add(Duration(days: maxBookingDays));
      final DateTime today = DateTime.now();
      
      // Ensure focusedDay is within valid range
      DateTime validFocusedDay = value.focusedDay.value;
      if (validFocusedDay.isBefore(today)) {
        validFocusedDay = today;
      } else if (validFocusedDay.isAfter(maxBookingDate)) {
        validFocusedDay = maxBookingDate;
      }
      
      return TableCalendar(
              rowHeight: 55,
              headerVisible: false,
              daysOfWeekVisible: true,
              pageJumpingEnabled: true,
              pageAnimationEnabled: false,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              lastDay: maxBookingDate,
              firstDay: today,
              enabledDayPredicate: (day) {
                // Enable dates from today up to maxBookingDays in the future
                final todayStart = DateTime(today.year, today.month, today.day);
                final dayStart = DateTime(day.year, day.month, day.day);
                final maxDate = DateTime(maxBookingDate.year, maxBookingDate.month, maxBookingDate.day);
                
                return (dayStart.isAtSameMomentAs(todayStart) || dayStart.isAfter(todayStart)) &&
                       (dayStart.isBefore(maxDate) || dayStart.isAtSameMomentAs(maxDate));
              },
              onDaySelected: value.onDaySelect,
              focusedDay: validFocusedDay,
              rangeStartDay: value.rangeStart,
              rangeEndDay: value.rangeEnd,
              availableGestures: AvailableGestures.none,
              calendarFormat: value.calendarFormatMonth,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onRangeSelected: (start, end, focusedDay) =>
                  value.onRangeSelect(start, end, focusedDay),
              headerStyle: const HeaderStyle(
                  leftChevronVisible: false,
                  formatButtonVisible: false,
                  rightChevronVisible: false),
              onPageChanged: (dayFocused) => value.onPageCtrl(dayFocused),
              onCalendarCreated: (controller) =>
                  value.onCalendarCreate(controller),
              selectedDayPredicate: (day) {
                return isSameDay(value.focusedDay.value, day);
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) =>
                      DateFormat.E(locale).format(date)[0],
                  weekdayStyle:
                      appCss.dmDenseBold14.textColor(appColor(context).primary),
                  weekendStyle: appCss.dmDenseBold14
                      .textColor(appColor(context).primary)),
              calendarStyle: CalendarStyle(
                  rangeHighlightColor:
                      appColor(context).primary.withOpacity(0.10),
                  rangeEndDecoration: BoxDecoration(
                      color: appColor(context).primary, shape: BoxShape.circle),
                  defaultTextStyle: appCss.dmDenseLight14
                      .textColor(appColor(context).darkText),
                  withinRangeTextStyle: appCss.dmDenseLight14
                      .textColor(appColor(context).primary),
                  rangeStartTextStyle: appCss.dmDenseLight14
                      .textColor(appColor(context).whiteColor),
                  rangeEndTextStyle:
                      appCss.dmDenseLight14.textColor(appColor(context).whiteColor),
                  rangeStartDecoration: BoxDecoration(color: appColor(context).primary, shape: BoxShape.circle),
                  todayTextStyle: appCss.dmDenseMedium14.textColor(appColor(context).primary),
                  todayDecoration: BoxDecoration(color: appColor(context).primary.withOpacity(.10), shape: BoxShape.circle)))
          .paddingAll(Insets.i20)
          .boxShapeExtension(color: appColor(context).fieldCardBg)
          .paddingSymmetric(horizontal: Insets.i20);
    });
  }
}
