import 'dart:developer';

import '../../../config.dart';

class CartScreen extends StatefulWidget {
  final bool? isBottomBar;
  const CartScreen({super.key, this.isBottomBar = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final cartCtrl = Provider.of<CartProvider>(context, listen: false);
      // Reset so button never shows stale data — always wait for fresh checkout
      cartCtrl.checkoutModel = null;
      cartCtrl.checkoutFailed = false;
      if (cartCtrl.cartList.isNotEmpty) {
        cartCtrl.checkout(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context1, value, child) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      log("cart model data is --------> ${value.cartList}");
      return /*value.widget1Opacity == 0.0
          ? const CartShimmer()
          :*/
          PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          final serviceCtrl =
              Provider.of<ServicesDetailsProvider>(context, listen: false);
          serviceCtrl.clearAdditionalServices();
          // Defer navigation until navigator is no longer locked from the pop
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
              return const Dashboard();
            }));
          });
        },
        child: Stack(
          children: [
            Scaffold(
                appBar: AppBar(
                    leadingWidth: 80,
                    title: Text(
                        language(context,
                            "${language(context, translations!.myCart)}${value.cartList.isEmpty ? "" : " (${value.cartList.length})"}"),
                        style: appCss.dmDenseBold18
                            .textColor(appColor(context).darkText)),
                    centerTitle: true,
                    leading: CommonArrow(
                            arrow: rtl(context)
                                ? eSvgAssets.arrowRight
                                : eSvgAssets.arrowLeft,
                            onTap: () => value.onBack(context, true))
                        .paddingAll(Insets.i8),
                    actions: [
                      if (value.cartList.isNotEmpty)
                        CommonArrow(
                                arrow: eSvgAssets.add,
                                onTap: () => route.pushNamed(
                                    context, routeName.dashboard))
                            .paddingSymmetric(horizontal: Insets.i20)
                    ]),
                body: value.cartList.isEmpty
                    ? EmptyLayout(
                        widget: Image.asset(eImageAssets.emptyCart,
                            height: Sizes.s380),
                        title: translations!.oopsNothingAdd,
                        subtitle: translations!.thereIsNothingInBasket,
                        buttonText: translations!.goToService,
                        bTap: () => value.addServiceEmptyTap(context),
                      )
                    : Stack(
                        children: [
                          SingleChildScrollView(
                              controller: value.scrollController,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          ...value.cartList.asMap().entries.map(
                                              (e) => CartLayout(
                                                  data: e.value,
                                                  infoTap: () => value.addOns(
                                                      context,
                                                      data:
                                                          e.value.serviceList),
                                                  editTap: () {
                                                    log("editTap:::${e.value} //// ${e.key}");
                                                    value.editCart(e.value,
                                                        context, e.key);
                                                  },
                                                  deleteTap: () {
                                                    log("deleteTap:::");
                                                    value
                                                        .deleteCartConfirmation(
                                                            context,
                                                            this,
                                                            e.key);
                                                  })),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  language(
                                                      context,
                                                      value.data == null
                                                          ? translations!
                                                              .applyCoupon
                                                          : translations!
                                                              .appliedDiscount),
                                                  style: appCss.dmDenseMedium14
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText)),
                                              Text(
                                                      language(
                                                          context,
                                                          translations!
                                                              .viewAll),
                                                      style: appCss
                                                          .dmDenseRegular14
                                                          .textColor(
                                                              appColor(context)
                                                                  .primary))
                                                  .inkWell(
                                                      onTap: () => route
                                                          .pushNamed(
                                                              context,
                                                              routeName
                                                                  .couponListScreen)
                                                          .then((values) =>
                                                              value.onCode(
                                                                  context,
                                                                  values)))
                                            ],
                                          ),
                                          const VSpace(Sizes.s10),
                                          const DiscountCouponLayout(),
                                          if (value.data != null)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const VSpace(Sizes.s10),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SvgPicture.asset(
                                                        eSvgAssets.offerFill,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                appColor(
                                                                        context)
                                                                    .greenColor,
                                                                BlendMode
                                                                    .srcIn)),
                                                    const HSpace(Sizes.s5),
                                                    if (value.checkoutModel !=
                                                        null)
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "${language(context, translations!.hurry)} ",
                                                                    style: appCss
                                                                        .dmDenseSemiBold13 /* dmDenseMedium14 */
                                                                        .textColor(
                                                                            appColor(context).greenColor),
                                                                    children: [
                                                                  TextSpan(
                                                                      text: symbolPosition
                                                                          ? "${getSymbol(context)}${(currency(context).currencyVal * value.checkoutModel!.total!.couponTotalDiscount!).toStringAsFixed(2)}"
                                                                          : "${(currency(context).currencyVal * value.checkoutModel!.total!.couponTotalDiscount!).toStringAsFixed(2)}${getSymbol(context)}",
                                                                      style: appCss
                                                                          .dmDenseblack13
                                                                          .textColor(
                                                                              appColor(context).greenColor)),
                                                                  TextSpan(
                                                                      text:
                                                                          " ${language(context, translations!.withCode)}",
                                                                      style: appCss
                                                                          .dmDenseSemiBold12
                                                                          .textColor(
                                                                              appColor(context).greenColor))
                                                                ])),
                                                            const VSpace(
                                                                Sizes.s2),
                                                            Text(
                                                                "(${language(context, translations!.couponDesc)})",
                                                                style: appCss
                                                                    .dmDenseMedium14
                                                                    .textColor(appColor(
                                                                            context)
                                                                        .greenColor))
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          const VSpace(Sizes.s25),
                                          Consumer<CommonApiProvider>(
                                              builder: (context1, api, child) {
                                            return BillSummaryLayout(
                                                balance: userModel?.wallet !=
                                                        null
                                                    ? symbolPosition
                                                        ? "${getSymbol(context)}${(currency(context).currencyVal * double.parse(userModel!.wallet!.balance.toString())).toStringAsFixed(2)}"
                                                        : "${(currency(context).currencyVal * double.parse(userModel!.wallet!.balance.toString())).toStringAsFixed(2)}${getSymbol(context)}"
                                                    : "0");
                                          }),
                                          const VSpace(Sizes.s10),
                                          if (value.checkoutModel != null)
                                            const BillLayout(),
                                          const VSpace(Sizes.s10),
                                          const DottedLines().paddingSymmetric(
                                              vertical: Insets.i15),
                                          Text(
                                                  language(context,
                                                      translations!.disclaimer),
                                                  style: appCss
                                                      .dmDenseSemiBold12
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText))
                                              .paddingOnly(bottom: Insets.i8),
                                          Text(
                                              language(context,
                                                  translations!.onceYouClick),
                                              style: appCss.dmDenseMedium12
                                                  .textColor(
                                                      appColor(context).red))
                                        ])
                                        .paddingSymmetric(
                                            horizontal: Insets.i20)
                                        .marginOnly(top: 20),
                                    const VSpace(Sizes.s50),
                                  ]).marginOnly(bottom: Insets.i100)),
                          if (value.checkoutModel != null)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: CartBottomLayout(
                                amount: symbolPosition
                                    ? "${getSymbol(context)}${(currency(context).currencyVal * value.checkoutModel!.total!.total!).toStringAsFixed(2)}"
                                    : "${(currency(context).currencyVal * value.checkoutModel!.total!.total!).toStringAsFixed(2)}${getSymbol(context)}",
                                onTap: () => value.onPaymentTap(
                                    context) /* route.pushNamed(
                                          context, routeName.paymentScreen,
                                          arg: {
                                            "checkoutBody": value.checkoutBody,
                                            "checkoutModel": value.checkoutModel
                                          }) */
                                ,
                              ).padding(
                                  bottom: widget.isBottomBar == true
                                      ? Sizes.s75
                                      : 0),
                            )
                        ],
                      ).height(MediaQuery.of(context).size.height)),
            if (value.isLoading)
              // if (value.isDeleteLoader)
              Container(
                width: screenWidth,
                height: screenHeight,
                color: appColor(context).darkText.withOpacity(0.2),
                child: Center(
                    child: Image.asset(
                  eGifAssets.loader,
                  height: Sizes.s100,
                )),
              )
          ],
        ),
      );
    });
  }
}
