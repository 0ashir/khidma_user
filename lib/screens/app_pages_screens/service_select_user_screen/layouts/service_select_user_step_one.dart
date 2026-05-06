import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/add_job_request/layouts/dark_drop_down_layout.dart';
import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/custom_date_selection.dart';
import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/weekday_selection.dart';
import 'package:fixit_user/utils/custom_time_picker.dart';
import 'package:intl/intl.dart';
import '../../../../config.dart';
import '../../services_details_screen/layouts/add_on_service_card.dart';

class ServiceSelectUserStepOne extends StatelessWidget {
  const ServiceSelectUserStepOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ServiceSelectProvider, SlotBookingProvider,
            ServicesDetailsProvider>(
        builder: (context1, value, schedule, service, child) {
      return Consumer<LocationProvider>(builder: (context2, loc, child) {
        log("value.servicesCart::1${jsonEncode(schedule.servicesCart?.type == "scheduled")}");
        log("value.servicesCart::2${jsonEncode(value.servicesCart != null)}");
        log("value.servicesCart::3${jsonEncode(value.servicesCart!.selectedDateTimeFormat = null)}");

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(controller: value.scrollController, children: [
              // Text(
              //         language(context, translations!.selectDateTime)
              //             .toUpperCase(),
              //         style: appCss.dmDenseSemiBold16
              //             .textColor(appColor(context).primary))
              //     .paddingSymmetric(horizontal: Insets.i20),
              const VSpace(Sizes.s15),
              loc.addressList.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(language(context, translations!.location),
                              overflow: TextOverflow.ellipsis,
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).darkText)),
                          const VSpace(Sizes.s5),
                          ButtonCommon(
                              title:
                                  language(context, translations!.addLocation),
                              color: appColor(context).whiteBg,
                              onTap: () => route
                                  .pushNamed(context, routeName.currentLocation)
                                  .then((e) => loc.getLocationList(context)),
                              fontColor: appColor(context).primary,
                              borderColor: appColor(context).primary),
                        ]).marginOnly(
                      bottom: Insets.i10, left: Sizes.s20, right: Sizes.s20)
                  : LocationChangeRowCommon(
                      title: language(
                          context,
                          value.address == null
                              ? translations!.addLocation
                              : translations!.change),
                      onTap: () => route
                              .pushNamed(context, routeName.myLocation,
                                  arg: true)
                              .then((e) {
                            log("EE :$e");
                            if (e != null) {
                              value.onChangeLocation(context, e);
                            }
                          })),
              const VSpace(Sizes.s10),
              if (value.address != null)
                LocationLayout(
                  data: value.address,
                  isPrimaryAnTapLayout: false,
                ),
              if (value.servicesCart?.selectedAdditionalServices != null &&
                  value.servicesCart?.selectedAdditionalServices?.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language(context, translations!.addOns),
                        style: appCss.dmDenseMedium14
                            .textColor(appColor(context).darkText)),
                    const VSpace(Sizes.s10),
                    ...value.servicesCart!.selectedAdditionalServices!
                        .asMap()
                        .entries
                        .map((e) => AddOnServiceCard(
                              deleteTap: () =>
                                  value.deleteJobRequestConfirmation(
                                      context, this, e.key),
                              index: e.key,
                              isDelete: true,
                              additionalServices: e.value,
                              additionalServicesLength: value.servicesCart!
                                      .selectedAdditionalServices!.length -
                                  1,
                            ))
                  ],
                ).padding(horizontal: Insets.i20, bottom: Sizes.s20),
              value.servicesCart != null &&
                      value.servicesCart!.serviceDate != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language(context, translations!.bookedDateTime),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        const VSpace(Sizes.s10),
                        BookedDateTimeLayout(
                            onTap: () {
                              value.servicesCart!.serviceDate = null;
                              value.servicesCart!.selectedDateTimeFormat = null;
                              value.notifyListeners();
                            },
                            date: DateFormat('dd MMMM, yyyy')
                                .format(value.servicesCart!.serviceDate!),
                            time:
                                "${translations!.at} ${DateFormat('hh:mm').format(value.servicesCart!.serviceDate!)} ${value.servicesCart!.selectedDateTimeFormat.toString()}"),
                      ],
                    ).paddingSymmetric(horizontal: Insets.i20)
                  : value.servicesCart.selectServiceManType ==
                              "as_per_my_choice" &&
                          (service.service?.type == "scheduled" ||
                              schedule.servicesCart?.type == "scheduled")
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(translations!.bookingFrequency.toString(),
                                    style: appCss.dmDenseSemiBold16
                                        .textColor(appColor(context).darkText))
                                .paddingSymmetric(
                                    horizontal: Insets.i20,
                                    vertical: Insets.i10),
                            SizedBox(
                                height: 50,
                                child: DarkDropDownLayout(
                                        isBig: true,
                                        val: schedule.bookingFrequency,
                                        hintText: translations!.daily,
                                        isField: true,
                                        isIcon: false,
                                        bookingFrequencyList:
                                            appArray.bookingFrequencyList,
                                        onChanged: (val) => schedule
                                            .onChangeBookingFrequency(val))
                                    .paddingDirectional(horizontal: Sizes.s20)),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: Sizes.s20, vertical: Sizes.s20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Sizes.s12, vertical: Sizes.s12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: appColor(context)
                                      .fieldCardBg, // border color
                                  width: Sizes.s1, // border width
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(translations!.serviceDuration.toString(),
                                          style: appCss.dmDenseSemiBold16
                                              .textColor(
                                                  appColor(context).darkText))
                                      .paddingOnly(bottom: Sizes.s5),
                                  Row(children: [
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          TextFieldCommon(
                                                  isEnable: false,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.r8),
                                                      borderSide: BorderSide(
                                                          color: appColor(context)
                                                              .stroke)),
                                                  focusNode:
                                                      schedule.startDateFocus,
                                                  controller:
                                                      schedule.startDateCtrl,
                                                  style: appCss.dmDenseMedium13
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText),
                                                  validator: (value) => validation
                                                      .dynamicTextValidation(
                                                          context,
                                                          value,
                                                          translations!
                                                              .pleaseSelectStartDate),
                                                  hintText: translations!.startDate!,
                                                  prefixIcon: eSvgAssets.calendar)
                                              .inkWell(onTap: () => schedule.onDateSelect(context, schedule.startDateCtrl.text))
                                        ])),
                                    const HSpace(Sizes.s15),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          TextFieldCommon(
                                                  isEnable: false,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.r8),
                                                      borderSide: BorderSide(
                                                          color: appColor(context)
                                                              .stroke)),
                                                  focusNode:
                                                      schedule.endDateFocus,
                                                  controller:
                                                      schedule.endDateCtrl,
                                                  hintText:
                                                      translations!.endDate!,
                                                  style: appCss.dmDenseMedium13
                                                      .textColor(appColor(context)
                                                          .darkText),
                                                  validator: (value) => validation
                                                      .dynamicTextValidation(
                                                          context,
                                                          value,
                                                          translations!
                                                              .pleaseSelectEndDate),
                                                  prefixIcon: eSvgAssets.calendar)
                                              .inkWell(onTap: () => schedule.onDateSelect(context, schedule.endDateCtrl.text))
                                        ]))
                                  ]),
                                  if (schedule.bookingFrequency == "daily")
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                                translations!.selectDays!
                                                    .toString(),
                                                style: appCss.dmDenseSemiBold16
                                                    .textColor(appColor(context)
                                                        .darkText))
                                            .paddingOnly(
                                                top: Sizes.s10,
                                                bottom: Sizes.s5),
                                        const WeekDaySelectionLayout()
                                      ],
                                    ),
                                  if (schedule.bookingFrequency == "custom")
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                                translations!.selectDateOnly
                                                    .toString(),
                                                style: appCss.dmDenseSemiBold16
                                                    .textColor(appColor(context)
                                                        .darkText))
                                            .paddingOnly(
                                                top: Sizes.s10,
                                                bottom: Sizes.s5),
                                        const CustomDateSelectionLayout()
                                      ],
                                    )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(language(context, translations!.time),
                                        style: appCss.dmDenseBold14.textColor(
                                            appColor(context).darkText))
                                    .paddingOnly(
                                        bottom: Insets.i10, left: Insets.i20)
                                    .alignment(Alignment.centerLeft),
                                Stack(alignment: Alignment.center, children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomTimePicker(
                                            title: language(
                                                context, translations!.hour),
                                            itemList: appArray.hourList,
                                            carouselController:
                                                schedule.carouselController,
                                            onScroll: (index) =>
                                                schedule.onHourScroll(index)),
                                        const HSpace(Sizes.s15),
                                        SvgPicture.asset(eSvgAssets.colonIcon),
                                        const HSpace(Sizes.s15),
                                        CustomTimePicker(
                                            title: language(
                                                context, translations!.minute),
                                            itemList: appArray.minList,
                                            onScroll: (index) =>
                                                schedule.onMinScroll(index),
                                            carouselController:
                                                schedule.carouselController1),
                                        const HSpace(Sizes.s20),
                                        CustomTimePicker(
                                            title: language(
                                                context, translations!.day),
                                            onScroll: (index) => schedule
                                                .onAmPmChange(context, index),
                                            carouselController:
                                                schedule.carouselController2,
                                            itemList: appArray.amPmList)
                                      ])
                                ]),
                              ],
                            ),
                            if (schedule.selectedDateList.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${translations?.scheduledList} (${schedule.selectedDateList.length})",
                                          style: appCss.dmDenseBold14.textColor(
                                              appColor(context).darkText))
                                      .paddingDirectional(vertical: Sizes.s10),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Sizes.s12,
                                          vertical: Sizes.s12),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  appColor(context).fieldCardBg,
                                              width: Sizes.s2),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListView.separated(
                                                separatorBuilder:
                                                    (context, index) => Divider(
                                                        height: 20,
                                                        thickness: 1,
                                                        color: appColor(context)
                                                            .fieldCardBg),
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: schedule
                                                    .selectedDateList.length,
                                                itemBuilder: (context, index) {
                                                  DateTime date = schedule
                                                      .selectedDateList[index];
                                                  String hour = appArray
                                                          .hourList[
                                                      schedule.scrollHourIndex];
                                                  String minute = appArray
                                                          .minList[
                                                      schedule.scrollMinIndex];
                                                  String amPm = appArray
                                                          .amPmList[
                                                      schedule.amIndex ?? 0];
                                                  return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            DateFormat(
                                                                    "dd MMM, yyyy")
                                                                .format(date),
                                                            style: appCss
                                                                .dmDenseMedium13
                                                                .textColor(appColor(
                                                                        context)
                                                                    .darkText)),
                                                        Text(
                                                            "$hour:$minute $amPm",
                                                            style: appCss
                                                                .dmDenseMedium13
                                                                .textColor(appColor(
                                                                        context)
                                                                    .primary))
                                                      ]);
                                                })
                                          ])),
                                ],
                              ).paddingDirectional(horizontal: Sizes.s20)
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language(context, translations!.dateTime),
                                style: appCss.dmDenseMedium14
                                    .textColor(appColor(context).darkText)),
                            Text(
                                language(
                                    context, translations!.thisServiceWill),
                                style: appCss.dmDenseMedium12
                                    .textColor(appColor(context).lightText)),
                            const VSpace(Sizes.s10),
                            Column(children: [
                              TimeSlotLayout(
                                  title: translations!.timeSlot,
                                  onTap: () => value.onTapDate(context))
                            ]).boxShapeExtension(
                                color: appColor(context).fieldCardBg),
                          ],
                        ).paddingSymmetric(horizontal: Insets.i20),
              const VSpace(Sizes.s15),
              if (value.servicesCart != null &&
                  value.servicesCart!.selectedServiceMan != null &&
                  value.servicesCart!.selectedServiceMan!.isNotEmpty)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            language(context, translations!.selectedServicemen),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        if ((value.servicesCart!.selectedRequiredServiceMan!) !=
                            value.servicesCart!.selectedServiceMan!.length)
                          Row(children: [
                            SvgPicture.asset(eSvgAssets.add,
                                height: Sizes.s15,
                                width: Sizes.s15,
                                fit: BoxFit.fitWidth,
                                colorFilter: ColorFilter.mode(
                                    appColor(context).primary,
                                    BlendMode.srcIn)),
                            Text(language(context, translations!.add),
                                style: appCss.dmDenseRegular14
                                    .textColor(appColor(context).primary))
                          ]).inkWell(
                              onTap: () => route.pushNamed(
                                      context, routeName.servicemanListScreen,
                                      arg: {
                                        "providerId":
                                            value.servicesCart!.user?.id,
                                        "requiredServiceman": value
                                            .servicesCart!
                                            .selectedRequiredServiceMan,
                                        "selectedServiceMan": value
                                            .servicesCart!.selectedServiceMan
                                      }).then((val) {
                                    if (val != null) {
                                      value.servicesCart!.selectedServiceMan =
                                          val;
                                      value.notifyListeners();
                                    } else {
                                      value.servicesCart!.selectedServiceMan =
                                          null;
                                    }
                                  }))
                      ]),
                  ...value.servicesCart!.selectedServiceMan!
                      .asMap()
                      .entries
                      .map(
                        (e) => ServicemanLayout(
                            image: e.value.media != null &&
                                    e.value.media!.isNotEmpty
                                ? e.value.media![0].originalUrl!
                                : null,
                            title: e.value.name,
                            rate: e.value.reviewRatings != null
                                ? e.value.reviewRatings.toString()
                                : "0",
                            exp: e.value.experienceDuration != null
                                ? e.value.experienceDuration.toString()
                                : "0",
                            expYear: e.value.experienceInterval ?? "Year",
                            editTap: () => route.pushNamed(
                                    context, routeName.servicemanListScreen,
                                    arg: {
                                      "providerId":
                                          value.servicesCart!.user?.id,
                                      "requiredServiceman": value.servicesCart!
                                          .selectedRequiredServiceMan,
                                      "selectedServiceMan":
                                          value.servicesCart!.selectedServiceMan
                                    }).then((val) {
                                  if (val != null) {
                                    value.servicesCart!.selectedServiceMan =
                                        val;
                                    value.notifyListeners();
                                  } else {
                                    value.servicesCart!.selectedServiceMan =
                                        null;
                                  }
                                }),
                            tileTap: () {
                              route.pushNamed(
                                  context, routeName.servicemanDetailScreen,
                                  arg: e.value.id);
                            }).paddingOnly(
                          top: Insets.i10,
                        ),
                      )
                ]).paddingSymmetric(horizontal: Insets.i20),
              if (value.servicesCart != null &&
                  (value.servicesCart!.selectedServiceMan == null ||
                      value.servicesCart!.selectedServiceMan!.isEmpty))
                SelectServicemanLayout(onTap: () {
                  // if (value.servicesCart != null &&
                  //     value.servicesCart!.serviceDate == null &&
                  //     (service.service?.type != "scheduled" ||
                  //         schedule.servicesCart?.type != "scheduled")) {
                  //   Fluttertoast.showToast(
                  //       msg: "Please select Date time first");
                  // } else {

                  log("message-p-pp-p-p-p${value.servicesCart.userId}");

                  route
                      .pushNamed(context, routeName.servicemanListScreen, arg: {
                    "providerId": /* value.servicesCart?.user
                              ?.id */
                        value.servicesCart.userId,
                    "requiredServiceman":
                        value.servicesCart!.selectedRequiredServiceMan
                  }).then((val) {
                    showLoading(context);
                    if (val != null) {
                      hideLoading(context);
                      value.servicesCart!.selectedServiceMan = val;
                      value.notifyListeners();
                    } else {
                      hideLoading(context);
                      value.servicesCart!.selectedServiceMan = null;
                    }
                  });
                  //}
                }).paddingOnly(
                    bottom: Insets.i15, left: Insets.i20, right: Insets.i20),
              CustomMessageLayout(
                controller: value.txtNote,
                focusNode: value.noteFocus,
                onTap: () {
                  Timer(const Duration(milliseconds: 500), () {
                    log("value.scrollController.position.maxScrollExtent:${value.scrollController.position.maxScrollExtent}");
                    value.scrollController.jumpTo(
                        value.scrollController.position.maxScrollExtent);
                    value.notifyListeners();
                  });

                  value.notifyListeners();
                },
              ).marginOnly(top: Insets.i15),
              const VSpace(Sizes.s100),
            ]),
            /*AnimatedBuilder(
                animation: value.scrollController,
                builder: (BuildContext context, Widget? child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height:
                        value.scrollController.position.userScrollDirection ==
                                ScrollDirection.reverse
                            ? 0
                            : 70,
                    child: child,
                  );
                },
                child: ButtonCommon(
                        title: value.buttonName(context),
                        margin: Insets.i20,
                        onTap: () => value.onNext(context))
                    .marginOnly(bottom: Insets.i20)
                    .backgroundColor(appColor(context).whiteBg))*/
            ButtonCommon(
                    isLoading: value.isLoading,
                    title: value.buttonName(context),
                    onTap: () => value.onNext(context),
                    margin: Insets.i20)
                .paddingOnly(bottom: Insets.i20)
                .decorated(color: appColor(context).whiteBg)
          ],
        );
      });
    });
  }
}
