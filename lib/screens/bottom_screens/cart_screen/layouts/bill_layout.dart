import 'dart:developer';

import '../../../../config.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<CartProvider>(context, listen: true);
    final services = value.checkoutModel?.services ?? [];

    log("service data is -----> ${services.isNotEmpty ? services[0].baseSubtotal : 'empty'}");

    return value.checkoutModel != null
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: Insets.i20),
            width: MediaQuery.of(context).size.width,
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
                    // ── Package services ──────────────────────────────────
                    if (value.checkoutModel!.servicesPackage != null &&
                        value.checkoutModel!.servicesPackage!.isNotEmpty)
                      Column(
                        children: [
                          ...value.checkoutModel!.servicesPackage!
                              .asMap()
                              .entries
                              .map((e) => Column(
                                    children: e.value.services!
                                        .asMap()
                                        .entries
                                        .map((ser) {
                                      int total = getTotalRequiredServiceMan(
                                          value.cartList,
                                          ser.value.serviceId,
                                          true);
                                      return (ser.value.total?.totalServicemen ?? 0) > 1
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(children: [
                                                  Text(
                                                      getName(value.cartList,
                                                          ser.value.serviceId, true),
                                                      style: appCss.dmDenseMedium14
                                                          .textColor(appColor(context)
                                                              .lightText)),
                                                  const HSpace(Sizes.s5),
                                                  SvgPicture.asset(
                                                          eSvgAssets.about,
                                                          fit: BoxFit.scaleDown,
                                                          colorFilter: ColorFilter.mode(
                                                              appColor(context).primary,
                                                              BlendMode.srcIn))
                                                      .inkWell(
                                                          onTap: () =>
                                                              value.onServiceDetail(
                                                                  context,
                                                                  packageServices:
                                                                      ser.value,
                                                                  totalServiceman:
                                                                      total))
                                                ]),
                                                Text(
                                                    symbolPosition
                                                        ? "${getSymbol(context)}${(currency(context).currencyVal * (ser.value.total?.subtotal ?? 0)).toStringAsFixed(2)}"
                                                        : "${(currency(context).currencyVal * (ser.value.total?.subtotal ?? 0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                    style: appCss.dmDenseMedium14
                                                        .textColor(
                                                            appColor(context).darkText))
                                              ]).paddingOnly(
                                              bottom: Insets.i10,
                                              right: Insets.i15,
                                              left: Insets.i15)
                                          : BillRowCommon(
                                                  title: getName(value.cartList,
                                                      ser.value.serviceId, true),
                                                  color: appColor(context).darkText,
                                                  price: symbolPosition
                                                      ? "${getSymbol(context)}${(currency(context).currencyVal * (ser.value.total?.subtotal ?? 0)).toStringAsFixed(2)}"
                                                      : "${(currency(context).currencyVal * (ser.value.total?.subtotal ?? 0)).toStringAsFixed(2)}${getSymbol(context)}")
                                              .paddingOnly(bottom: Insets.i10);
                                    }).toList(),
                                  ))
                        ],
                      ),

                    // ── Regular services — iterate with index ─────────────
                    if (value.cartList.isNotEmpty && services.isNotEmpty)
                      Column(
                        children: value.cartList.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final service = item.serviceList;

                          // Guard: skip if no matching checkout service at this index
                          if (idx >= services.length) return const SizedBox.shrink();

                          final checkoutService = services[idx];

                          final discount = service?.discount ?? 0;
                          final title = service?.title ?? "Service";
                          final isScheduled = checkoutService.type == "scheduled";
                          final double scheduledPrice =
                              (checkoutService.baseSubtotal ?? 0).toDouble();
                          final int serviceCount =
                              checkoutService.scheduledServicesCount ?? 1;
                          final double price = (service?.price ?? 0).toDouble();
                          final double finalPrice = isScheduled
                              ? scheduledPrice * serviceCount.toDouble()
                              : price;
                          final double discountedAmount =
                              discount > 0 ? (price * discount / 100) : 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service title + price row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isScheduled
                                        ? "$title (${translations?.total} ${translations?.scheduledService} : $serviceCount)"
                                        : title,
                                    style: appCss.dmDenseMedium14
                                        .textColor(appColor(context).lightText),
                                  ).width(Sizes.s200),
                                  Text(
                                    symbolPosition
                                        ? "${getSymbol(context)}${finalPrice.toStringAsFixed(2)}"
                                        : "${finalPrice.toStringAsFixed(2)}${getSymbol(context)}",
                                    style: appCss.dmDenseMedium14
                                        .textColor(appColor(context).darkText),
                                  ),
                                ],
                              ).paddingOnly(
                                  bottom: Insets.i10, left: Insets.i15, right: Insets.i15),

                              // Discount row
                              if (discount > 0 && !isScheduled)
                                BillRowCommon(
                                  title: "Discount (${discount.toStringAsFixed(0)}%)",
                                  color: appColor(context).red,
                                  price: symbolPosition
                                      ? "-${getSymbol(context)}${discountedAmount.toStringAsFixed(2)}"
                                      : "-${discountedAmount.toStringAsFixed(2)}${getSymbol(context)}",
                                ).paddingOnly(bottom: Insets.i10),

                              // Scheduled subtotal row
                              if (isScheduled)
                                BillRowCommon(
                                  title: "${translations?.subtotal}",
                                  price: symbolPosition
                                      ? "${getSymbol(context)}${scheduledPrice.toStringAsFixed(2)}"
                                      : "${scheduledPrice.toStringAsFixed(2)}${getSymbol(context)}",
                                ).paddingOnly(bottom: Insets.i10),

                              // Add-ons
                              if (service?.selectedAdditionalServices != null &&
                                  service!.selectedAdditionalServices!.isNotEmpty)
                                ...service.selectedAdditionalServices!.map((addon) {
                                  final addonTitle = addon.title ?? "Add-On";
                                  final addonPrice = addon.price ?? 0;
                                  final totalPrice = addonPrice * addon.qty;
                                  return BillRowCommon(
                                    title: "$addonTitle (\$$addonPrice × ${addon.qty})",
                                    color: appColor(context).green,
                                    price: symbolPosition
                                        ? "+${getSymbol(context)}${totalPrice.toStringAsFixed(2)}"
                                        : "+${totalPrice.toStringAsFixed(2)}${getSymbol(context)}",
                                  ).paddingOnly(bottom: Insets.i10);
                                }).toList(),

                              // Tax — use this service's own taxes, not always [0]
                              if (checkoutService.taxes != null &&
                                  checkoutService.taxes!.isNotEmpty)
                                BillRowCommon(
                                  title:
                                      "${translations!.tax}(${checkoutService.taxes![0].rate ?? 0}%)",
                                  color: appColor(context).online,
                                  price:
                                      "+${getSymbol(context)}${(currency(context).currencyVal * (checkoutService.taxes![0].amount ?? 0)).toStringAsFixed(2)}",
                                ).paddingOnly(bottom: Insets.i10),
                            ],
                          );
                        }).toList(),
                      ),

                    // ── Platform fees ─────────────────────────────────────
                    BillRowCommon(
                            title: translations!.platformFees,
                            color: appColor(context).online,
                            price: symbolPosition
                                ? "+${getSymbol(context)}${(currency(context).currencyVal * (value.checkoutModel!.total?.platformFees ?? 0)).toStringAsFixed(2)}"
                                : "+${(currency(context).currencyVal * (value.checkoutModel!.total?.platformFees ?? 0)).toStringAsFixed(2)}${getSymbol(context)}")
                        .paddingOnly(bottom: Insets.i10),

                    // ── Coupon discount ───────────────────────────────────
                    if ((value.checkoutModel!.total?.couponTotalDiscount ?? 0) > 0)
                      BillRowCommon(
                              title: translations!.coupons,
                              color: appColor(context).red,
                              price: symbolPosition
                                  ? "-${getSymbol(context)}${(currency(context).currencyVal * value.checkoutModel!.total!.couponTotalDiscount!).toStringAsFixed(2)}"
                                  : "-${(currency(context).currencyVal * value.checkoutModel!.total!.couponTotalDiscount!).toStringAsFixed(2)}${getSymbol(context)}")
                          .paddingOnly(bottom: Insets.i10),
                  ]),

                  // ── Grand total ───────────────────────────────────────
                  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        Text(language(context, translations!.totalAmount),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        Text(
                            symbolPosition
                                ? "${getSymbol(context)}${(currency(context).currencyVal * (value.checkoutModel!.total?.total ?? 0)).toStringAsFixed(2)}"
                                : "${(currency(context).currencyVal * (value.checkoutModel!.total?.total ?? 0)).toStringAsFixed(2)}${getSymbol(context)}",
                            style: appCss.dmDenseBold16
                                .textColor(appColor(context).primary))
                      ])
                      .paddingSymmetric(horizontal: Insets.i15)
                      .paddingOnly(bottom: Insets.i5, top: Insets.i10)
                ]))
        : Container();
  }
}
