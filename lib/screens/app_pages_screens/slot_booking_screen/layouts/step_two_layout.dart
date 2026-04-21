import 'dart:developer';

import 'package:intl/intl.dart';
import '../../../../config.dart';

class StepTwoLayout extends StatelessWidget {
  const StepTwoLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SlotBookingProvider>(builder: (context2, value, child) {
      final currencyValue = currency(context).currencyVal;

      final price = value.servicesCart?.price ?? 0;
      final requiredServicemen = value.servicesCart?.requiredServicemen ?? 1;
      final selectedServicemen =
          value.servicesCart?.selectedRequiredServiceMan ?? requiredServicemen;

      double totalPrice =
          currencyValue * ((price / requiredServicemen) * selectedServicemen);
      dynamic baseRate = value.servicesCart
          ?.serviceRate /* currencyValue * (serviceRate * selectedServicemen) */;
      double difference = totalPrice - baseRate;
      log("message.  $difference");
      num? scheduleCount = value.selectedDateList.length;
      double schedulePrice = (baseRate?.toDouble() ?? 0.0) * (scheduleCount);

      String formattedSchedulePrice = symbolPosition
          ? "${getSymbol(context)}${schedulePrice.toStringAsFixed(2)}"
          : "${schedulePrice.toStringAsFixed(2)}${getSymbol(context)}";

      return SafeArea(
          child: Stack(alignment: Alignment.bottomCenter, children: [
        ListView(children: [
          Text(language(context, translations!.billDetails).toUpperCase(),
              style: appCss.dmDenseSemiBold16
                  .textColor(appColor(context).primary)),
          const VSpace(Sizes.s15),
          value.servicesCart!.selectServiceManType == "app_choose"
              ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      SvgPicture.asset(eSvgAssets.about,
                          colorFilter: ColorFilter.mode(
                              appColor(context).darkText, BlendMode.srcIn),
                          fit: BoxFit.scaleDown),
                      const HSpace(Sizes.s10),
                      Expanded(
                          child: Column(children: [
                        Text(language(context, translations!.asYouPreviously),
                            overflow: TextOverflow.fade,
                            style: appCss.dmDenseRegular14
                                .textColor(appColor(context).darkText))
                      ]))
                    ])
                  .paddingAll(Insets.i15)
                  .boxShapeExtension(color: appColor(context).fieldCardBg)
              : Container(),
          const VSpace(Sizes.s25),

          Text(language(context, translations!.bookedDateTime),
              style:
                  appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
          const VSpace(Sizes.s10),

          // Show scheduled service card if there are multiple dates selected
          if (value.selectedDateList.isNotEmpty &&
              value.bookingFrequency != null &&
              value.servicesCart!.type == "scheduled")
            Container(
              padding: const EdgeInsets.all(Sizes.s16),
              decoration: BoxDecoration(
                color: appColor(context).primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations?.scheduledService ?? "Scheduled Service",
                    style: appCss.dmDenseSemiBold16
                        .textColor(const Color(0xFF1A5F7A)),
                  ),
                  const VSpace(Sizes.s12),
                  _buildScheduleInfoRow(
                    context,
                    "Booking Frequency:",
                    value.bookingFrequency ?? "",
                  ),
                  const VSpace(Sizes.s8),
                  _buildScheduleInfoRow(
                    context,
                    "From:",
                    "${DateFormat('yyyy-MM-dd').format(value.rangeStart ?? value.selectedDateList.first)} To ${DateFormat('yyyy-MM-dd').format(value.rangeEnd ?? value.selectedDateList.last)}",
                  ),
                  const VSpace(Sizes.s8),
                  _buildScheduleInfoRow(
                    context,
                    "Time:",
                    "${appArray.hourList[value.scrollHourIndex]}:${appArray.minList[value.scrollMinIndex]} ${appArray.amPmList[value.amIndex ?? 0]}",
                  ),
                  const VSpace(Sizes.s8),
                  _buildScheduleInfoRow(
                    context,
                    "Total Scheduled Services:",
                    "${value.selectedDateList.length}",
                  ),
                ],
              ),
            )
          else
            // Show normal date/time for regular bookings
            BookedDateTimeLayout(
                onTap: () => value.onProviderDateTimeSelect(context),
                date: DateFormat('dd MMMM, yyyy').format(
                  value.servicesCart!.serviceDate ?? DateTime.now(),
                ),
                time:
                    "At ${DateFormat('hh:mm').format(value.servicesCart?.serviceDate ?? DateTime.now())} ${value.servicesCart?.selectedDateTimeFormat ?? DateFormat('a').format(value.servicesCart?.serviceDate ?? DateTime.now())}"),
          const VSpace(Sizes.s25),
          BillSummaryLayout(
              balance: symbolPosition
                  ? "${getSymbol(context)}${(currency(context).currencyVal * (userModel?.wallet != null ? userModel?.wallet?.balance ?? 0 : 0.0)).toStringAsFixed(2)}"
                  : "${(currency(context).currencyVal * (userModel?.wallet != null ? userModel?.wallet?.balance ?? 0 : 0.0)).toStringAsFixed(2)}${getSymbol(context)}"),
          const VSpace(Sizes.s10),
          Container(
              //  height: Sizes.s200,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: Insets.i20),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(isDark(context)
                          ? eImageAssets.pendingBillBgDark
                          : eImageAssets.pendingBillBg),
                      fit: BoxFit.fill)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      BillRowCommon(
                          title: translations!.perServiceCharge,
                          price: symbolPosition
                              ? "${getSymbol(context)}${value.step2Data?.perServicemanCharge ?? "00.00"}"
                              : "${value.step2Data?.perServicemanCharge}${getSymbol(context)}"),
                      BillRowCommon(
                              title: symbolPosition
                                  ? "${value.step2Data?.requiredServicemen} ${language(context, translations!.serviceman)} "
                                      "(${getSymbol(context)}${value.step2Data?.perServicemanCharge ?? "00.00"} × "
                                      "${value.step2Data?.requiredServicemen})"
                                  : "${value.servicesCart?.requiredServicemen ?? 0} ${language(context, translations!.serviceman)} "
                                      "(${value.step2Data?.perServicemanCharge ?? "00.00"}${getSymbol(context)} × "
                                      "${value.step2Data?.requiredServicemen})",
                              price: symbolPosition
                                  ? "${getSymbol(context)}${value.step2Data?.totalServicemenCharge ?? "00.00"}"
                                  : "${value.step2Data?.totalServicemenCharge ?? "00.00"}${getSymbol(context)}")
                          .marginOnly(top: Insets.i20),
                      if (value.servicesCart!.discount != null &&
                          value.servicesCart!.discount != 0)
                        BillRowCommon(
                                color: appColor(context).red,
                                title:
                                    "${translations!.appliedDiscount} (${value.servicesCart!.discount}%)",
                                price: (value.servicesCart?.discount == 0)
                                    ? "0"
                                    : symbolPosition
                                        ? "-${getSymbol(context)}${value.step2Data?.discountAmount}"
                                        : "-${value.step2Data?.discountAmount}${getSymbol(context)}")
                            .marginOnly(top: Insets.i20),
                      if (value.servicesCart!.selectedAdditionalServices !=
                              null &&
                          value.servicesCart!.selectedAdditionalServices!
                              .isNotEmpty)
                        /*  Text(
                            "${value.step2Data?.additionalServices!.length.toString()}"), */
                        if (value.step2Data?.additionalServices != null &&
                            value.step2Data!.additionalServices!.isNotEmpty)
                          const VSpace(Sizes.s20),
                      /*   if (value.servicesCart!.selectedAdditionalServices !=
                              null &&
                          value.servicesCart!.selectedAdditionalServices!
                              .isNotEmpty) */
                      if (value.step2Data?.additionalServices != null &&
                          value.step2Data!.additionalServices!.isNotEmpty)
                        /* ...value.servicesCart!.selectedAdditionalServices! */
                        ...value.step2Data!.additionalServices!.map((charge) {
                          return BillRowCommon(
                            title:
                                "${charge.title} (\$${charge.price} × ${charge.qty} )",
                            color: appColor(context).green,
                            price: symbolPosition
                                ? "+ ${getSymbol(context)}${(currency(context).currencyVal * (charge.totalPrice ?? 0.0)).toStringAsFixed(2)}"
                                : "+ ${(currency(context).currencyVal * (charge.totalPrice ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                          ).padding(bottom: Insets.i10);
                        }),
                      if (value.servicesCart?.type == 'scheduled')
                        BillRowCommon(
                                title:
                                    "Total Scheduled Services : ${value.selectedDateList.length}",
                                price: formattedSchedulePrice)
                            .marginOnly(top: Insets.i20),
                      const VSpace(Sizes.s20),
                    ]),
                    Column(children: [
                      const VSpace(Sizes.s20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language(context, translations!.totalAmount),
                                style: appCss.dmDenseMedium14
                                    .textColor(appColor(context).darkText)),
                            /* if (value.servicesCart!
                                        .selectedAdditionalServices !=
                                    null &&
                                value.servicesCart!.selectedAdditionalServices!
                                    .isNotEmpty) */
                            Text(
                                value.servicesCart != null
                                    ? value.servicesCart!.type == "scheduled"
                                        ? formattedSchedulePrice
                                        : symbolPosition
                                            ? "${getSymbol(context)}${value.step2Data?.totalAmount}"
                                            : "${value.step2Data?.totalAmount ?? "00.00"}${getSymbol(context)}"
                                    : "",
                                style: appCss.dmDenseBold16
                                    .textColor(appColor(context).primary)),
                            /*  Text(
                                "data${value.servicesCart!.selectedAdditionalServices}"), */
                            /*   if (value.servicesCart!
                                        .selectedAdditionalServices ==
                                    null ||
                                value.servicesCart!.selectedAdditionalServices!
                                    .isEmpty)
                              Text(
                                  value.servicesCart != null
                                      ? symbolPosition
                                          ? "${getSymbol(context)}${(currency(context).currencyVal * (value.servicesCart!.serviceRate! /* * value.servicesCart!.selectedRequiredServiceMan! */)).toStringAsFixed(2)}"
                                          : "${(currency(context).currencyVal * (value.servicesCart!.serviceRate! /* * value.servicesCart!.selectedRequiredServiceMan! */)).toStringAsFixed(2)}${getSymbol(context)}"
                                      : "",
                                  style: appCss.dmDenseBold16
                                      .textColor(appColor(context).primary)), */
                          ]).paddingSymmetric(horizontal: Insets.i15)
                    ])
                  ])),
          const VSpace(Sizes.s100),
        ]).paddingSymmetric(horizontal: Insets.i20),
        ButtonCommon(
                title: translations?.confirmBooking ??
                    language(context, appFonts.confirmBooking),
                onTap: () => value.addToCart(context),
                margin: Insets.i20)
            .paddingOnly(bottom: Insets.i20)
            .backgroundColor(appColor(context).whiteBg)
      ]));
    });
  }

  Widget _buildScheduleInfoRow(
      BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appCss.dmDenseMedium13.textColor(const Color(0xFF1A5F7A)),
        ),
        const HSpace(Sizes.s8),
        Expanded(
          child: Text(
            value,
            style: appCss.dmDenseRegular13.textColor(const Color(0xFF1A5F7A)),
          ),
        ),
      ],
    );
  }
}
