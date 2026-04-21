import 'dart:async';
import 'dart:developer';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/add_job_request/layouts/dark_drop_down_layout.dart';
import 'package:fixit_user/utils/custom_time_picker.dart';
import 'package:intl/intl.dart';
import '../../../../config.dart';
import '../../services_details_screen/layouts/add_on_service_card.dart';
import 'weekday_selection.dart';
import 'custom_date_selection.dart';

class StepOneLayout extends StatefulWidget {
  const StepOneLayout({super.key});

  @override
  State<StepOneLayout> createState() => _StepOneLayoutState();
}

class _StepOneLayoutState extends State<StepOneLayout>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer3<SlotBookingProvider, ServicesDetailsProvider,
            ProviderDetailsProvider>(
        builder: (context1, value, serviceCtrl, provider, child) {
      log("choose serviceType ${provider.selectProviderIndex}");
      return Consumer<LocationProvider>(builder: (context2, loc, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
              child: Stack(alignment: Alignment.bottomCenter, children: [
            value.servicesCart == null
                ? Center(
                    child: Image.asset(
                    eGifAssets.loader,
                    height: Sizes.s100,
                  ))
                : ListView(controller: value.scrollController, children: [
                    const VSpace(Sizes.s15),
                    loc.addressList.isEmpty && value.address == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(language(context, translations!.location),
                                    overflow: TextOverflow.ellipsis,
                                    style: appCss.dmDenseMedium14
                                        .textColor(appColor(context).darkText)),
                                const VSpace(Sizes.s5),
                                ButtonCommon(
                                    title: language(
                                        context, translations!.addLocation),
                                    color: appColor(context).whiteBg,
                                    onTap: () => value.addNewLoc(context),
                                    fontColor: appColor(context).primary,
                                    borderColor: appColor(context).primary)
                              ]).marginOnly(
                            bottom: Insets.i10,
                            right: Insets.i20,
                            left: Insets.i20)
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
                    if (value.servicesCart!.selectedAdditionalServices !=
                            null &&
                        value.servicesCart!.selectedAdditionalServices!
                            .isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language(context, translations!.addOns),
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).darkText)),
                          const VSpace(Sizes.s10),
                          /*    Text(
                              "data${value.servicesCart!.selectedAdditionalServices}"), */
                          ...value.servicesCart!.selectedAdditionalServices!
                              .asMap()
                              .entries
                              .map((e) => AddOnServiceCard(
                                    deleteTap: () =>
                                        value.deleteJobRequestConfirmation(
                                            context, this, e.key),
                                    index: e.key,
                                    isDelete: true,
                                    incrementTap: () =>
                                        serviceCtrl.increment(e.key),
                                    decrementTap: () =>
                                        serviceCtrl.decrement(e.key),
                                    additionalServices: e.value,
                                    additionalServicesLength: value
                                            .servicesCart!
                                            .selectedAdditionalServices!
                                            .length -
                                        1,
                                  ))
                        ],
                      ).padding(horizontal: Insets.i20, bottom: Sizes.s20),
                    value.servicesCart != null &&
                            value.servicesCart!.serviceDate != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  language(
                                      context, translations!.bookedDateTime),
                                  style: appCss.dmDenseMedium14
                                      .textColor(appColor(context).darkText)),
                              const VSpace(Sizes.s10),
                              BookedDateTimeLayout(
                                  onTap: () {
                                    value.servicesCart!.serviceDate = null;
                                    value.servicesCart!.selectedDateTimeFormat =
                                        null;
                                  },
                                  date: DateFormat('dd MMMM, yyyy')
                                      .format(value.servicesCart!.serviceDate!),
                                  time:
                                      "${translations!.at} ${DateFormat('hh:mm').format(value.servicesCart!.serviceDate!)} ${value.servicesCart!.selectedDateTimeFormat ?? DateFormat('aa').format(value.servicesCart!.serviceDate!)}"),
                            ],
                          ).paddingSymmetric(horizontal: Insets.i20)
                        : (serviceCtrl.service?.type == "scheduled" ||
                                value.servicesCart?.type == "scheduled")
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                          translations!.bookingFrequency
                                              .toString(),
                                          style: appCss.dmDenseSemiBold16
                                              .textColor(
                                                  appColor(context).darkText))
                                      .paddingSymmetric(
                                          horizontal: Insets.i20,
                                          vertical: Insets.i10),
                                  SizedBox(
                                      height: 50,
                                      child: DarkDropDownLayout(
                                          isBig: true,
                                          val: value.bookingFrequency,
                                          hintText: translations!.daily,
                                          isField: true,
                                          isIcon: false,
                                          bookingFrequencyList:
                                              appArray.bookingFrequencyList,
                                          onChanged: (val) =>
                                              value.onChangeBookingFrequency(
                                                  val)).paddingDirectional(
                                          horizontal: Sizes.s20)),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: Sizes.s20,
                                        vertical: Sizes.s20),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: Sizes.s12,
                                        vertical: Sizes.s12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: appColor(context)
                                            .fieldCardBg, // border color
                                        width: Sizes.s1, // border width
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                                translations!.serviceDuration
                                                    .toString(),
                                                style: appCss.dmDenseSemiBold16
                                                    .textColor(appColor(context)
                                                        .darkText))
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
                                                            borderRadius: BorderRadius.circular(
                                                                AppRadius.r8),
                                                            borderSide: BorderSide(
                                                                color: appColor(context)
                                                                    .stroke)),
                                                        focusNode: value
                                                            .startDateFocus,
                                                        controller:
                                                            value.startDateCtrl,
                                                        style: appCss
                                                            .dmDenseMedium13
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
                                                    .inkWell(onTap: () => value.onDateSelect(context, value.startDateCtrl.text))
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
                                                            borderRadius: BorderRadius.circular(
                                                                AppRadius.r8),
                                                            borderSide: BorderSide(
                                                                color: appColor(context)
                                                                    .stroke)),
                                                        focusNode:
                                                            value.endDateFocus,
                                                        controller:
                                                            value.endDateCtrl,
                                                        hintText: translations!
                                                            .endDate!,
                                                        style: appCss.dmDenseMedium13
                                                            .textColor(
                                                                appColor(context)
                                                                    .darkText),
                                                        validator: (value) =>
                                                            validation.dynamicTextValidation(
                                                                context,
                                                                value,
                                                                translations!
                                                                    .pleaseSelectEndDate),
                                                        prefixIcon:
                                                            eSvgAssets.calendar)
                                                    .inkWell(onTap: () => value.onDateSelect(context, value.endDateCtrl.text))
                                              ]))
                                        ]),
                                        if (value.bookingFrequency == "daily")
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                      translations!.selectDays!
                                                          .toString(),
                                                      style: appCss
                                                          .dmDenseSemiBold16
                                                          .textColor(
                                                              appColor(context)
                                                                  .darkText))
                                                  .paddingOnly(
                                                      top: Sizes.s10,
                                                      bottom: Sizes.s5),
                                              const WeekDaySelectionLayout()
                                            ],
                                          ),
                                        if (value.bookingFrequency == "custom")
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                      translations!
                                                          .selectDateOnly
                                                          .toString(),
                                                      style: appCss
                                                          .dmDenseSemiBold16
                                                          .textColor(
                                                              appColor(context)
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
                                  // Column(
                                  //   children: [
                                  //     Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         Text(
                                  //           language(context,
                                  //               translations!.customDateTime),
                                  //           style: appCss.dmDenseRegular14
                                  //               .textColor(
                                  //             value.selectIndex == 0
                                  //                 ? appColor(context).primary
                                  //                 : appColor(context).darkText,
                                  //           ),
                                  //         ),
                                  //         CommonRadio(
                                  //           onTap: () => value.onDateTimeSelect(
                                  //               context, 0),
                                  //           index: 0,
                                  //           selectedIndex: value.selectIndex,
                                  //         ),
                                  //       ],
                                  //     ).inkWell(
                                  //         onTap: () => value.onDateTimeSelect(
                                  //             context, 0)),
                                  //     const VSpace(Sizes.s15),
                                  //     Divider(
                                  //       height: 1,
                                  //       thickness: 1,
                                  //       color: appColor(context).stroke,
                                  //     ).paddingSymmetric(vertical: Insets.i10),
                                  //     const VSpace(Sizes.s15),
                                  //     Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         Text(
                                  //           language(context,
                                  //               translations!.asPerProvider),
                                  //           style: appCss.dmDenseRegular14
                                  //               .textColor(
                                  //             value.selectIndex == 1
                                  //                 ? appColor(context).primary
                                  //                 : appColor(context).darkText,
                                  //           ),
                                  //         ),
                                  //         CommonRadio(
                                  //           onTap: () => value.onDateTimeSelect(
                                  //               context, 1),
                                  //           index: 1,
                                  //           selectedIndex: value.selectIndex,
                                  //         ),
                                  //       ],
                                  //     ).inkWell(
                                  //         onTap: () => value.onDateTimeSelect(
                                  //             context, 1)),
                                  //   ],
                                  // )
                                  //     .paddingSymmetric(
                                  //         vertical: Insets.i20,
                                  //         horizontal: Sizes.s20)
                                  //     .decorated(
                                  //       color: appColor(context).whiteBg,
                                  //       borderRadius:
                                  //           BorderRadius.circular(AppRadius.r8),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: appColor(context)
                                  //               .darkText
                                  //               .withOpacity(0.06),
                                  //           blurRadius: 12,
                                  //           spreadRadius: 0,
                                  //           offset: const Offset(0, 2),
                                  //         ),
                                  //       ],
                                  //       border: Border.all(
                                  //           color: appColor(context).stroke),
                                  //     )
                                  //     .paddingSymmetric(horizontal: Insets.i20)
                                  //     .paddingOnly(bottom: Insets.i20),
                                  // if (value.selectIndex == 0)
                                  Column(
                                    children: [
                                      Text(
                                              language(
                                                  context, translations!.time),
                                              style: appCss.dmDenseBold14
                                                  .textColor(appColor(context)
                                                      .darkText))
                                          .paddingOnly(
                                              bottom: Insets.i10,
                                              left: Insets.i20)
                                          .alignment(Alignment.centerLeft),
                                      Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CustomTimePicker(
                                                      title: language(context,
                                                          translations!.hour),
                                                      itemList:
                                                          appArray.hourList,
                                                      carouselController: value
                                                          .carouselController,
                                                      onScroll: (index) => value
                                                          .onHourScroll(index)),
                                                  const HSpace(Sizes.s15),
                                                  SvgPicture.asset(
                                                      eSvgAssets.colonIcon),
                                                  const HSpace(Sizes.s15),
                                                  CustomTimePicker(
                                                      title: language(context,
                                                          translations!.minute),
                                                      itemList:
                                                          appArray.minList,
                                                      onScroll: (index) => value
                                                          .onMinScroll(index),
                                                      carouselController: value
                                                          .carouselController1),
                                                  const HSpace(Sizes.s20),
                                                  CustomTimePicker(
                                                      title: language(context,
                                                          translations!.day),
                                                      onScroll: (index) =>
                                                          value.onAmPmChange(
                                                              context, index),
                                                      carouselController: value
                                                          .carouselController2,
                                                      itemList:
                                                          appArray.amPmList)
                                                ])
                                          ]),
                                    ],
                                  ),
                                  if (value.selectedDateList.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("${translations?.scheduledList} (${value.selectedDateList.length})",
                                                style: appCss.dmDenseBold14
                                                    .textColor(appColor(context)
                                                        .darkText))
                                            .paddingDirectional(
                                                vertical: Sizes.s10),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Sizes.s12,
                                                vertical: Sizes.s12),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: appColor(context)
                                                        .fieldCardBg,
                                                    width: Sizes.s2),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ListView.separated(
                                                      separatorBuilder: (context,
                                                              index) =>
                                                          Divider(
                                                              height: 20,
                                                              thickness: 1,
                                                              color:
                                                                  appColor(
                                                                          context)
                                                                      .fieldCardBg),
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: value
                                                          .selectedDateList
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        DateTime date = value
                                                                .selectedDateList[
                                                            index];
                                                        String hour = appArray
                                                                .hourList[
                                                            value
                                                                .scrollHourIndex];
                                                        String minute = appArray
                                                                .minList[
                                                            value
                                                                .scrollMinIndex];
                                                        String amPm = appArray
                                                                .amPmList[
                                                            value.amIndex ?? 0];
                                                        return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  DateFormat(
                                                                          "dd MMM, yyyy")
                                                                      .format(
                                                                          date),
                                                                  style: appCss
                                                                      .dmDenseMedium13
                                                                      .textColor(
                                                                          appColor(context)
                                                                              .darkText)),
                                                              Text(
                                                                  "$hour:$minute $amPm",
                                                                  style: appCss
                                                                      .dmDenseMedium13
                                                                      .textColor(
                                                                          appColor(context)
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
                                  Text(
                                    language(context, translations!.dateTime),
                                    style: appCss.dmDenseMedium14
                                        .textColor(appColor(context).darkText),
                                  ).paddingSymmetric(horizontal: Insets.i20),
                                  Text(
                                    "${language(context, translations!.thisServiceWill)} ${value.servicesCart!.duration ?? "0"} ${value.servicesCart!.durationUnit ?? "hours"}",
                                    style: appCss.dmDenseMedium12
                                        .textColor(appColor(context).lightText),
                                  ).paddingSymmetric(horizontal: Insets.i20),
                                  const VSpace(Sizes.s10),
                                  TimeSlotLayout(
                                    title: translations!.dateTime,
                                    onTap: () =>
                                        value.onProviderDateTimeSelect(context),
                                  ).paddingSymmetric(horizontal: Insets.i20),
                                ],
                              ),
                    const VSpace(Sizes.s15),
                    const ServicemanQuantityLayout(),
                    if ((value.servicesCart?.selectedRequiredServiceMan ?? 0) >
                        (value.servicesCart?.requiredServicemen ?? 1))
                      Text(language(context, translations!.youWillOnly),
                              style: appCss.dmDenseMedium12
                                  .textColor(appColor(context).red))
                          .paddingOnly(bottom: Insets.i25)
                          .paddingSymmetric(horizontal: Insets.i20),
                    CustomMessageLayout(
                        onTap: () {
                          Timer(const Duration(milliseconds: 500), () {
                            log("value.scrollController.position.maxScrollExtent:${value.scrollController.position.maxScrollExtent}");
                            value.scrollController.jumpTo(value
                                .scrollController.position.maxScrollExtent);
                          });
                        },
                        controller: value.txtNote,
                        focusNode: value.noteFocus),
                    const VSpace(Sizes.s100)
                  ]),
            ButtonCommon(
                    isLoading: value.isNextLoading,
                    title: value.buttonName(context),
                    margin: Insets.i20,
                    onTap: () => value.onTapNext(context))
                .marginOnly(bottom: Insets.i20)
                .backgroundColor(appColor(context).whiteBg)
          ])),
        );
      });
    });
  }
}
