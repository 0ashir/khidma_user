import 'package:intl/intl.dart';
import '../../../../config.dart';

class BookingLayout extends StatelessWidget {
  final BookingModel? data;
  final GestureTapCallback? onTap, editLocationTap, editDateTimeTap;
  final int? index;

  const BookingLayout(
      {super.key,
      this.data,
      this.onTap,
      this.index,
      this.editLocationTap,
      this.editDateTimeTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(builder: (context1, value, child) {
      /*   final extraChargesTotal = widget.data!.extraCharges!
          .map((e) => double.tryParse(e.total.toString()) ?? 0.0)
          .fold(0.0, (prev, element) => prev + element);

      final totalAmount = currency(context).currencyVal *
          ((double.tryParse(widget.data!.total.toString()) ?? 0.0) +
              extraChargesTotal); */
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (data!.servicePackageId != null) const VSpace(Sizes.s8),
                    if (data!.servicePackageId != null)
                      BookingStatusLayout(title: appFonts.package),
                    const VSpace(Sizes.s8),
                    Text(language(context, data?.service?.title),
                        maxLines: 2,
                        style: appCss.dmDenseMedium16
                            .textColor(appColor(context).darkText)),
                    Row(children: [
                      data?.grandTotalWithExtras == 0
                          ? Text(
                              language(
                                  context,
                                  symbolPosition
                                      ? "${getSymbol(context)}${data?.total?.toStringAsFixed(2)}"
                                      : "${data?.total?.toStringAsFixed(2)}${getSymbol(context)}"),
                              style: appCss.dmDenseBold18
                                  .textColor(appColor(context).darkText))
                          : Text(
                              language(
                                  context,
                                  symbolPosition
                                      ? "${getSymbol(context)}${data?.grandTotalWithExtras?.toStringAsFixed(2)}"
                                      : "${data?.grandTotalWithExtras?.toStringAsFixed(2)}${getSymbol(context)}"),
                              style: appCss.dmDenseBold18
                                  .textColor(appColor(context).darkText)),
                      const HSpace(Sizes.s8),
                      if (data!.service?.discount != null)
                        Text(
                            language(context,
                                "(${data!.service!.discount!}% ${language(context, translations!.off)})"),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).red))
                    ])
                  ])),
              data!.service!.media != null && data!.service!.media!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data!.service!.media![0].originalUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                          height: Sizes.s84,
                          width: Sizes.s84,
                          decoration: ShapeDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                              shape: const SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius.all(
                                      SmoothRadius(
                                          cornerRadius: AppRadius.r10,
                                          cornerSmoothing: 1))))),
                      placeholder: (context, url) => Container(
                          height: Sizes.s84,
                          width: Sizes.s84,
                          decoration: ShapeDecoration(
                              image: DecorationImage(
                                  image: AssetImage(eImageAssets.noImageFound1),
                                  fit: BoxFit.cover),
                              shape: const SmoothRectangleBorder(
                                  borderRadius:
                                      SmoothBorderRadius.all(SmoothRadius(cornerRadius: AppRadius.r10, cornerSmoothing: 1))))),
                      errorWidget: (context, url, error) => Container(height: Sizes.s84, width: Sizes.s84, decoration: ShapeDecoration(image: DecorationImage(image: AssetImage(eImageAssets.noImageFound1), fit: BoxFit.cover), shape: const SmoothRectangleBorder(borderRadius: SmoothBorderRadius.all(SmoothRadius(cornerRadius: AppRadius.r10, cornerSmoothing: 1)))))).padding(left: Sizes.s10)
                  : Container(height: Sizes.s84, width: Sizes.s84, decoration: ShapeDecoration(image: DecorationImage(image: AssetImage(eImageAssets.noImageFound1), fit: BoxFit.cover), shape: const SmoothRectangleBorder(borderRadius: SmoothBorderRadius.all(SmoothRadius(cornerRadius: AppRadius.r10, cornerSmoothing: 1)))))
            ]),
            Image.asset(eImageAssets.bulletDotted)
                .paddingSymmetric(vertical: Insets.i12),
            StatusRow(
              title: translations!.bookingStatus,
              statusText: data!.bookingStatus!.name,
              statusId: data!.bookingStatusId,
            ),
            // if (data!.parentBookingNumber != null)
            //   StatusRow(
            //     title: translations!.subBookingId,
            //     title2: data!.parentBookingNumber != null
            //         ? "#${data!.parentBookingNumber}"
            //         : "",
            //   ),

            if (data!.bookingStatus!.slug != translations!.cancelled)
              StatusRow(
                  statusText: data!.bookingStatus!.name,
                  statusId: data!.bookingStatusId,
                  title: translations!.selectServicemen,
                  title2:
                      "${((data!.requiredServicemen ?? 1) + (data!.totalExtraServicemen != null ? (data!.totalExtraServicemen ?? 1) : 0))} ${language(context, translations!.serviceman)}",
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).darkText)),
            if (data!.dateTime != null)
              StatusRow(
                  statusText: data!.bookingStatus!.name,
                  statusId: data!.bookingStatusId,
                  title: translations!.dateTime,
                  onTap: editDateTimeTap!,
                  title2: DateFormat("dd-MM-yyyy, hh:mm aa")
                      .format(DateTime.parse(data!.dateTime ?? "24-4")),
                  isDateLocation:
                      data!.bookingStatus!.slug == translations!.pending
                          ? true
                          : false,
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).darkText)),
            //Remove location Filed
            if (data!.address != null)
              StatusRow(
                  statusText: data!.bookingStatus!.name,
                  statusId: data!.bookingStatusId,
                  title: translations!.location,
                  onTap: editLocationTap,
                  title2: data!.address == null
                      ? getAddress(context, data!.addressId)
                      : "${data!.address!.address}-${data!.address!.area ?? data?.address?.state?.name ?? ''}",
                  isDateLocation:
                      (data!.bookingStatus!.slug == translations!.pending &&
                          data!.bookingStatus!.slug != translations!.cancelled),
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).darkText)),
            if (data!.bookingStatus!.slug != translations!.cancelled)
              StatusRow(
                  statusText: data!.bookingStatus!.name,
                  statusId: data!.bookingStatusId,
                  title: translations!.payment,
                  title2: data!.paymentStatus != null
                      ? data!.paymentMethod == "cash"
                          ? data!.paymentStatus!.toLowerCase() == "completed"
                              ? data!.paymentStatus!
                              : language(context, translations!.notPaid)
                                  .toUpperCase()
                          : data!.paymentStatus!
                      : data!.bookingStatus!.slug == translations!.completed
                          ? data!.paymentStatus == "COMPLETED"
                              ? language(context, translations!.paid)
                              : language(context, translations!.notPaid)
                          : data!.paymentMethod == "cash"
                              ? language(context, translations!.notPaid)
                              : language(context, translations!.paid),
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).online)),
            StatusRow(
                title: translations!.paymentMode,
                title2: data!.paymentMethod == "on_hand" ||
                        data!.paymentMethod == "cash"
                    ? language(context, translations!.cash)
                    : capitalizeFirstLetter(data!.paymentMethod),
                style:
                    appCss.dmDenseMedium12.textColor(appColor(context).online)),
            const VSpace(Sizes.s15),
            if (data!.isExpand!)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data!.provider != null)
                    ServiceProviderLayout(
                            title: language(context, translations!.provider),
                            image: data!.provider!.media != null &&
                                    data!.provider!.media!.isNotEmpty
                                ? data!.provider!.media![0].originalUrl!
                                : null,
                            name: data!.provider!.name,
                            rate: data!.provider!.reviewRatings != null
                                ? data!.provider!.reviewRatings.toString()
                                : "0",
                            index: 0,
                            list: const [])
                        .paddingSymmetric(horizontal: Insets.i12)
                        .boxShapeExtension(
                            color: appColor(context).fieldCardBg,
                            radius: AppRadius.r15),
                  if (data!.servicemen != null && data!.servicemen!.isNotEmpty)
                    Image.asset(eImageAssets.bulletDotted)
                        .paddingSymmetric(vertical: Insets.i12),
                  Stack(alignment: Alignment.bottomCenter, children: [
                    Column(children: [
                      if (data!.servicemen != null &&
                          data!.servicemen!.isNotEmpty)
                        Column(
                            children:
                                data!.servicemen!.asMap().entries.map((s) {
                          return ServiceProviderLayout(
                              isProvider: false,
                              title: language(context, translations!.serviceman)
                                  .capitalizeFirst(),
                              image: (s.value.media != null &&
                                      s.value.media!.isNotEmpty)
                                  ? s.value.media!.first.originalUrl
                                  : null,
                              /* image:
                                  s.value.media != null || s.value.media != []
                                      ? s.value.media?.first.originalUrl!
                                      : null, */
                              name: s.value.name,
                              rate: s.value.reviewRatings ?? "0",
                              index: s.key,
                              list: data!.servicemen!);
                        }).toList())
                    ])
                        .paddingSymmetric(horizontal: Insets.i12)
                        .boxShapeExtension(
                            color: appColor(context).fieldCardBg,
                            radius: AppRadius.r15)
                        .paddingOnly(
                            bottom: data!.servicemen != null &&
                                    data!.servicemen!.length > 1
                                ? Insets.i15
                                : 0),
                  ])
                ],
              ),
          ])
              .paddingSymmetric(vertical: Insets.i15, horizontal: Insets.i15)
              .decorated(
                  color: appColor(context).whiteBg,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  boxShadow: [
                    BoxShadow(
                        color: appColor(context).darkText.withOpacity(0.06),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 2)),
                  ],
                  border: Border.all(color: appColor(context).stroke))
              .padding(bottom: Insets.i20, horizontal: Sizes.s20)
              .inkWell(onTap: onTap),
          Transform.translate(
            offset: const Offset(0, -Insets.i10), // Moves the container upwards
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Insets.i10),
                color: appColor(context).primary,
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: Sizes.s4, horizontal: Sizes.s10),
              child: Text(
                "#${data!.bookingNumber!}",
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).whiteColor),
              ),
            ),
          ).padding(horizontal: Sizes.s40),
          Positioned(
              bottom: Insets.i2,
              left: MediaQuery.of(context).size.width / 2.2,
              /*   bottom: Insets.i5,
              left: 175,
              right: 175, */
              child: CommonArrow(
                      arrow: data!.isExpand == true
                          ? eSvgAssets.upDoubleArrow
                          : eSvgAssets.downDoubleArrow,
                      isThirteen: true,
                      onTap: () => value.onExpand(data, index!),
                      color: appColor(context).fieldCardBg)
                  .center()),
        ],
      ).paddingOnly(top: Sizes.s10, bottom: Sizes.s8);
    });
  }
}
