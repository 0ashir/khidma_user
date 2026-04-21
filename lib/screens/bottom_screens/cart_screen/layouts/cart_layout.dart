import 'package:intl/intl.dart';

import '../../../../config.dart';

class CartLayout extends StatefulWidget {
  final CartModel? data;
  final GestureTapCallback? deleteTap, editTap, infoTap;

  const CartLayout(
      {super.key, this.data, this.deleteTap, this.editTap, this.infoTap});

  @override
  State<CartLayout> createState() => _CartLayoutState();
}

class _CartLayoutState extends State<CartLayout> {
  List<ProviderModel> provider = [];
  bool isAnyEmpty = false;
  String imageUrl = "";

  @override
  void initState() {
    // TODO: implement initState

    if (widget.data!.isPackage == true) {
      provider = isServiceManEmpty(widget.data!.servicePackageList!.services!);
      widget.data!.servicePackageList!.services!
          .asMap()
          .entries
          .forEach((element) {
        if (element.value.selectServiceManType == "app_choose") {
          isAnyEmpty = true;
        }
      });
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // log("widget.data!.isPackage :${widget.data!.serviceList.user}");
    if (widget.data!.isPackage == true) {
      final mediaList = widget.data!.servicePackageList?.media;
      if (mediaList != null && mediaList.isNotEmpty) {
        imageUrl = mediaList.first.originalUrl ?? "";
      }
    } else {
      final mediaList = widget.data!.serviceList?.media;
      if (mediaList != null && mediaList.isNotEmpty) {
        imageUrl = mediaList.first.originalUrl ?? "";
      }
    }
    return Column(children: [
      IntrinsicHeight(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          CachedNetworkImage(
            imageUrl: widget.data!.isPackage!
                ? (widget.data?.servicePackageList?.user?.media != null &&
                        widget
                            .data!.servicePackageList!.user!.media!.isNotEmpty)
                    ? widget.data!.servicePackageList!.user!.media!.first
                            .originalUrl ??
                        ""
                    : ""
                : (widget.data?.serviceList?.user != null &&
                        widget.data?.serviceList?.user?.media != null &&
                        widget.data!.serviceList!.user!.media!.isNotEmpty)
                    ? widget.data!.serviceList!.user!.media!.first
                            .originalUrl ??
                        ""
                    : "",
            /*widget.data!.isPackage!
                ? (widget.data?.servicePackageList?.user?.media?.isNotEmpty ??
                        false)
                    ? widget.data!.servicePackageList!.user!.media?.first
                        .originalUrl
                    : ""
                : (widget.data?.serviceList?.user != null &&
                        widget.data?.serviceList?.user.media?.isNotEmpty)
                    ? widget.data!.serviceList!.user.media.first.originalUrl
                    : "",*/
            imageBuilder: (context, imageProvider) => Container(
                height: Sizes.s38,
                width: Sizes.s38,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover, image: imageProvider))),
            errorWidget: (context, url, error) => Container(
                height: Sizes.s38,
                width: Sizes.s38,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(eImageAssets.noImageFound1)))),
          ),
          const HSpace(Sizes.s8),
          Text(
              widget.data!.isPackage!
                  ? widget.data?.servicePackageList?.user?.name ?? ''
                  : (widget.data?.serviceList?.user != null
                      ? widget.data!.serviceList!.user!.name ?? ''
                      : ""),
              style:
                  appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
          VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: appColor(context).lightText,
                  indent: 12,
                  endIndent: 12)
              .paddingSymmetric(horizontal: Insets.i6),
          Row(children: [
            SvgPicture.asset(eSvgAssets.star),
            const HSpace(Sizes.s3),
            Text(
                widget.data!.isPackage!
                    ? widget.data!.servicePackageList!.user!.reviewRatings !=
                            null
                        ? widget.data!.servicePackageList!.user!.reviewRatings!
                            .toStringAsFixed(2)
                        : "0.0"
                    : widget.data!.serviceList!.user != null
                        ? widget.data!.serviceList!.user!.reviewRatings != null
                            ? widget.data!.serviceList!.user!.reviewRatings!
                                .toStringAsFixed(2)
                            : "0.0"
                        : "0.0",
                style: appCss.dmDenseMedium13
                    .textColor(appColor(context).darkText))
          ])
        ]),
        Row(children: [
          CommonArrow(
            arrow: eSvgAssets.edit,
            isThirteen: true,
            onTap: widget.editTap,
          ),
          const HSpace(Sizes.s6),
          CommonArrow(
              arrow: eSvgAssets.delete,
              isThirteen: true,
              onTap: widget.deleteTap,
              svgColor: appColor(context).red,
              color: appColor(context).red.withOpacity(0.1))
        ])
      ])).paddingAll(Insets.i13),
      Divider(height: 0, thickness: 1, color: appColor(context).stroke),
      const VSpace(Sizes.s12),
      Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      language(context,
                          "${widget.data!.isPackage! ? widget.data!.servicePackageList!.title : widget.data!.serviceList!.title!}"),
                      style: appCss.dmDenseSemiBold16
                          .textColor(appColor(context).darkText)),
                  const VSpace(Sizes.s4),
                  Row(children: [
                    Text(
                        language(
                            context,
                            symbolPosition
                                ? "${getSymbol(context)}${(currency(context).currencyVal * (widget.data!.isPackage! ? widget.data!.servicePackageList!.price! : widget.data!.serviceList!.serviceRate!)).toStringAsFixed(2)}"
                                : "${(currency(context).currencyVal * (widget.data!.isPackage! ? widget.data!.servicePackageList!.price! : widget.data!.serviceList!.serviceRate!)).toStringAsFixed(2)}${getSymbol(context)}"),
                        style: appCss.dmDenseBold18
                            .textColor(appColor(context).primary)),
                    if (widget.data!.isPackage!
                        ? widget.data!.servicePackageList!.discount != null
                        : widget.data!.serviceList!.discount != null)
                      Text(
                              language(context,
                                  "(${widget.data!.isPackage! ? widget.data!.servicePackageList!.discount : widget.data!.serviceList!.discount}% ${language(context, translations!.off)})"),
                              style: appCss.dmDenseMedium12
                                  .textColor(appColor(context).red))
                          .paddingSymmetric(horizontal: Insets.i2)
                  ]),
                  const VSpace(Sizes.s8),
                  widget.data!.isPackage == false &&
                          widget.data!.serviceList!.type != 'scheduled'
                      ? IntrinsicHeight(
                          child: FittedBox(
                          child: Row(children: [
                            SvgPicture.asset(
                              eSvgAssets.calendar,
                              height: Sizes.s16,
                              colorFilter: ColorFilter.mode(
                                  appColor(context).darkText, BlendMode.srcIn),
                            ),
                            const HSpace(Sizes.s6),
                            Text(
                                DateFormat("dd MMM, yyyy").format(
                                    widget.data!.serviceList!.serviceDate ??
                                        DateTime.now()),
                                style: appCss.dmDenseRegular13
                                    .textColor(appColor(context).darkText)),
                            VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    color: appColor(context).stroke,
                                    indent: 3,
                                    endIndent: 3)
                                .paddingSymmetric(horizontal: Insets.i6),
                            SvgPicture.asset(
                              eSvgAssets.clock,
                              height: Sizes.s16,
                              colorFilter: ColorFilter.mode(
                                  appColor(context).darkText, BlendMode.srcIn),
                            ),
                            const HSpace(Sizes.s6),
                            Text(
                                "${DateFormat("hh:mm").format(widget.data!.serviceList!.serviceDate ?? DateTime.now())} ${widget.data!.serviceList!.selectedDateTimeFormat ?? "AM"}",
                                style: appCss.dmDenseRegular13
                                    .textColor(appColor(context).darkText)),
                            const HSpace(Sizes.s6),
                          ]),
                        ))
                      : (widget.data!.isPackage == false &&
                              widget.data!.serviceList!.type != 'scheduled')
                          ? SizedBox(
                              width: Sizes.s200,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("\u2022 ",
                                        style: appCss.dmDenseRegular13
                                            .textColor(
                                                appColor(context).greenColor)),
                                    const HSpace(Sizes.s5),
                                    Expanded(
                                        child: Text(
                                                language(
                                                    context,
                                                    translations!
                                                        .dateTimeShowInPackageDetail),
                                                style: appCss.dmDenseMedium12
                                                    .textColor(appColor(context)
                                                        .green))
                                            .paddingOnly(right: Insets.i15))
                                  ]),
                            )
                          : const SizedBox.shrink(),
                  // Show schedule information for scheduled services
                  if (widget.data!.isPackage == false &&
                      widget.data!.serviceList!.type == 'scheduled' &&
                      widget.data!.serviceList!.isScheduledBooking == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: Sizes.s16,
                              color: appColor(context).primary,
                            ),
                            const HSpace(Sizes.s6),
                            Text(
                              "Scheduled Service",
                              style: appCss.dmDenseSemiBold13
                                  .textColor(appColor(context).primary),
                            ),
                          ],
                        ),
                        const VSpace(Sizes.s8),
                        _buildScheduleInfoRow(
                          context,
                          "From:",
                          "${DateFormat('dd MMM, yyyy').format(widget.data!.serviceList!.scheduleStartDate!)} to ${DateFormat('dd MMM, yyyy').format(widget.data!.serviceList!.scheduleEndDate!)}",
                        ),
                        const VSpace(Sizes.s6),
                        _buildScheduleInfoRow(
                          context,
                          "Time:",
                          widget.data!.serviceList!.scheduleTime ?? "",
                        ),
                        const VSpace(Sizes.s6),
                        _buildScheduleInfoRow(
                          context,
                          "Frequency:",
                          widget.data!.serviceList!.bookingFrequency
                                  ?.toUpperCase() ??
                              "",
                        ),
                        const VSpace(Sizes.s6),
                        _buildScheduleInfoRow(
                          context,
                          "Total Services:",
                          "${widget.data!.serviceList!.scheduledServicesCount ?? 0}",
                        ),
                      ],
                    ),
                ]),
          ),
          Container(
              height: Sizes.s94,
              width: Sizes.s94,
              decoration: ShapeDecoration(
                  image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      /* AssetImage(widget.data!.isPackage == true
                          ? eImageAssets.package
                          : eImageAssets.fsl1), */
                      fit: BoxFit.cover),
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 8, cornerSmoothing: 1)))))
        ]),
        const VSpace(Sizes.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                language(
                    context,
                    widget.data!.isPackage == true
                        ? translations!.includedService
                        : translations!.selectedServicemen),
                style: appCss.dmDenseMedium12
                    .textColor(appColor(context).darkText)),
            Text(
                "${widget.data!.isPackage == true ? widget.data!.servicePackageList!.services!.length : widget.data!.serviceList!.requiredServicemen} ${capitalizeFirstLetter(language(context, widget.data!.isPackage == true ? translations!.service : language(context, translations!.serviceman)))}",
                style: appCss.dmDenseSemiBold12
                    .textColor(appColor(context).primary)),
          ],
        ),
        // if (widget.data!.isPackage == false)
        //   if (widget.data?.serviceList?.selectedAdditionalServices?.isNotEmpty)
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Row(
        //       children: [
        //         Text(language(context, translations!.addOns),
        //             style: appCss.dmDenseMedium12
        //                 .textColor(appColor(context).darkText)),
        //         const HSpace(Sizes.s5),
        //         SvgPicture.asset(eSvgAssets.about,
        //                 fit: BoxFit.scaleDown,
        //                 colorFilter: ColorFilter.mode(
        //                     appColor(context).primary, BlendMode.srcIn))
        //             .inkWell(onTap: widget.infoTap)
        //       ],
        //     ),
        //     Text(
        //         "${widget.data!.serviceList!.selectedAdditionalServices!.length}",
        //         style: appCss.dmDenseSemiBold12
        //             .textColor(appColor(context).primary)),
        //   ],
        // ).marginOnly(top: Sizes.s10),
        const DottedLines().paddingSymmetric(vertical: Insets.i12),
        widget.data!.isPackage == false
            ? Column(
                children: [
                  widget.data!.serviceList!.selectedServiceMan == null ||
                          widget.data!.serviceList!.selectedServiceMan!.isEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(language(context, translations!.note),
                                  style: appCss.dmDenseRegular13
                                      .textColor(appColor(context).lightText)),
                              const HSpace(Sizes.s10),
                              Expanded(
                                  child: Column(children: [
                                Text(
                                    language(
                                        context, translations!.asYouPreviously),
                                    overflow: TextOverflow.fade,
                                    style: appCss.dmDenseRegular13
                                        .textColor(appColor(context).lightText))
                              ]))
                            ])
                      : Column(
                          children: widget
                              .data!.serviceList!.selectedServiceMan!
                              .asMap()
                              .entries
                              .map<Widget>(
                                (j) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: Sizes.s38,
                                          width: Sizes.s38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: j.value.media != null &&
                                                      j.value.media!.isNotEmpty
                                                  ? NetworkImage(j
                                                          .value
                                                          .media![0]
                                                          .originalUrl ??
                                                      '')
                                                  : AssetImage(eImageAssets
                                                      .noImageFound2),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const HSpace(Sizes.s8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              language(context,
                                                      translations!.serviceman)
                                                  .capitalizeFirst(),
                                              style: appCss.dmDenseMedium12
                                                  .textColor(appColor(context)
                                                      .lightText),
                                            ),
                                            Text(
                                              j.value.name ?? 'Unknown',
                                              style: appCss.dmDenseMedium14
                                                  .textColor(appColor(context)
                                                      .darkText),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(eSvgAssets.star),
                                        const HSpace(Sizes.s3),
                                        Text(
                                          j.value.reviewRatings?.toString() ??
                                              '0.0',
                                          style: appCss.dmDenseMedium13
                                              .textColor(
                                                  appColor(context).darkText),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                                    .paddingAll(Insets.i12)
                                    .boxShapeExtension(
                                        color: appColor(context).fieldCardBg)
                                    .paddingOnly(bottom: Insets.i10),
                              )
                              .toList(),
                        )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language(context,
                                translations!.totalSelectedServicemenList),
                            style: appCss.dmDenseRegular14
                                .textColor(appColor(context).darkText),
                          ),
                          const VSpace(Sizes.s10),
                          ...provider.asMap().entries.map(
                                (j) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Row(children: [
                                        Container(
                                            height: Sizes.s38,
                                            width: Sizes.s38,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(j
                                                        .value
                                                        .media![0]
                                                        .originalUrl!)))),
                                        const HSpace(Sizes.s8),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  language(
                                                          context,
                                                          translations!
                                                              .serviceman)
                                                      .capitalizeFirst(),
                                                  style: appCss.dmDenseMedium12
                                                      .textColor(
                                                          appColor(context)
                                                              .lightText)),
                                              Text(j.value.name!,
                                                  style: appCss.dmDenseMedium14
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText))
                                            ])
                                      ]),
                                      Row(children: [
                                        SvgPicture.asset(eSvgAssets.star),
                                        const HSpace(Sizes.s3),
                                        Text(
                                            j.value.reviewRatings != null
                                                ? j.value.reviewRatings
                                                    .toString()
                                                : "0",
                                            style: appCss.dmDenseMedium13
                                                .textColor(
                                                    appColor(context).darkText))
                                      ])
                                    ])
                                    .paddingAll(Insets.i12)
                                    .boxShapeExtension(
                                        color: appColor(context).fieldCardBg)
                                    .paddingOnly(bottom: Insets.i10),
                              ),
                        ]),
                  if (isAnyEmpty)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language(context, translations!.note),
                              style: appCss.dmDenseRegular13
                                  .textColor(appColor(context).lightText)),
                          const HSpace(Sizes.s10),
                          Expanded(
                              child: Column(children: [
                            Text(language(context, translations!.appSelectNote),
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.start,
                                style: appCss.dmDenseRegular13
                                    .textColor(appColor(context).lightText))
                          ]))
                        ]),
                ],
              ),
        // if (data!.isPackage == true) const DottedLines(),
        /* if (data!.isPackage == true)
          Text(language(context, translations!.thisServiceIsSelected),
                  style: appCss.dmDenseSemiBold12
                      .textColor(appColor(context).online))
              .paddingOnly(top: Insets.i12)*/
      ]).paddingSymmetric(horizontal: Insets.i15),
      const VSpace(Sizes.s15),
    ])
        .boxBorderExtension(context, isShadow: true)
        .paddingOnly(bottom: Insets.i15);
  }

  Widget _buildScheduleInfoRow(
      BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appCss.dmDenseMedium12.textColor(appColor(context).darkText),
        ),
        const HSpace(Sizes.s6),
        Expanded(
          child: Text(
            value,
            style:
                appCss.dmDenseRegular12.textColor(appColor(context).lightText),
          ),
        ),
      ],
    );
  }
}
