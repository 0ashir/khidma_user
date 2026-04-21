import 'package:fixit_user/utils/custom_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../config.dart';

class DateTimePicker extends StatefulWidget {
  final bool? isWeek;
  final bool? isService, isEdit;
  final int? selectProviderIndex;
  final Services? service;

  const DateTimePicker(
      {super.key,
      this.isWeek = false,
      this.isService = false,
      this.selectProviderIndex,
      this.isEdit = false,
      this.service});

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker>
    with SingleTickerProviderStateMixin {
  DateTime dateTime = DateTime.now();
  ScrollController hourController = ScrollController();
  ScrollController minuteController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SlotBookingProvider, ServiceSelectProvider>(
        builder: (context1, dateTimePvr, serviceSelectCtrl, child) {
      return StatefulWrapper(
          onInit: () => Future.delayed(DurationClass.ms150).then((value) {
                widget.isService!
                    ? dateTimePvr.onInit(
                        context,
                        /*isEdit: widget.isEdit*/
                        isPackage: widget.isService,
                        index: widget.selectProviderIndex,
                        service: widget.service, /*sync: this*/
                      )
                    : dateTimePvr.onInit(
                        context,
                        /*  isEdit: widget.isEdit,*/
                        service: widget.service, /*sync: this*/
                      );
              }),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      alignment: Alignment.bottomCenter,
                      decoration: ShapeDecoration(
                          color: appColor(context).whiteBg,
                          shape: const SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.only(
                                  topLeft: SmoothRadius(
                                      cornerRadius: 10, cornerSmoothing: 1),
                                  topRight: SmoothRadius(
                                      cornerRadius: 10, cornerSmoothing: 1)))),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                              child: Column(children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      language(context,
                                          translations!.selectDateTime),
                                      style: appCss.dmDenseBold18.textColor(
                                          appColor(context).darkText)),
                                  const Icon(CupertinoIcons.multiply)
                                      .inkWell(onTap: () => route.pop(context))
                                ]).paddingSymmetric(
                                horizontal: Insets.i20, vertical: Insets.i20),
                            (dateTimePvr.scrollHourIndex >= 0 &&
                                    dateTimePvr.scrollMinIndex >= 0 &&
                                    dateTimePvr.scrollDayIndex >= 0)
                                ? Text(
                                    "${DateFormat('dd MMM yyyy').format(dateTimePvr.focusedDay.value)}, "
                                    "${appArray.hourList[dateTimePvr.scrollHourIndex]}:"
                                    "${appArray.minList[dateTimePvr.scrollMinIndex]} "
                                    "${appArray.amPmList[dateTimePvr.scrollDayIndex]}",
                                    style: appCss.dmDenseMedium18
                                        .textColor(appColor(context).primary),
                                  )
                                    .padding(
                                        horizontal: Insets.i20,
                                        bottom: Insets.i15,
                                        top: Insets.i10)
                                    .alignment(Alignment.centerLeft)
                                : const SizedBox
                                    .shrink(), // or loading, default, etc.

                            /*  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonArrow(
                                      arrow: eSvgAssets.arrowLeft,
                                      onTap: () => dateTimePvr.onLeftArrow()),
                                  const HSpace(Sizes.s20),
                                  Container(
                                      height: Sizes.s34,
                                      alignment: Alignment.center,
                                      width: Sizes.s100,
                                      child: DropdownButton(
                                          underline: Container(),
                                          focusColor: Colors.white,
                                          value: dateTimePvr.chosenValue,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          iconEnabledColor: Colors.black,
                                          items: appArray.monthList
                                              .map<DropdownMenuItem>(
                                                  (monthValue) {
                                            return DropdownMenuItem(
                                                value: monthValue,
                                                child: Text(monthValue['title'],
                                                    style: appCss.dmDenseLight14
                                                        .textColor(
                                                            appColor(context)
                                                                .darkText)));
                                          }).toList(),
                                          icon: SvgPicture.asset(
                                            eSvgAssets.dropDown,
                                            colorFilter: ColorFilter.mode(
                                                appColor(context).darkText,
                                                BlendMode.srcIn),
                                          ),
                                          onChanged: (choseVal) =>
                                              dateTimePvr.onDropDownChange(
                                                  choseVal,
                                                  context))).boxShapeExtension(
                                      color: appColor(context).fieldCardBg,
                                      radius: AppRadius.r4),
                                  const HSpace(Sizes.s20),
                                  Container(
                                          alignment: Alignment.center,
                                          height: Sizes.s34,
                                          width: Sizes.s87,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                    "${dateTimePvr.selectedYear.year}",
                                                    style: appCss.dmDenseLight14
                                                        .textColor(
                                                            appColor(context)
                                                                .darkText)),
                                                SvgPicture.asset(
                                                    eSvgAssets.dropDown,
                                                    colorFilter: ColorFilter.mode(
                                                        appColor(context)
                                                            .darkText,
                                                        BlendMode.srcIn))
                                              ]))
                                      .boxShapeExtension(
                                          color: appColor(context).fieldCardBg,
                                          radius: AppRadius.r4)
                                      .inkWell(
                                          onTap: () =>
                                              dateTimePvr.selectYear(context)),
                                  const HSpace(Sizes.s20),
                                  CommonArrow(
                                      arrow: eSvgAssets.arrowRight,
                                      onTap: () => dateTimePvr.onRightArrow()),
                                ]).paddingSymmetric(horizontal: Insets.i10),*/
                            const VSpace(Sizes.s15),
                            TableCalendar(
                                    currentDay: dateTimePvr.focusedDay.value,
                                    lastDay: DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month + 1,
                                      DateTime.now().day,
                                    ),
                                    /*    lastDay: DateTime.utc(
                                    DateTime.now().year + 100, 3, 14),*/
                                    firstDay: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day),
                                    focusedDay: dateTimePvr.focusedDay.value,
                                    headerVisible: false,
                                    availableGestures:
                                        AvailableGestures.horizontalSwipe,
                                    calendarFormat: dateTimePvr.calendarFormat,
                                    // onDaySelected: value.onDaySelected,
                                    rowHeight: 55,
                                    onPageChanged: (dayFocused) =>
                                        dateTimePvr.onPageCtrl(dayFocused),
                                    onCalendarCreated: (controller) => dateTimePvr
                                        .onCalendarCreate(controller),
                                    selectedDayPredicate: (day) {
                                      // Use `selectedDayPredicate` to determine which day is currently selected.
                                      // If this returns true, then `day` will be marked as selected.

                                      // Using `isSameDay` is recommended to disregard
                                      // the time-part of compared DateTime objects.
                                      return isSameDay(
                                          dateTimePvr.selectedDay, day);
                                    },
                                    daysOfWeekVisible: true,
                                    pageJumpingEnabled: true,
                                    pageAnimationEnabled: false,
                                    onDaySelected: (selectedDay, focusedDay) =>
                                        dateTimePvr.onDaySelected(
                                            selectedDay, focusedDay, context),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                        dowTextFormatter: (date, locale) =>
                                            DateFormat.E(locale)
                                                .format(date)[0],
                                        weekdayStyle: TextStyle(
                                            color: appColor(context).darkText,
                                            fontWeight: FontWeight.bold),
                                        weekendStyle:
                                            TextStyle(color: appColor(context).darkText, fontWeight: FontWeight.bold)),
                                    calendarBuilders: CalendarBuilders(
                                      defaultBuilder:
                                          (context, day, focusedDay) => Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            height: Sizes.s30,
                                            width: Sizes.s30,
                                            decoration: BoxDecoration(
                                                color: appColor(context)
                                                    .whiteColor,
                                                shape: BoxShape.circle),
                                            child: Text(
                                              day.day.toString(),
                                              style: appCss.dmDenseMedium14
                                                  .textColor(appColor(context)
                                                      .lightText),
                                            ),
                                          ),
                                          const VSpace(Sizes.s5),
                                          Container(
                                              alignment: Alignment.center,
                                              height: Sizes.s5,
                                              width: Sizes.s5,
                                              decoration: BoxDecoration(
                                                  color:
                                                      appColor(context).trans,
                                                  shape: BoxShape.circle)),
                                        ],
                                      ),
                                      todayBuilder:
                                          (context, day, focusedDay) => Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            height: Sizes.s30,
                                            width: Sizes.s30,
                                            decoration: BoxDecoration(
                                                color:
                                                    appColor(context).primary,
                                                shape: BoxShape.circle),
                                            child: Text(
                                              day.day.toString(),
                                              style: appCss.dmDenseMedium14
                                                  .textColor(appColor(context)
                                                      .whiteBg),
                                            ),
                                          ),
                                          const VSpace(Sizes.s5),
                                          Container(
                                              alignment: Alignment.center,
                                              height: Sizes.s5,
                                              width: Sizes.s5,
                                              decoration: BoxDecoration(
                                                  color:
                                                      appColor(context).primary,
                                                  shape: BoxShape.circle)),
                                        ],
                                      ),
                                    ),
                                    calendarStyle: CalendarStyle(markerSize: 10, markerDecoration: BoxDecoration(color: appColor(context).primary, shape: BoxShape.circle), selectedDecoration: BoxDecoration(color: appColor(context).primary, shape: BoxShape.circle), todayTextStyle: appCss.dmDenseMedium14.textColor(appColor(context).primary), todayDecoration: BoxDecoration(color: appColor(context).primary.withOpacity(.10), shape: BoxShape.circle)))
                                .paddingAll(Insets.i20)
                                .boxShapeExtension(color: appColor(context).fieldCardBg),
                            /* TableCalendar(
                                    rowHeight: 50,
                                    headerVisible: false,
                                    daysOfWeekVisible: true,
                                    pageJumpingEnabled: true,
                                    pageAnimationEnabled: false,
                                    lastDay: DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month + 1,
                                      DateTime.now().day,
                                    ),
                                    firstDay: DateTime.utc(DateTime.now().year,
                                        DateTime.now().month, DateTime.now().day),
                                    onDaySelected: (selectedDay, focusedDay) =>
                                        dateTimePvr.onDaySelected(
                                            selectedDay, focusedDay, context),
                                    focusedDay: dateTimePvr.focusedDay.value,
                                    availableGestures: AvailableGestures.none,
                                    calendarFormat: widget.isWeek == true
                                        ? dateTimePvr.calendarFormat
                                        : dateTimePvr.calendarFormatMonth,
                                    startingDayOfWeek: StartingDayOfWeek.monday,
                                    headerStyle: const HeaderStyle(
                                        leftChevronVisible: false,
                                        formatButtonVisible: false,
                                        rightChevronVisible: false),
                                    onPageChanged: (dayFocused) =>
                                        dateTimePvr.onPageCtrl(dayFocused),
                                    onCalendarCreated: (controller) =>
                                        dateTimePvr.onCalendarCreate(controller),
                                    selectedDayPredicate: (day) {
                                      return isSameDay(
                                          dateTimePvr.focusedDay.value, day);
                                    },
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                        dowTextFormatter: (date, locale) =>
                                            DateFormat.E(locale).format(date)[0],
                                        weekdayStyle: appCss.dmDenseBold14
                                            .textColor(appColor(context).primary),
                                        weekendStyle: appCss.dmDenseBold14
                                            .textColor(appColor(context).primary)),
                                    calendarStyle: CalendarStyle(defaultTextStyle: appCss.dmDenseLight14.textColor(appColor(context).darkText), weekendTextStyle: appCss.dmDenseLight14.textColor(appColor(context).darkText), disabledTextStyle: appCss.dmDenseLight14.textColor(appColor(context).lightText), todayTextStyle: appCss.dmDenseMedium14.textColor(appColor(context).primary), todayDecoration: BoxDecoration(color: appColor(context).primary.withOpacity(.10), shape: BoxShape.circle)))
                                .paddingAll(Insets.i20)
                                .boxShapeExtension(color: appColor(context).fieldCardBg)
                                .paddingSymmetric(horizontal: Insets.i10),*/
                            Text(language(context, translations!.time),
                                    style: appCss.dmDenseBold14
                                        .textColor(appColor(context).darkText))
                                .paddingOnly(
                                    top: Insets.i25,
                                    bottom: Insets.i10,
                                    left: Insets.i20)
                                .alignment(Alignment.centerLeft),
                            Stack(alignment: Alignment.center, children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomTimePicker(
                                        title: language(
                                            context, translations!.hour),
                                        itemList: appArray.hourList,
                                        carouselController:
                                            dateTimePvr.carouselController,
                                        onScroll: (index) =>
                                            dateTimePvr.onHourScroll(index))
                                    /* .inkWell(
                                            onTap: () =>
                                                dateTimePvr.onHourTap(context))*/
                                    ,
                                    const HSpace(Sizes.s10),
                                    SvgPicture.asset(eSvgAssets.colonIcon),
                                    const HSpace(Sizes.s10),
                                    CustomTimePicker(
                                        title: language(
                                            context, translations!.minute),
                                        itemList: appArray.minList,
                                        onScroll: (index) =>
                                            dateTimePvr.onMinScroll(index),
                                        carouselController:
                                            dateTimePvr.carouselController1)
                                    /* .inkWell(
                                            onTap: () =>
                                                dateTimePvr.onHourTap(context))*/
                                    ,
                                    const HSpace(Sizes.s20),
                                    CustomTimePicker(
                                        title: language(
                                            context, translations!.day),
                                        onScroll: (index) => dateTimePvr
                                            .onAmPmChange(context, index),
                                        carouselController:
                                            dateTimePvr.carouselController2,
                                        itemList: appArray.amPmList)
                                    /*  .inkWell(
                                            onTap: () =>
                                                dateTimePvr.onHourTap(context))*/
                                  ])
                            ]),
                            ButtonCommon(
                                isLoading: dateTimePvr.isLoading,
                                title: translations!.addDateTime!,
                                onTap: () =>
                                    dateTimePvr.checkSlotAvailableForAppChoose(
                                        context: context,
                                        isService: widget.isService!,
                                        isEdit: widget.isEdit!)).paddingOnly(
                                top: Insets.i30,
                                bottom: Insets.i20,
                                left: Insets.i20,
                                right: Insets.i20)
                          ])),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: dateTimePvr.isVisible ? 1.0 : 0.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Insets.i50,
                                    horizontal: Insets.i30),
                                child: Container(
                                  decoration: ShapeDecoration(
                                      color: appColor(context).primary,
                                      shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                              cornerRadius: 10,
                                              cornerSmoothing: 1))),
                                  child: Text(
                                    translations!.youCantSelect!,
                                    style: appCss.dmDenseMedium16.textColor(
                                        appColor(context).whiteColor),
                                  )
                                      .paddingAll(Insets.i10)
                                      .decorated(color: appColor(context).red),
                                ),
                              ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            ),
          ));
    });
  }
}
