import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/cartListBottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'widgets/checkoutBillDetailsCard.dart';
import 'widgets/checkoutDateSelector.dart';
import 'widgets/checkoutServicesCard.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    required this.companyName,
    required this.providerAdvanceBookingDays,
    required this.providerName,
    required this.providerId,
    final Key? key,
    required this.isFrom,
    this.orderID,
    this.customJobRequestId,
    this.bidder,
    this.cartFromProvider,
    this.cartId,
  }) : super(key: key);

  final String providerName;
  final String isFrom;
  final String providerId;
  final String companyName;
  final String providerAdvanceBookingDays;
  final String? orderID;
  final String? customJobRequestId;
  final BidProvider? bidder;
  final bool? cartFromProvider;
  final String? cartId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => Builder(
        builder: (final context) => MultiBlocProvider(
          providers: [
            BlocProvider<PlaceOrderCubit>(
              create: (final BuildContext context) =>
                  PlaceOrderCubit(cartRepository: CartRepository()),
            ),
            BlocProvider(
              create: (context) =>
                  AddTransactionCubit(bookingRepository: BookingRepository()),
            ),
            BlocProvider<ValidateCustomTimeCubit>(
              create: (context) =>
                  ValidateCustomTimeCubit(cartRepository: CartRepository()),
            ),
            BlocProvider<CheckProviderAvailabilityCubit>(
              create: (final BuildContext context) =>
                  CheckProviderAvailabilityCubit(
                    providerRepository: ProviderRepository(),
                  ),
            ),
            BlocProvider<RequestAreaCoverageCubit>(
              create: (final BuildContext context) => RequestAreaCoverageCubit(
                providerRepository: ProviderRepository(),
              ),
            ),
            BlocProvider<ValidatePromocodeCubit>(
              create: (final BuildContext context) =>
                  ValidatePromocodeCubit(cartRepository: CartRepository()),
            ),
          ],
          child: CheckoutScreen(
            orderID: arguments["orderID"],
            customJobRequestId: arguments["customJobRequestId"],
            companyName: arguments["companyName"] ?? '',
            isFrom: arguments["isFrom"] ?? '',
            providerName: arguments['providerName'] ?? '',
            providerId: arguments['providerId'] ?? '',
            providerAdvanceBookingDays:
                arguments['providerAdvanceBookingDays'] ?? '',
            bidder: arguments['bidder'],
            cartFromProvider: arguments['cartFromProvider'] ?? false,
            cartId: arguments['cartId'],
          ),
        ),
      ),
    );
  }
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ValueNotifier<bool> isPaymentProcessing = ValueNotifier<bool>(false);

  PaymentGatewaysSettings? paymentGatewaySetting;
  String? placedOrderId;
  StreamSubscription? _cartSubscription;
  int? selectedAddressIndex;
  GetAddressModel? selectedAddress;
  String? _lastCheckedProviderAvailabilityKey;

  /// Address id the custom job's get_cart pricing was last requested for ('' =
  /// none, priced from coordinates), so a changed address triggers a reprice.
  String? _customJobPricedFor;
  final ValueNotifier<bool> _isLocationUnavailableAtDoorstep =
      ValueNotifier<bool>(false);
  dynamic selectedDate, selectedTime;
  String? message;
  Promocode? appliedPromocode;
  double promoCodeDiscount = 0;
  bool isBillDetailsExpanded = true;

  // Billing: same as the service address unless the user picks another saved
  // address (always required for at-store bookings).
  bool _billingSameAsService = true;
  GetAddressModel? _billingAddress;
  late List<Map<String, dynamic>> enabledPaymentMethods = context
      .read<SystemSettingCubit>()
      .getEnabledPaymentMethods(
        isOnlinePaymentAllowed: widget.isFrom != "customJobRequest"
            ? context.read<CartCubit>().isOnlinePaymentAllowed(
                isFrom: widget.isFrom,
              )
            : context.read<SystemSettingCubit>().isOnlinePaymentAllowedGlobally,
        isPayLaterAllowed: widget.isFrom != "customJobRequest"
            ? context.read<CartCubit>().isPayLaterAllowed(isFrom: widget.isFrom)
            : context.read<SystemSettingCubit>().isPayLaterAllowedGlobally,
      );

  ValueNotifier<String> paymentButtonName = ValueNotifier('');

  String? selectedPaymentMethod;
  final TextEditingController _instructionController = TextEditingController();

  final List<Map<String, String>> deliverableOptions = [
    {
      "title": 'atHome',
      "description": 'atHomeDescription',
      "image": AppAssets.homeAdd,
    },
    {
      "title": 'atStore',
      "description": 'atStoreDescription',
      "image": AppAssets.storeOutline,
    },
  ];
  late String selectedDeliverableOption = deliverableOptions[0]['title']!;
  final GlobalKey _deliverablePillKey = GlobalKey();

  //----------------------------------- Razorpay Payment Gateway Start ----------------------------
  final Razorpay _razorpay = Razorpay();

  //----------------------------------- Cashfree Payment Gateway Start ----------------------------
  final CFPaymentGatewayService _cfPaymentGatewayService =
      CFPaymentGatewayService();

  void initializeCashfree() {
    _cfPaymentGatewayService.setCallback(
      _handleCashfreePaymentSuccess,
      _handleCashfreePaymentError,
    );
  }

  Future<void> _handleCashfreePaymentSuccess(String cfOrderId) async {
    final CashfreeOrderStatus status = await CartRepository()
        .getCashfreeOrderStatus(orderId: cfOrderId);
    _navigateToOrderConfirmation(
      isSuccess: status == CashfreeOrderStatus.paid,
      isPending: status == CashfreeOrderStatus.pending,
    );
  }

  void _handleCashfreePaymentError(
    CFErrorResponse errorResponse,
    String cfOrderId,
  ) {
    _navigateToOrderConfirmation(isSuccess: false);
  }

  Future<void> openCashfreePaymentGateway({
    required final double orderAmount,
    required final String localOrderId,
    required final String cashfreePaymentSessionId,
    required final String cashfreeOrderId,
  }) async {
    try {
      ClarityService.logAction(
        ClarityActions.paymentGatewayRedirected,
        _buildCartAnalyticsPayload(
          paymentMethod: 'cashfree',
          paymentAmount: orderAmount.toString(),
        ),
      );
      ClarityService.setTag('payment_gateway', 'cashfree');

      if (cashfreePaymentSessionId.isEmpty) {
        UiUtils.showMessage(
          context,
          'onlinePaymentNotAvailableNow'.translate(context: context),
          ToastificationType.warning,
        );
        return;
      }

      final CFEnvironment cfEnvironment =
          (paymentGatewaySetting?.cashfreeEnvironment ?? '').toLowerCase() ==
              'production'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final CFSession session = CFSessionBuilder()
          .setEnvironment(cfEnvironment)
          .setOrderId(
            cashfreeOrderId.isNotEmpty ? cashfreeOrderId : localOrderId,
          )
          .setPaymentSessionId(cashfreePaymentSessionId)
          .build();

      final cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      _cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      UiUtils.showMessage(context, e.message, ToastificationType.error);
      _navigateToOrderConfirmation(isSuccess: false);
    } catch (e) {
      UiUtils.showMessage(
        context,
        'paymentFailure'.translate(context: context),
        ToastificationType.error,
      );
      _navigateToOrderConfirmation(isSuccess: false);
    }
  }

  //----------------------------------- Cashfree Payment Gateway End ----------------------------

  void initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
  }

  void _handleRazorPayPaymentSuccess(final PaymentSuccessResponse response) {
    _navigateToOrderConfirmation(isSuccess: true);
  }

  void _handleRazorPayPaymentError(final PaymentFailureResponse response) {
    _navigateToOrderConfirmation(isSuccess: false);
  }

  void _handleRazorPayExternalWallet(final ExternalWalletResponse response) {}

  Future<void> openRazorPayGateway({
    required final double orderAmount,
    required final String placedOrderId,
    required final String razorpayOrderId,
  }) async {
    ClarityService.logAction(
      ClarityActions.paymentGatewayRedirected,
      _buildCartAnalyticsPayload(
        paymentMethod: 'razorpay',
        paymentAmount: orderAmount.toString(),
      ),
    );
    ClarityService.setTag('payment_gateway', 'razorpay');
    final options = <String, Object?>{
      'key': paymentGatewaySetting!.razorpayKey,
      //this should be come from server
      'amount': (orderAmount * 100).toInt(),
      'name': appName,
      'description': '',
      'currency': paymentGatewaySetting!.razorpayCurrency,
      'notes': {'order_id': placedOrderId},
      'order_id': razorpayOrderId,
    };

    _razorpay.open(options);
  }

  //----------------------------------- Razorpay Payment Gateway End ----------------------------

  //----------------------------------- Stripe Payment Gateway Start ----------------------------

  Future<void> openStripePaymentGateway({
    required final double orderAmount,
    required final String placedOrderId,
  }) async {
    try {
      //to disable back button
      isPaymentProcessing.value = true;
      ClarityService.logAction(
        ClarityActions.paymentGatewayRedirected,
        _buildCartAnalyticsPayload(
          paymentMethod: 'stripe',
          paymentAmount: orderAmount.toString(),
        ),
      );
      ClarityService.setTag('payment_gateway', 'stripe');
      StripeService.init(
        paymentGatewaySetting!.stripePublishableKey,
        paymentGatewaySetting!.stripeMode,
      );

      final response = await StripeService.payWithPaymentSheet(
        orderId: placedOrderId,
      );
      //to enable back button
      isPaymentProcessing.value = false;

      if (response.status == 'succeeded') {
        _navigateToOrderConfirmation(isSuccess: true);
      } else if (response.status == 'cancelled') {
        _handleStripeSheetDismissed();
      } else {
        // Surface Stripe's / the backend's actual reason; the confirmation
        // screen only shows a generic "booking failed".
        final String reason = response.message ?? '';
        if (mounted && reason.isNotEmpty && response.status != 'cancelled') {
          UiUtils.showMessage(context, reason, ToastificationType.error);
        }
        _navigateToOrderConfirmation(isSuccess: false);
      }
    } catch (e) {
      isPaymentProcessing.value = false;
      if (!mounted) return;
      UiUtils.showMessage(context, e.toString(), ToastificationType.error);
    }
  }

  /// The customer closed the Stripe sheet without paying. That is not a
  /// failure, so stay on checkout instead of showing the failure screen.
  ///
  /// The booking placed for this attempt is still released server-side
  /// (`add_transaction` → cancelled), exactly as before; for online payments the
  /// cart is only cleared after a successful payment, so it is intact and the
  /// next tap simply places a fresh booking — with Stripe or another method.
  void _handleStripeSheetDismissed() {
    ClarityService.logAction(
      ClarityActions.paymentFailed,
      _buildCartAnalyticsPayload(
        paymentMethod: selectedPaymentMethod,
        paymentAmount: _currentCartTotalAmount(),
      )..['result'] = 'dismissed',
    );
    if (placedOrderId != null) {
      context.read<AddTransactionCubit>().addTransaction(
        status: "cancelled",
        orderID: placedOrderId!,
      );
    }
    placedOrderId = null;
    if (!mounted) return;
    const String key = 'paymentNotCompleted';
    final String translated = key.translate(context: context);
    UiUtils.showMessage(
      context,
      translated == key
          ? "Payment wasn't completed. You can try again or choose another payment method."
          : translated,
      ToastificationType.info,
    );
  }

  //----------------------------------- Stripe Payment Gateway End ----------------------------

  void _navigateToOrderConfirmation({
    required final bool isSuccess,
    final bool isPending = false,
  }) {
    if (!isSuccess) {
      final payload = _buildCartAnalyticsPayload(
        paymentMethod: selectedPaymentMethod,
        paymentAmount: _currentCartTotalAmount(),
      );
      payload['result'] = isPending ? 'pending' : 'failure';
      ClarityService.logAction(
        isPending
            ? ClarityActions.paymentPending
            : ClarityActions.paymentFailed,
        payload,
      );
      paymentButtonName.value = "rePayment";
      context.read<AddTransactionCubit>().addTransaction(
        status: isPending ? "pending" : "cancelled",
        orderID: placedOrderId ?? "0",
      );
      context.read<BookingCubit>().fetchAllBookings(status: '');
      Navigator.pushNamed(
        context,
        orderConfirmation,
        arguments: {
          'isSuccess': false,
          'isPending': isPending,
          "orderId": placedOrderId,
          "isReBooking": widget.isFrom == "reBooking" ? '1' : '0',
          if (widget.isFrom == "customJobRequest")
            "customJobRequestId": widget.customJobRequestId,
        },
      );
      return;
    }
    final payload = _buildCartAnalyticsPayload(
      paymentMethod: selectedPaymentMethod,
      paymentAmount: _currentCartTotalAmount(),
    );
    payload['result'] = 'success';
    ClarityService.logAction(ClarityActions.paymentSucceeded, payload);
    Navigator.pushNamed(
      context,
      orderConfirmation,
      arguments: {
        'isSuccess': isSuccess,
        "orderId": placedOrderId,
        "isReBooking": widget.isFrom == "reBooking" ? '1' : '0',
        if (widget.isFrom == "customJobRequest")
          "customJobRequestId": widget.customJobRequestId,
      },
    );
  }

  void getPaymentGatewaySetting() {
    paymentGatewaySetting = context
        .read<SystemSettingCubit>()
        .paymentGatewaysSettings;

    if (widget.isFrom != "customJobRequest" &&
        context.read<CartCubit>().isOnlinePaymentAllowed(
          isFrom: widget.isFrom,
        )) {
      paymentButtonName = ValueNotifier("makePayment");
    } else if (widget.isFrom == "customJobRequest" &&
        context.read<SystemSettingCubit>().isOnlinePaymentAllowedGlobally) {
      paymentButtonName = ValueNotifier("makePayment");
    } else {
      paymentButtonName = ValueNotifier("bookService");
    }
  }

  void getMyRequests() {
    if (widget.isFrom == "customJobRequest") {
      final MyRequestCartCubit myRequestCartCubit = context
          .read<MyRequestCartCubit>();
      myRequestCartCubit.emitSuccess(widget.bidder ?? BidProvider.empty());
      _syncSelectedDeliverableOption(
        atStoreAvailable: myRequestCartCubit.checkAtStoreProviderAvailable(
          isFrom: widget.isFrom,
        ),
        atDoorstepAvailable: myRequestCartCubit
            .checkAtDoorstepProviderAvailable(isFrom: widget.isFrom),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getMyRequests();
    context.read<GetAddressCubit>().fetchAddress();
    getPaymentGatewaySetting();
    initializeRazorpay();
    initializeCashfree();
    if (widget.isFrom != "customJobRequest") {
      final CartCubit cartCubit = context.read<CartCubit>();
      final bool isReorderCart = widget.isFrom == "reBooking";
      final bool cartAlreadyLoaded =
          !isReorderCart &&
          cartCubit.state is CartFetchSuccess &&
          ((cartCubit.state as CartFetchSuccess).cartData.carId?.isNotEmpty ??
              false);

      final bool selectedLocally =
          cartAlreadyLoaded &&
          (widget.isFrom != "cart" ||
              widget.cartId == null ||
              cartCubit.selectPrimaryCart(widget.cartId!));

      if (!selectedLocally) {
        cartCubit.getCartDetails(
          isReorderCart: isReorderCart,
          reOrderId: widget.orderID,
          preferredCartId: widget.isFrom == "cart" ? widget.cartId : null,
        );
      } else if (cartCubit.state is CartFetchSuccess) {
        _syncSelectedDeliverableOption(
          atStoreAvailable: cartCubit.checkAtStoreProviderAvailable(
            isFrom: widget.isFrom,
          ),
          atDoorstepAvailable: cartCubit.checkAtDoorstepProviderAvailable(
            isFrom: widget.isFrom,
          ),
        );
      }
    }
    if (widget.isFrom == "customJobRequest") {
      getMyRequests();
      _refreshCustomJobPricing();
    }
    if (widget.isFrom != "customJobRequest" && widget.providerId != "0") {
      context.read<GetAllPromocodesCubit>().getAllPromocodes(
        providerIdOrSlug: widget.providerId,
      );
    }

    if (widget.isFrom != "customJobRequest" &&
        context.read<CartCubit>().isOnlinePaymentAllowed(
          isFrom: widget.isFrom,
        )) {
      selectedPaymentMethod = enabledPaymentMethods[0]['paymentType'];
    } else if (widget.isFrom == "customJobRequest" &&
        context.read<SystemSettingCubit>().isOnlinePaymentAllowedGlobally) {
      selectedPaymentMethod = enabledPaymentMethods[0]['paymentType'];
    } else {
      selectedPaymentMethod = "cod";
    }

    //listning to the state changes of place order cubit to disable the back button
    context.read<PlaceOrderCubit>().stream.listen((state) {
      isPaymentProcessing.value = state is PlaceOrderInProgress;
    });
  }

  Widget getHeadingTimeSelector() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: CustomText(
      'scheduleTime'.translate(context: context),
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: context.colors.textPrimary,
    ),
  );

  Widget verticalSpacing() {
    return const CustomSizedBox(height: 10);
  }

  Map<String, Object?> _buildCartAnalyticsPayload({
    String? paymentMethod,
    String? paymentAmount,
  }) {
    final Map<String, Object?> data = {
      'source': widget.isFrom,
      'provider_id': widget.providerId,
      'provider_name': widget.providerName,
      'company_name': widget.companyName,
      'delivery_type': selectedDeliverableOption,
      'selected_date': selectedDate ?? '',
      'selected_time': selectedTime ?? '',
      'custom_job_request_id': widget.customJobRequestId ?? '',
      'payment_method': paymentMethod,
      'payment_amount': paymentAmount,
      'promo_code_name': appliedPromocode?.promoCode ?? '',
    };

    if (widget.isFrom == 'customJobRequest') {
      final myRequestState = context.read<MyRequestCartCubit>().state;
      if (myRequestState is MyRequestCartSuccess) {
        final bidder = myRequestState.bidderData;
        data.addAll({
          'partner_id': bidder.providerId.toString(),
          'partner_name': bidder.translatedProviderName ?? bidder.companyName,
          'bidder_price': bidder.counterPrice,
          'final_total': bidder.finalTotal ?? bidder.counterPrice,
        });
      }
    } else {
      final cartState = context.read<CartCubit>().state;
      if (cartState is CartFetchSuccess) {
        final cart = cartState.cartData;
        final serviceNames =
            cart.cartDetails
                ?.map(
                  (detail) =>
                      detail.serviceDetails?.translatedTitle ??
                      detail.serviceDetails?.title ??
                      '',
                )
                .where((name) => name.isNotEmpty)
                .toList() ??
            <String>[];
        data.addAll({
          'cart_provider_id': cart.providerId ?? '',
          'cart_provider_name':
              cart.translatedProviderName ?? cart.providerName ?? '',
          'services': serviceNames.join('|'),
          'service_count': serviceNames.length,
          'total_quantity': cart.totalQuantity ?? '',
          'subtotal': cart.subTotal ?? '',
          'overall_amount': cart.overallAmount ?? '',
          'promo_code_name':
              cart.appliedPromoCodeName ?? appliedPromocode?.promoCode ?? '',
          'promo_discount': cart.promoCodeDiscountAmount ?? '',
        });
      }
    }

    data.removeWhere(
      (key, value) =>
          value == null ||
          (value is String && value.isEmpty) ||
          (value is num && value == 0),
    );
    return data;
  }

  String _currentCartTotalAmount() {
    final bool isAtStore = selectedDeliverableOption == "atStore";
    if (widget.isFrom == 'customJobRequest') {
      return context.read<MyRequestCartCubit>().getCartTotalAmount(
        isAtStoreBooked: isAtStore,
        isFrom: widget.isFrom,
      );
    }
    return context.read<CartCubit>().getCartTotalAmount(
      isAtStoreBooked: isAtStore,
      isFrom: widget.isFrom,
    );
  }

  Widget _buildViewProviderInstructionField({final bool fullWidth = false}) =>
      CustomContainer(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: fullWidth
            ? context.colors.backgroundPrimary
            : context.colors.backgroundSecondary,
        border: fullWidth
            ? null
            : Border.all(color: context.colors.borderDefault),
        borderRadius: 12,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            CustomSvgPicture(
              svgImage: AppAssets.edit,
              color: context.colors.iconPrimary,
              height: 16,
              width: 16,
              avoideResponsive: true,
            ),
            const CustomSizedBox(width: 8),
            CustomText(
              'writeInstruction'.translate(context: context),
              color: context.colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ],
        ),
      );

  Widget _buildFilledProviderInstructionField(final String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'providerInstruction'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
              const CustomSizedBox(height: 4),
              CustomText(
                text,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ],
          ),
        ),
        const CustomSizedBox(width: 8),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(24),
          onTap: _openProviderInstructionBottomSheet,
          child: CustomContainer(
            padding: const EdgeInsets.all(8),
            color: context.colors.backgroundSecondary,
            borderRadius: 24,
            child: CustomSvgPicture(
              svgImage: AppAssets.edit,
              color: context.colors.iconPrimary,
              height: 20,
              width: 20,
              avoideResponsive: true,
            ),
          ),
        ),
      ],
    ),
  );

  void _openProviderInstructionBottomSheet() {
    UiUtils.showBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      child: ProviderInstructionBottomSheet(
        initialInstruction: _instructionController.text,
      ),
    ).then((final Object? value) {
      if (value is String) {
        _instructionController.text = value;
      }
    });
  }

  /// `provider_id` for the availability check. The API only wants it for a
  /// plain cart checkout, to pick which of the customer's carts to check —
  /// reorders are resolved from `order_id` and custom requests from
  /// `bidder_id`. The cart flow uses "0" when no single provider is known.
  String? get _availabilityProviderId {
    if (widget.isFrom == "customJobRequest") return null;
    if ((widget.orderID ?? '').isNotEmpty) return null;
    final String id = widget.providerId;
    return id.isEmpty || id == "0" ? null : id;
  }

  void _checkProviderAvailabilityForSelectedAddress() {
    if (selectedAddress == null ||
        selectedDeliverableOption != deliverableOptions[0]["title"]) {
      return;
    }

    final bool isCartDataReady = widget.isFrom == "customJobRequest"
        ? context.read<MyRequestCartCubit>().state is MyRequestCartSuccess
        : context.read<CartCubit>().state is CartFetchSuccess;
    if (!isCartDataReady) return;

    final String key = '${selectedAddress!.id}|$selectedDeliverableOption';
    if (_lastCheckedProviderAvailabilityKey == key) return;
    _lastCheckedProviderAvailabilityKey = key;

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (!mounted) return;

      final String latitude = selectedAddress?.lattitude.toString() ?? '';
      final String longitude = selectedAddress?.longitude.toString() ?? '';

      if (context.read<MyRequestCartCubit>().checkAtDoorstepProviderAvailable(
        isFrom: widget.isFrom,
      )) {
        context
            .read<CheckProviderAvailabilityCubit>()
            .checkProviderAvailability(
              customJobRequestId: widget.bidder?.customJobRequestId,
              bidderId: widget.bidder?.providerId.toString(),
              isAuthTokenRequired: true,
              checkingAtCheckOut: '1',
              providerId: _availabilityProviderId,
              latitude: latitude,
              longitude: longitude,
            );
      } else if (widget.isFrom != "customJobRequest" &&
          context.read<CartCubit>().checkAtDoorstepProviderAvailable(
            isFrom: widget.isFrom,
          )) {
        context
            .read<CheckProviderAvailabilityCubit>()
            .checkProviderAvailability(
              orderId: widget.orderID,
              isAuthTokenRequired: true,
              checkingAtCheckOut: '1',
              providerId: _availabilityProviderId,
              latitude: latitude,
              longitude: longitude,
            );
      }
    });
  }

  Widget buildServiceLocationValue({
    required final String value,
    required final VoidCallback onTap,
    final String? labelKey,
  }) => CustomInkWellContainer(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          (labelKey ?? 'serviceLocation').translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textSecondary,
        ),
        const CustomSizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CustomText(
                value,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                color: context.colors.textPrimary,
              ),
            ),
            const CustomSizedBox(width: 4),
            CustomSvgPicture(
              svgImage: AppAssets.downArrow,
              height: 16,
              width: 16,
              color: context.colors.iconPrimary,
              avoideResponsive: true,
            ),
          ],
        ),
      ],
    ),
  );

  /// Billing address under the service location. Doorstep: a "same as service
  /// location" tick and, when unticked, a picker styled like the service
  /// location value. At-store there is no service address to match, so the
  /// picker is shown directly.
  Widget _buildBillingLocation({final bool withTopGap = true}) {
    final GetAddressModel? billing = _effectiveBillingAddress;
    return Padding(
      padding: EdgeInsets.only(top: withTopGap ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isAtStore)
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CustomCheckBox(
                    value: _billingSameAsService,
                    onChanged: (final bool? v) =>
                        setState(() => _billingSameAsService = v ?? true),
                  ),
                ),
                const CustomSizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    'billingSameAsServiceAddress'.translate(context: context),
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          if (_isBillingSeparate) ...[
            if (!_isAtStore) const CustomSizedBox(height: 8),
            buildServiceLocationValue(
              labelKey: 'billingAddress',
              value: billing == null
                  ? 'selectBillingAddress'.translate(context: context)
                  : [
                      billing.regionAndCountry,
                      billing.mobile,
                    ].where((final p) => (p ?? '').isNotEmpty).join(' · '),
              onTap: _pickBillingAddress,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildAddressSelector() {
    return BlocListener<AddAddressCubit, AddAddressState>(
      listener:
          (final BuildContext context, final AddAddressState addAddressState) {
            if (addAddressState is AddAddressFail) {
              UiUtils.showMessage(
                context,
                addAddressState.error.toString(),
                ToastificationType.error,
              );
            }
          },
      child: BlocConsumer<GetAddressCubit, GetAddressState>(
        listener:
            (
              final BuildContext context,
              final GetAddressState getAddressState,
            ) {
              if (getAddressState is GetAddressSuccess) {
                for (var i = 0; i < getAddressState.data.length; i++) {
                  if (getAddressState.data[i].isDefault == "1") {
                    selectedAddressIndex = i;
                    selectedAddress = getAddressState.data[i];
                    _syncActiveAddress();
                    setState(() {});
                  }
                }
                context.read<AddressesCubit>().load(getAddressState.data);
              }
            },
        builder:
            (
              final BuildContext context,
              final GetAddressState getAddressState,
            ) {
              if (getAddressState is GetAddressSuccess) {
                if (getAddressState.data.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        'noServiceAddressAdded'.translate(context: context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                      const CustomSizedBox(height: 4),
                      CustomInkWellContainer(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            googleMapRoute,
                            arguments: {
                              "defaultLatitude": HiveRepository.getLatitude,
                              "defaultLongitude": HiveRepository.getLongitude,
                              'showAddressForm': true,
                              'screenType':
                                  GoogleMapScreenType.selectLocationOnMap,
                            },
                          ).then((final Object? value) {
                            if (!context.mounted) return;
                            context.read<GetAddressCubit>().fetchAddress();
                            setState(() {});
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSvgPicture(
                              svgImage: AppAssets.plus,
                              height: 16,
                              width: 16,
                              color: context.colors.iconBrand,
                              avoideResponsive: true,
                            ),
                            const CustomSizedBox(width: 4),
                            CustomText(
                              'addAddress'.translate(context: context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textBrand,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  if (selectedAddress == null) {
                    selectedAddress = getAddressState.data.firstWhere(
                      (e) => e.isDefault == '1',
                      orElse: () => getAddressState.data.first,
                    );
                    _syncActiveAddress();
                  }
                  _checkProviderAvailabilityForSelectedAddress();

                  return BlocListener<AddAddressCubit, AddAddressState>(
                    listener: (context, state) {},
                    child: buildServiceLocationValue(
                      value: selectedAddress?.address?.toString() ?? '',
                      onTap: () {
                        UiUtils.showBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          useSafeArea: true,
                          child: AddressBottomSheet(
                            addresses: getAddressState.data,
                            defaultAddress: selectedAddress!,
                          ),
                          context: context,
                        ).then((final value) {
                          if (!context.mounted) return;
                          if (value != null &&
                              value['selectedAddress'] != null) {
                            selectedAddress = value['selectedAddress'];
                            _syncActiveAddress();
                            context
                                .read<CheckProviderAvailabilityCubit>()
                                .reset();
                            _isLocationUnavailableAtDoorstep.value = false;
                            _checkProviderAvailabilityForSelectedAddress();
                            // Tax and the promo depend on the address; after
                            // the availability check, which needs a loaded cart.
                            _syncPromoToCart();
                            setState(() {});
                          }
                        });
                      },
                    ),
                  );
                }
              }
              if (getAddressState is GetAddressInProgress) {
                return const CustomShimmerLoadingContainer(
                  height: 36,
                  width: double.infinity,
                );
              }
              return const CustomSizedBox();
            },
      ),
    );
  }

  Widget _deliverableOptionRow(final int index) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomSvgPicture(
        svgImage: deliverableOptions[index]['image']!,
        height: 20,
        width: 20,
        color: selectedDeliverableOption == deliverableOptions[index]['title']
            ? context.colors.iconPrimary
            : context.colors.iconSecondary,
      ),
      const CustomSizedBox(width: 8),
      CustomText(
        deliverableOptions[index]['title']!.translate(context: context),
        fontSize: 14,
        color: selectedDeliverableOption == deliverableOptions[index]['title']
            ? context.colors.textPrimary
            : context.colors.textSecondary,
      ),
      if (selectedDeliverableOption == deliverableOptions[index]['title']) ...[
        const CustomSizedBox(width: 12),
        CustomSvgPicture(
          svgImage: AppAssets.checkCircleFill,
          height: 20,
          width: 20,
          color: context.colors.iconBrand,
          avoideResponsive: true,
        ),
      ],
    ],
  );

  void _showDeliverableOptionsMenu() {
    UiUtils.removeFocus();
    final RenderBox? button =
        _deliverablePillKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    if (button == null) {
      return;
    }
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          Offset(0, button.size.height + 8),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(const Offset(0, 8)),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: context.colors.surfacePrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      constraints: const BoxConstraints(minWidth: 162),
      items: [
        for (int i = 0; i < deliverableOptions.length; i++) ...[
          if (i > 0)
            PopupMenuItem<String>(
              enabled: false,
              height: 1,
              padding: EdgeInsets.zero,
              child: Container(height: 1, color: context.colors.borderDefault),
            ),
          PopupMenuItem<String>(
            value: deliverableOptions[i]['title'],
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: _deliverableOptionRow(i),
            ),
          ),
        ],
      ],
    ).then((final String? value) {
      if (value != null) {
        selectedDeliverableOption = value;
        _syncActiveAddress();
        _checkProviderAvailabilityForSelectedAddress();
        setState(() {});
      }
    });
  }

  Widget buildDeliverableOptionPill() => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(8),
    onTap: _showDeliverableOptionsMenu,
    child: CustomContainer(
      key: _deliverablePillKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: context.colors.backgroundSecondary,
      border: Border.all(color: context.colors.borderDefault),
      borderRadius: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            selectedDeliverableOption.translate(context: context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(width: 6),
          CustomSvgPicture(
            svgImage: AppAssets.downArrow,
            height: 14,
            width: 14,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ],
      ),
    ),
  );

  Widget buildServiceLocationSection({
    required final bool showAddress,
    required final bool showDeliverableOptions,
    final String? providerAddress,
    final double? providerLatitude,
    final double? providerLongitude,
  }) {
    if (!showAddress && !showDeliverableOptions) {
      // At-store only provider: no location row or toggle, just billing.
      return CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: context.colors.surfacePrimary,
        child: _buildBillingLocation(withTopGap: false),
      );
    }
    final bool canOpenProviderLocation =
        providerLatitude != null && providerLongitude != null;
    void openProviderLocationSheet() {
      if (!canOpenProviderLocation) return;
      UiUtils.showBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        child: ProviderLocationBottomSheet(
          providerAddress: providerAddress ?? '',
          providerLatitude: providerLatitude,
          providerLongitude: providerLongitude,
        ),
      );
    }

    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colors.surfacePrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: showAddress
                    ? buildAddressSelector()
                    : CustomInkWellContainer(
                        onTap: canOpenProviderLocation
                            ? openProviderLocationSheet
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              'providerLocation'.translate(context: context),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: context.colors.textSecondary,
                            ),
                            const CustomSizedBox(height: 4),
                            CustomText(
                              (providerAddress ?? '').isNotEmpty
                                  ? providerAddress!
                                  : 'atStore'.translate(context: context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              maxLines: 1,
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                      ),
              ),
              if (showDeliverableOptions) ...[
                const CustomSizedBox(width: 12),
                buildDeliverableOptionPill(),
              ],
            ],
          ),
          _buildBillingLocation(),
        ],
      ),
    );
  }

  Widget buildAddMoreAndInstructionPills(final String? providerId) => Row(
    children: [
      if (widget.isFrom == "cart") ...[
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (widget.cartFromProvider == true) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                providerRoute,
                arguments: {"providerId": providerId},
              );
            }
          },
          child: CustomContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: context.colors.backgroundSecondary,
            border: Border.all(color: context.colors.borderDefault),
            borderRadius: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.plus,
                  height: 16,
                  width: 16,
                  color: context.colors.iconPrimary,
                  avoideResponsive: true,
                ),
                const CustomSizedBox(width: 8),
                CustomText(
                  'addMoreItem'.translate(context: context),
                  color: context.colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),
        const CustomSizedBox(width: 8),
      ],
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _instructionController,
        builder: (context, value, child) => value.text.trim().isNotEmpty
            ? const CustomSizedBox()
            : GestureDetector(
                onTap: _openProviderInstructionBottomSheet,
                child: _buildViewProviderInstructionField(),
              ),
      ),
    ],
  );

  String _promoDiscountLabel(final Promocode promo) {
    final String currency = context.read<SystemSettingCubit>().systemCurrency;
    return '${promo.discount ?? ''}'
        '${promo.discountType == "percentage" ? '%' : ' $currency'} '
        '${'off'.translate(context: context)}';
  }

  String _promoMinOrderLabel(final Promocode promo) =>
      "${'onMinimumServiceOf'.translate(context: context)} "
      "${(promo.minimumOrderAmount ?? '0').priceFormat(context)}";

  Widget _buildOfferRow({
    required final String discountLabel,
    required final String subtitleLabel,
    required final String buttonLabel,
    required final Color buttonColor,
    required final VoidCallback? onButtonTap,
    final bool isLoading = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const CustomSvgPicture(
        svgImage: AppAssets.verified,
        height: 24,
        width: 24,
        avoideResponsive: true,
      ),
      const CustomSizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              discountLabel,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
            CustomText(
              subtitleLabel,
              fontSize: 12,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
      const CustomSizedBox(width: 8),
      CustomInkWellContainer(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
        onTap: onButtonTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: isLoading
              ? CustomSizedBox(
                  height: 16,
                  width: 16,
                  child: CustomCircularProgressIndicator(color: buttonColor),
                )
              : CustomText(buttonLabel, fontSize: 14, color: buttonColor),
        ),
      ),
    ],
  );

  Widget _buildSuggestedPromoRow() =>
      BlocBuilder<GetAllPromocodesCubit, GetAllPromocodesState>(
        builder:
            (
              final BuildContext context,
              final GetAllPromocodesState promoState,
            ) {
              final Promocode? suggested =
                  promoState is GetAllPromocodesFetchSuccess &&
                      promoState.promocodeList.isNotEmpty
                  ? promoState.promocodeList.first
                  : null;

              if (suggested == null) {
                return CustomText(
                  "applyCouponAndGetExtraDiscount".translate(context: context),
                  fontSize: 12,
                  color: context.colors.textSecondary,
                );
              }

              return BlocConsumer<
                ValidatePromocodeCubit,
                ValidatePromoCodeState
              >(
                listener:
                    (
                      final BuildContext context,
                      final ValidatePromoCodeState validateState,
                    ) {
                      if (validateState is ValidatePromoCodeSuccess &&
                          validateState.promoCodeId == suggested.id) {
                        if (!validateState.error) {
                          promoCodeDiscount =
                              double.tryParse(validateState.discountAmount) ??
                              0;
                          appliedPromocode = suggested;
                          setState(() {});
                          _syncPromoToCart();
                        } else {
                          UiUtils.showMessage(
                            context,
                            validateState.message,
                            ToastificationType.error,
                          );
                        }
                      } else if (validateState is ValidatePromoCodeFailure) {
                        UiUtils.showMessage(
                          context,
                          validateState.errorMessage,
                          ToastificationType.error,
                        );
                      }
                    },
                builder:
                    (
                      final BuildContext context,
                      final ValidatePromoCodeState validateState,
                    ) {
                      final bool isApplying =
                          validateState is ValidatePromoCodeInProgress &&
                          validateState.promoCodeID == suggested.id;
                      return _buildOfferRow(
                        discountLabel: _promoDiscountLabel(suggested),
                        subtitleLabel: _promoMinOrderLabel(suggested),
                        buttonLabel: 'apply'.translate(context: context),
                        buttonColor: context.colors.textBrand,
                        isLoading: isApplying,
                        onButtonTap: isApplying
                            ? null
                            : () {
                                context
                                    .read<ValidatePromocodeCubit>()
                                    .validatePromoCodes(
                                      totalAmount: context
                                          .read<CartCubit>()
                                          .getCartSubTotalAmount(
                                            isFrom: widget.isFrom,
                                            isAtStoreBooked:
                                                selectedDeliverableOption ==
                                                "atStore",
                                          ),
                                      promoCodeID: suggested.id!,
                                      providerId: widget.providerId,
                                    );
                              },
                      );
                    },
              );
            },
      );

  BoxDecoration selectedItemBorderStyle() => BoxDecoration(
    boxShadow: [BoxShadow(color: context.colors.borderDefault, blurRadius: 3)],
    border: Border.all(color: context.colors.textPrimary),
    color: context.colors.surfaceElevated,
    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
  );

  BoxDecoration normalBoxDecoration() => BoxDecoration(
    color: context.colors.surfaceElevated,
    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
  );

  void _syncSelectedDeliverableOption({
    required final bool atStoreAvailable,
    required final bool atDoorstepAvailable,
  }) {
    final bool currentSelectionStillValid =
        (selectedDeliverableOption == deliverableOptions[1]['title'] &&
            atStoreAvailable) ||
        (selectedDeliverableOption == deliverableOptions[0]['title'] &&
            atDoorstepAvailable);
    if (!currentSelectionStillValid) {
      selectedDeliverableOption = atDoorstepAvailable
          ? deliverableOptions[0]['title']!
          : deliverableOptions[1]['title']!;
    }
  }

  bool get _isAtStore => selectedDeliverableOption == "atStore";

  /// At-store has no service address to match, so billing is always picked
  /// separately there; doorstep follows the "same as service" tick.
  bool get _isBillingSeparate => _isAtStore || !_billingSameAsService;

  /// Billing address to send. Always sent, at-store or doorstep: the picked
  /// billing address when it differs, otherwise the customer's selected
  /// address (doorstep "same as service").
  GetAddressModel? get _effectiveBillingAddress =>
      _isBillingSeparate ? _billingAddress : selectedAddress;

  /// Doorstep with "same as service location" ticked; at-store billing is
  /// always a separate address.
  bool get _billingSameAsShippingFlag => !_isAtStore && !_isBillingSeparate;

  /// Opens the address form in billing mode (country, region, address custom
  /// fields, mobile) — nothing is saved to the account, the result is only
  /// used for this order.
  void _pickBillingAddress() {
    final GetAddressModel? current = _billingAddress;
    UiUtils.showBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      child: BlocProvider(
        create: (_) => GetCustomFieldsCubit()..fetchCustomFields(),
        child: CustomContainer(
          padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: AddressSheet(
            isBilling: true,
            addressDataModel: AddressModel(
              mobile:
                  current?.mobile ?? '${HiveRepository.getUserMobileNumber}',
              type: current?.type ?? '',
              countryId: current?.countryId,
              regionId: current?.regionId,
            ),
          ),
        ),
      ),
    ).then((final value) {
      if (!mounted || value is! GetAddressModel) return;
      setState(() => _billingAddress = value);
    });
  }

  void placeOrder() {
    if (_isBillingSeparate && _effectiveBillingAddress == null) {
      UiUtils.showMessage(
        context,
        'billingAddressRequired'.translate(context: context),
        ToastificationType.warning,
      );
      return;
    }
    ClarityService.logAction(
      ClarityActions.cartCheckoutTapped,
      _buildCartAnalyticsPayload(
        paymentMethod: selectedPaymentMethod,
        paymentAmount: _currentCartTotalAmount(),
      ),
    );
    context.read<PlaceOrderCubit>().placeOrder(
      status: "awaiting",
      orderId: widget.orderID ?? '',
      customJobRequestId: widget.customJobRequestId ?? '',
      bidderId: widget.providerId,
      // this is partner id which we will get from bidder
      selectedAddressID: selectedAddress?.id,
      promoCodeId: appliedPromocode?.id ?? '',
      paymentMethod: selectedPaymentMethod!,
      orderNote: _instructionController.text.trim().toString(),
      dateOfService: selectedDate!,
      startingTime: selectedTime!,
      isAtStoreOptionSelected: selectedDeliverableOption == "atStore"
          ? "1"
          : "0",
      cartId: context.read<CartCubit>().getCartId(isFrom: widget.isFrom),
      billingAddress: _effectiveBillingAddress,
      billingSameAsShipping: _billingSameAsShippingFlag,
    );
  }

  Widget buildPaymentMethodsList({final VoidCallback? onSelected}) =>
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: enabledPaymentMethods.length,
        separatorBuilder: (final context, final index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: CustomSizedBox(
            height: 1,
            width: double.infinity,
            child: DashedRect(
              color: context.colors.borderDefault,
              strokeWidth: 1,
              gap: 4,
            ),
          ),
        ),
        itemBuilder: (context, index) {
          final Map<String, dynamic> paymentMethod =
              enabledPaymentMethods[index];
          return CustomRadioOptionsWidget(
            image: paymentMethod["image"] ?? '',
            title: paymentMethod["title"] ?? '',
            value: paymentMethod["paymentType"] ?? '',
            groupValue: selectedPaymentMethod ?? '',
            applyAccentColor: false,
            onChanged: (final Object? selectedValue) {
              selectedPaymentMethod = selectedValue.toString();
              paymentButtonName.value = selectedValue.toString() == "cod"
                  ? "bookService"
                  : "makePayment";
              setState(() {});
              onSelected?.call();
            },
          );
        },
      );

  bool computeShowPaymentOptions(final bool isCustomJobRequest) {
    final bool isPayLaterAllowed = isCustomJobRequest
        ? context.read<SystemSettingCubit>().isPayLaterAllowedGlobally
        : context.read<CartCubit>().isPayLaterAllowed(isFrom: widget.isFrom) &&
              context.read<SystemSettingCubit>().isPayLaterAllowedGlobally;

    final bool isOnlinePaymentAllowed = isCustomJobRequest
        ? context.read<SystemSettingCubit>().isOnlinePaymentAllowedGlobally
        : context.read<CartCubit>().isOnlinePaymentAllowed(
            isFrom: widget.isFrom,
          );

    final bool isMoreThanOnePaymentGatewayEnabled = context
        .read<SystemSettingCubit>()
        .isMoreThanOnePaymentGatewayEnabled();

    return (isCustomJobRequest &&
            isPayLaterAllowed &&
            isOnlinePaymentAllowed) ||
        (isCustomJobRequest &&
            isOnlinePaymentAllowed &&
            isMoreThanOnePaymentGatewayEnabled) ||
        (!isCustomJobRequest && isPayLaterAllowed && isOnlinePaymentAllowed) ||
        (!isCustomJobRequest &&
            isOnlinePaymentAllowed &&
            isMoreThanOnePaymentGatewayEnabled);
  }

  Widget buildPayUsingPill() {
    final Map<String, dynamic> current = enabledPaymentMethods.firstWhere(
      (final m) => m["paymentType"] == selectedPaymentMethod,
      orElse: () =>
          enabledPaymentMethods.isNotEmpty ? enabledPaymentMethods.first : {},
    );
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        UiUtils.removeFocus();
        UiUtils.showBottomSheet(
          context: context,
          enableDrag: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const CustomSizedBox(height: 16),
                CustomText(
                  'selectPayment'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 16),
                Divider(height: 1, color: context.colors.borderDefault),
                const CustomSizedBox(height: 16),
                buildPaymentMethodsList(
                  onSelected: () => Navigator.pop(context),
                ),
                CustomSizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'payUsing'.translate(context: context),
            fontSize: 11,
            color: context.colors.textSecondary,
          ),
          const CustomSizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((current["image"] ?? '').toString().isNotEmpty) ...[
                CustomContainer(
                  borderRadius: 4,
                  child: CustomSvgPicture(
                    svgImage: current["image"].toString(),
                    height: 18,
                    width: 18,
                  ),
                ),
                const CustomSizedBox(width: 4),
              ],
              CustomText(
                (current["title"] ?? '').toString().translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                color: context.colors.textPrimary,
              ),
              CustomSvgPicture(
                svgImage: AppAssets.downArrow,
                height: 20,
                width: 20,
                color: context.colors.iconSecondary,
                avoideResponsive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _computeOnlinePaymentAmount() => widget.isFrom == 'customJobRequest'
      ? double.parse(
          context.read<MyRequestCartCubit>().getCartTotalAmount(
            isFrom: widget.isFrom,
            isAtStoreBooked: selectedDeliverableOption == "atStore",
          ),
        )
      : double.parse(
              context.read<CartCubit>().getCartTotalAmount(
                isFrom: widget.isFrom,
                isAtStoreBooked: selectedDeliverableOption == "atStore",
              ),
            ) -
            (_cartHasBackendPromo || (_cartPromoError ?? '').isNotEmpty
                ? 0
                : promoCodeDiscount);

  /// Cart calls resolve country/tax from `address_id`, which is only right for
  /// a doorstep booking. At-store the service is at the provider, so a saved
  /// address in another country must not filter the cart (it came back empty
  /// for a cart whose services are in a different country).
  void _syncActiveAddress() {
    CartRepository.activeAddressId = _isAtStore ? null : selectedAddress?.id;
    if (widget.isFrom == "customJobRequest" &&
        (CartRepository.activeAddressId ?? '') != _customJobPricedFor) {
      _refreshCustomJobPricing();
    }
  }

  /// Custom job tax, fees and visiting charge come from get_cart for the
  /// picked address, not from the bid's stored estimate.
  void _refreshCustomJobPricing() {
    final BidProvider? bidder = widget.bidder;
    if (bidder == null) return;
    _customJobPricedFor = CartRepository.activeAddressId ?? '';
    context.read<MyRequestCartCubit>().loadPricing(bidder);
  }

  void _syncPromoToCart() {
    CartRepository.activePromoCodeId = appliedPromocode?.id;
    if (widget.isFrom != 'cart') return;
    // Silent: the promo only reprices the cart, the screen must not reload.
    context.read<CartCubit>().getCartDetails(
      isReorderCart: false,
      preferredCartId: widget.cartId,
      silent: true,
    );
  }

  Cart? get _currentCart {
    final CartState cartState = context.read<CartCubit>().state;
    if (cartState is! CartFetchSuccess) return null;
    return widget.isFrom == 'cart'
        ? cartState.cartData
        : cartState.reOrderCartData;
  }

  bool get _cartHasBackendPromo => _currentCart?.hasBackendPromo ?? false;

  /// Why the backend left the applied promo out of the cart price, if it did.
  String? get _cartPromoError => _currentCart?.promoError;

  Widget _buildPromoErrorText() => BlocBuilder<CartCubit, CartState>(
    builder: (final BuildContext context, final CartState state) {
      final String error = state is CartFetchSuccess
          ? ((widget.isFrom == 'cart' ? state.cartData : state.reOrderCartData)
                    ?.promoError ??
                '')
          : '';
      if (error.isEmpty) return const CustomSizedBox();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: CustomText(error, fontSize: 12, color: context.colors.textError),
      );
    },
  );

  Widget continueButtonContainer(final BuildContext context) {
    final bool isCartDataReady = widget.isFrom == "customJobRequest"
        ? context.watch<MyRequestCartCubit>().state is MyRequestCartSuccess
        : context.watch<CartCubit>().state is CartFetchSuccess;

    if (!isCartDataReady) {
      return CustomContainer(
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 2),
            color: context.colors.overlayFooterShadow,
          ),
        ],
        color: context.colors.surfacePrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: CustomShimmerLoadingContainer(
          height: 48,
          width: context.screenWidth,
          borderRadius: UiUtils.borderRadiusOf12,
        ),
      );
    }

    return BlocConsumer<PlaceOrderCubit, PlaceOrderState>(
      listener: (context, placeOrderState) {
        if (placeOrderState is PlaceOrderSuccess) {
          if (!placeOrderState.isError) {
            placedOrderId = placeOrderState.orderId;

            final double cartTotalAmount = _computeOnlinePaymentAmount();

            if (selectedPaymentMethod == "cod") {
              _navigateToOrderConfirmation(isSuccess: true);
            } else {
              ClarityService.logAction(
                ClarityActions.paymentStarted,
                _buildCartAnalyticsPayload(
                  paymentMethod: selectedPaymentMethod,
                  paymentAmount: cartTotalAmount.toString(),
                ),
              );
              ClarityService.setTag(
                'payment_method',
                selectedPaymentMethod ?? '',
              );
              if (selectedPaymentMethod == 'stripe') {
                openStripePaymentGateway(
                  orderAmount: cartTotalAmount,
                  placedOrderId: placeOrderState.orderId,
                );
              } else if (selectedPaymentMethod == 'razorpay') {
                openRazorPayGateway(
                  orderAmount: cartTotalAmount,
                  placedOrderId: placeOrderState.orderId,
                  razorpayOrderId: placeOrderState.razorpayOrderId,
                );
              } else if (selectedPaymentMethod == 'paystack') {
                _openWebviewPaymentGateway(
                  webviewLink: placeOrderState.paystackLink,
                );
              } else if (selectedPaymentMethod == 'flutterwave') {
                _openWebviewPaymentGateway(
                  webviewLink: placeOrderState.flutterwaveLink,
                );
              } else if (selectedPaymentMethod == 'paypal') {
                _openWebviewPaymentGateway(
                  webviewLink: placeOrderState.paypalLink,
                );
              } else if (selectedPaymentMethod == 'xendit') {
                _openWebviewPaymentGateway(
                  webviewLink: placeOrderState.xenditLink,
                );
              } else if (selectedPaymentMethod == 'cashfree') {
                openCashfreePaymentGateway(
                  orderAmount: cartTotalAmount,
                  localOrderId: placeOrderState.orderId,
                  cashfreePaymentSessionId:
                      placeOrderState.cashfreePaymentSessionId,
                  cashfreeOrderId: placeOrderState.cashfreeOrderId,
                );
              } else {
                UiUtils.showMessage(
                  context,
                  'onlinePaymentNotAvailableNow'.translate(context: context),
                  ToastificationType.warning,
                );
              }
            }
          } else {
            UiUtils.showMessage(
              context,
              placeOrderState.message.translate(context: context),
              ToastificationType.error,
            );
          }
        }
        if (placeOrderState is PlaceOrderFailure) {
          UiUtils.showMessage(
            context,
            placeOrderState.errorMessage.translate(context: context),
            ToastificationType.error,
          );
        }
      },
      builder: (context, state) {
        return BlocConsumer<
          CheckProviderAvailabilityCubit,
          CheckProviderAvailabilityState
        >(
          listener:
              (
                final context,
                CheckProviderAvailabilityState checkProviderAvailabilityState,
              ) {
                if (checkProviderAvailabilityState
                    is CheckProviderAvailabilityFetchSuccess) {
                  _isLocationUnavailableAtDoorstep.value =
                      checkProviderAvailabilityState.error;
                  if (checkProviderAvailabilityState.error) {
                    UiUtils.showMessage(
                      context,
                      'serviceNotAvailableAtSelectedAddress'.translate(
                        context: context,
                      ),
                      ToastificationType.warning,
                    );
                  } else if (selectedDate != null && selectedTime != null) {
                    context.read<ValidateCustomTimeCubit>().validateCustomTime(
                      providerId: widget.providerId,
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      orderId: widget.orderID,
                      customJobRequestId: widget.customJobRequestId,
                    );
                  }
                } else if (checkProviderAvailabilityState
                    is CheckProviderAvailabilityFetchFailure) {
                  _isLocationUnavailableAtDoorstep.value = true;
                  UiUtils.showMessage(
                    context,
                    checkProviderAvailabilityState.errorMessage,
                    ToastificationType.error,
                  );
                }
              },
          builder:
              (
                final context,
                CheckProviderAvailabilityState checkProviderAvailabilityState,
              ) {
                return BlocConsumer<
                  ValidateCustomTimeCubit,
                  ValidateCustomTimeState
                >(
                  listener:
                      (
                        final BuildContext context,
                        final ValidateCustomTimeState validateCustomTimeState,
                      ) {
                        if (validateCustomTimeState
                            is ValidateCustomTimeSuccess) {
                          if (!validateCustomTimeState.error) {
                            placeOrder();
                          } else {
                            UiUtils.showMessage(
                              context,
                              validateCustomTimeState.message,
                              ToastificationType.error,
                            );
                          }
                        } else if (validateCustomTimeState
                            is ValidateCustomTimeFailure) {
                          UiUtils.showMessage(
                            context,
                            validateCustomTimeState.errorMessage,
                            ToastificationType.error,
                          );
                        }
                      },
                  builder:
                      (
                        final BuildContext context,
                        final ValidateCustomTimeState validateCustomTimeState,
                      ) {
                        final bool isCustomJobRequest =
                            widget.isFrom == "customJobRequest";
                        final bool showPaymentOptionsPill =
                            computeShowPaymentOptions(isCustomJobRequest) &&
                            enabledPaymentMethods.isNotEmpty;
                        return CustomContainer(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              offset: const Offset(0, 2),
                              color: context.colors.overlayFooterShadow,
                            ),
                          ],
                          color: context.colors.surfacePrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: paymentButtonName,
                            builder: (context, value, _) {
                              final Widget payButton = CustomRoundedButton(
                                onTap: () {
                                  if (validateCustomTimeState
                                          is ValidateCustomTimeInProgress ||
                                      checkProviderAvailabilityState
                                          is CheckProviderAvailabilityFetchInProgress) {
                                    return;
                                  }

                                  if (selectedTime == null ||
                                      selectedDate == null) {
                                    UiUtils.showMessage(
                                      context,
                                      'pleaseSelectDateAndTime'.translate(
                                        context: context,
                                      ),
                                      ToastificationType.warning,
                                    );
                                    return;
                                  }

                                  if (context
                                          .read<MyRequestCartCubit>()
                                          .checkAtDoorstepProviderAvailable(
                                            isFrom: widget.isFrom,
                                          ) &&
                                      selectedDeliverableOption ==
                                          deliverableOptions[0]["title"]) {
                                    if (selectedAddress == null) {
                                      UiUtils.showMessage(
                                        context,
                                        'pleaseSelectAddress'.translate(
                                          context: context,
                                        ),
                                        ToastificationType.warning,
                                      );
                                    } else {
                                      context
                                          .read<
                                            CheckProviderAvailabilityCubit
                                          >()
                                          .checkProviderAvailability(
                                            customJobRequestId: widget
                                                .bidder
                                                ?.customJobRequestId,
                                            bidderId: widget.bidder?.providerId
                                                .toString(),
                                            isAuthTokenRequired: true,
                                            checkingAtCheckOut: '1',
                                            providerId: _availabilityProviderId,
                                            latitude:
                                                selectedAddress?.lattitude
                                                    .toString() ??
                                                '',
                                            longitude:
                                                selectedAddress?.longitude
                                                    .toString() ??
                                                '',
                                          );
                                    }
                                  } else if (widget.isFrom !=
                                          "customJobRequest" &&
                                      context
                                          .read<CartCubit>()
                                          .checkAtDoorstepProviderAvailable(
                                            isFrom: widget.isFrom,
                                          ) &&
                                      selectedDeliverableOption ==
                                          deliverableOptions[0]["title"]) {
                                    if (selectedAddress == null) {
                                      UiUtils.showMessage(
                                        context,
                                        'pleaseSelectAddress'.translate(
                                          context: context,
                                        ),
                                        ToastificationType.warning,
                                      );
                                    } else {
                                      context
                                          .read<
                                            CheckProviderAvailabilityCubit
                                          >()
                                          .checkProviderAvailability(
                                            orderId: widget.orderID,
                                            isAuthTokenRequired: true,
                                            checkingAtCheckOut: '1',
                                            providerId: _availabilityProviderId,
                                            latitude:
                                                selectedAddress?.lattitude
                                                    .toString() ??
                                                '',
                                            longitude:
                                                selectedAddress?.longitude
                                                    .toString() ??
                                                '',
                                          );
                                    }
                                  } else {
                                    placeOrder();
                                  }
                                },
                                widthPercentage: 1,
                                backgroundColor: context.colors.backgroundBrand,
                                buttonTitle: selectedPaymentMethod == "cod"
                                    ? 'bookService'.translate(context: context)
                                    : '${'pay'.translate(context: context)} ${_computeOnlinePaymentAmount().toStringAsFixed(2).countryPriceFormat(context)}',
                                showBorder: false,
                                radius: UiUtils.borderRadiusOf12,
                                textSize: 16,
                                fontWeight: FontWeight.w500,
                                child:
                                    state is PlaceOrderInProgress ||
                                        checkProviderAvailabilityState
                                            is CheckProviderAvailabilityFetchInProgress ||
                                        validateCustomTimeState
                                            is ValidateCustomTimeInProgress
                                    ? Center(
                                        child: CustomCircularProgressIndicator(
                                          color:
                                              context.colors.textInverseLight,
                                        ),
                                      )
                                    : null,
                              );
                              if (!showPaymentOptionsPill) return payButton;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  buildPayUsingPill(),
                                  const CustomSizedBox(width: 12),
                                  Expanded(child: payButton),
                                ],
                              );
                            },
                          ),
                        );
                      },
                );
              },
        );
      },
    );
  }

  Widget getTitle({required String title}) {
    return CustomText(
      title.translate(context: context),
      fontSize: 16,
      color: context.colors.textPrimary,
      fontWeight: FontWeight.bold,
    );
  }

  int currentServiceCount(final CartState cartState) {
    if (widget.isFrom == "customJobRequest") return 1;
    if (cartState is CartFetchSuccess) {
      final List<CartDetails>? details = widget.isFrom == "cart"
          ? cartState.cartData.cartDetails
          : cartState.reOrderCartData?.cartDetails;
      if (details == null) return 0;
      final Set<String> distinctServiceIds = details
          .map((final d) => d.serviceId)
          .whereType<String>()
          .where((final id) => id.isNotEmpty)
          .toSet();
      return distinctServiceIds.isNotEmpty
          ? distinctServiceIds.length
          : details.length;
    }
    return 0;
  }

  Widget buildAppBarSubtitle(
    final BuildContext context, {
    required final int serviceCount,
    required final String amount,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomText(
        '$serviceCount ${(serviceCount > 1 ? "services" : "service").translate(context: context)}',
        fontSize: 12,
        color: context.colors.textSecondary,
      ),
      const CustomSizedBox(width: 6),
      CustomContainer(
        height: 4,
        width: 4,
        shape: BoxShape.circle,
        color: context.colors.textTertiary,
      ),
      const CustomSizedBox(width: 6),
      CustomText(amount, fontSize: 12, color: context.colors.textSecondary),
    ],
  );

  Widget buildCheckoutAppBarTitle(final bool isCustomJobRequest) {
    Widget titleColumn(final int serviceCount, final String amount) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          widget.companyName.isNotEmpty
              ? widget.companyName
              : widget.providerName,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          color: context.colors.textPrimary,
        ),
        const CustomSizedBox(height: 2),
        buildAppBarSubtitle(
          context,
          serviceCount: serviceCount,
          amount: amount,
        ),
      ],
    );

    if (isCustomJobRequest) {
      return BlocBuilder<MyRequestCartCubit, MyRequestCartState>(
        builder: (context, state) => titleColumn(
          1,
          state is MyRequestCartSuccess
              ? state.pricing != null
                    ? _currentCartTotalAmount().countryPriceFormat(context)
                    : _currentCartTotalAmount().priceFormat(context)
              : '',
        ),
      );
    }
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) => titleColumn(
        currentServiceCount(state),
        state is CartFetchSuccess
            ? _currentCartTotalAmount().countryPriceFormat(context)
            : '',
      ),
    );
  }

  bool _hasMultipleProviderCarts(final CartState cartState) =>
      cartState is CartFetchSuccess &&
      (cartState.cartData.otherCarts?.any(
            (final c) => c.cartDetails?.isNotEmpty ?? false,
          ) ??
          false);

  void _onProviderAvatarTap() {
    final CartState cartState = context.read<CartCubit>().state;
    final bool hasMultipleProviderCarts = _hasMultipleProviderCarts(cartState);

    if (widget.isFrom == "cart" && hasMultipleProviderCarts) {
      Navigator.pop(context);
      final BuildContext rootContext = UiUtils.rootNavigatorKey.currentContext!;
      UiUtils.showBottomSheet(
        context: rootContext,
        enableDrag: true,
        child: const CartListBottomSheet(),
      ).then((final value) {
        if (!rootContext.mounted) return;
        if (value is Map) {
          Navigator.of(rootContext).pushNamed(
            scheduleScreenRoute,
            arguments: {
              "isFrom": "cart",
              "providerName": value["providerName"] ?? '',
              "providerId": value["providerId"] ?? "0",
              "companyName": value["companyName"] ?? '',
              "providerAdvanceBookingDays": value["providerAdvanceBookingDays"],
              "cartId": value["cartId"] ?? '',
            },
          );
        }
      });
      return;
    }

    Navigator.pushNamed(
      context,
      providerRoute,
      arguments: {"providerId": widget.providerId},
    );
  }

  Widget buildProviderAvatarAction() {
    final bool hasMultipleProviderCarts = _hasMultipleProviderCarts(
      context.watch<CartCubit>().state,
    );
    if (!hasMultipleProviderCarts) return const CustomSizedBox();

    final bool canOpenProvider =
        widget.providerId.isNotEmpty && widget.providerId != "0";
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: CustomInkWellContainer(
        borderRadius: BorderRadius.circular(20),
        onTap: canOpenProvider ? _onProviderAvatarTap : null,
        child: CustomContainer(
          padding: const EdgeInsets.all(8),
          color: context.colors.surfacePrimary,
          borderRadius: 24,
          child: CustomSvgPicture(
            svgImage: AppAssets.userSwitch,
            height: 24,
            width: 24,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isCustomJobRequest = widget.isFrom == "customJobRequest";

    return ValueListenableBuilder(
      valueListenable: isPaymentProcessing,
      builder: (context, paymentProcessing, child) {
        return PopScope(
          canPop: !paymentProcessing,
          child: AnnotatedSafeArea(
            isAnnotated: true,
            applyBottomInset: false,
            child: Theme(
              data: Theme.of(context).copyWith(
                bottomSheetTheme: Theme.of(context).bottomSheetTheme.copyWith(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                ),
              ),
              child: Scaffold(
                backgroundColor: context.colors.backgroundSecondary,
                appBar: UiUtils.getSimpleAppBar(
                  context: context,
                  titleWidget: buildCheckoutAppBarTitle(isCustomJobRequest),
                  // Pinned stroke under the header; it used to be the top
                  // border of the service location row, which scrolled away.
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1.5),
                    child: Container(
                      height: 1.5,
                      color: context.colors.borderDefault,
                    ),
                  ),
                  actions: [
                    if (widget.isFrom != 'customJobRequest')
                      buildProviderAvatarAction(),
                  ],
                  onLeadingTap: paymentProcessing ? () {} : null,
                ),
                body: isCustomJobRequest
                    ? _buildMainScheduleContent(
                        context: context,
                        isCustomJobRequest: isCustomJobRequest,
                      )
                    : BlocConsumer<CartCubit, CartState>(
                        listener: (context, cartState) {
                          if (cartState is CartFetchSuccess) {
                            enabledPaymentMethods = context
                                .read<SystemSettingCubit>()
                                .getEnabledPaymentMethods(
                                  isOnlinePaymentAllowed: context
                                      .read<CartCubit>()
                                      .isOnlinePaymentAllowed(
                                        isFrom: widget.isFrom,
                                      ),
                                  isPayLaterAllowed: context
                                      .read<CartCubit>()
                                      .isPayLaterAllowed(isFrom: widget.isFrom),
                                );
                            _syncSelectedDeliverableOption(
                              atStoreAvailable: context
                                  .read<CartCubit>()
                                  .checkAtStoreProviderAvailable(
                                    isFrom: widget.isFrom,
                                  ),
                              atDoorstepAvailable: context
                                  .read<CartCubit>()
                                  .checkAtDoorstepProviderAvailable(
                                    isFrom: widget.isFrom,
                                  ),
                            );

                            if (enabledPaymentMethods.isNotEmpty) {
                              // Keep the customer's choice across cart refreshes
                              // (e.g. applying a promo) while it is still offered.
                              final bool stillOffered = enabledPaymentMethods
                                  .any(
                                    (final m) =>
                                        m['paymentType'] ==
                                        selectedPaymentMethod,
                                  );
                              if (!stillOffered) {
                                selectedPaymentMethod =
                                    enabledPaymentMethods[0]['paymentType'];
                              }
                            } else {
                              selectedPaymentMethod = "cod";
                            }
                            _checkProviderAvailabilityForSelectedAddress();
                            setState(() {});
                          }
                        },
                        builder: (context, cartState) {
                          if (cartState is CartFetchInProgress) {
                            return Center(
                              child: CustomCircularProgressIndicator(
                                color: context.colors.textBrand,
                              ),
                            );
                          }
                          if (cartState is CartFetchFailure) {
                            return ErrorContainer(
                              errorMessage: cartState.errorMessage,
                              onTapRetry: () {
                                context.read<CartCubit>().getCartDetails(
                                  isReorderCart: widget.isFrom == "reorder",
                                  reOrderId: widget.orderID,
                                );
                              },
                            );
                          }
                          return _buildMainScheduleContent(
                            context: context,
                            isCustomJobRequest: isCustomJobRequest,
                          );
                        },
                      ),
                bottomSheet: ColoredBox(
                  color: context.colors.surfacePrimary,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: ClipShadowBottom(
                      child: continueButtonContainer(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleBillDetails() =>
      setState(() => isBillDetailsExpanded = !isBillDetailsExpanded);

  void _onDateTimeSaved(
    final String date,
    final dynamic time,
    final String? newMessage,
  ) {
    if (!mounted) return;
    setState(() {
      selectedDate = date;
      selectedTime = time;
      message = newMessage;
    });
  }

  List<Widget> _buildServicesFooter(final String? providerId) => [
    buildAddMoreAndInstructionPills(providerId),
    ValueListenableBuilder<TextEditingValue>(
      valueListenable: _instructionController,
      builder: (context, value, child) => value.text.trim().isEmpty
          ? const CustomSizedBox()
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildFilledProviderInstructionField(value.text),
            ),
    ),
  ];

  Widget _buildMainScheduleContent({
    required BuildContext context,
    required bool isCustomJobRequest,
  }) {
    final bool isAtStoreProviderAvailable = isCustomJobRequest
        ? context.read<MyRequestCartCubit>().checkAtStoreProviderAvailable(
            isFrom: widget.isFrom,
          )
        : context.read<CartCubit>().checkAtStoreProviderAvailable(
            isFrom: widget.isFrom,
          );

    final bool isAtDoorstepProviderAvailable = isCustomJobRequest
        ? context.read<MyRequestCartCubit>().checkAtDoorstepProviderAvailable(
            isFrom: widget.isFrom,
          )
        : context.read<CartCubit>().checkAtDoorstepProviderAvailable(
            isFrom: widget.isFrom,
          );

    final bool showServiceDeliverableOptions =
        isAtStoreProviderAvailable && isAtDoorstepProviderAvailable;

    final bool showAddressSelector =
        selectedDeliverableOption == deliverableOptions[0]["title"] &&
        isAtDoorstepProviderAvailable;

    final CartState cartState = context.read<CartCubit>().state;
    final Cart? cartData = !isCustomJobRequest && cartState is CartFetchSuccess
        ? cartState.cartData
        : null;
    final MyRequestCartState myRequestCartState = context
        .read<MyRequestCartCubit>()
        .state;
    final BidProvider? bidderData =
        isCustomJobRequest && myRequestCartState is MyRequestCartSuccess
        ? myRequestCartState.bidderData
        : null;
    final bool isAtStoreSelected =
        selectedDeliverableOption == deliverableOptions[1]["title"];

    final bool hasCartServices =
        cartData == null || (cartData.cartDetails?.isNotEmpty ?? false);

    final GetAllPromocodesState promoState = context
        .watch<GetAllPromocodesCubit>()
        .state;
    final bool hasPromocodesToShow =
        (promoState is GetAllPromocodesFetchSuccess &&
            promoState.promocodeList.isNotEmpty) ||
        appliedPromocode != null;

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      padding: EdgeInsetsDirectional.only(
        bottom:
            kBottomNavigationBarHeight.rh(context) +
            40.rh(context) +
            MediaQuery.viewPaddingOf(context).bottom,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasCartServices &&
              (showAddressSelector ||
                  showServiceDeliverableOptions ||
                  isAtStoreSelected)) ...[
            buildServiceLocationSection(
              showAddress: showAddressSelector,
              showDeliverableOptions: showServiceDeliverableOptions,
              providerAddress: cartData?.providerAddress,
              providerLatitude: cartData?.providerLatitude,
              providerLongitude: cartData?.providerLongitude,
            ),
          ],
          if (isAtStoreSelected &&
              (isCustomJobRequest
                  ? bidderData?.distance != null &&
                        bidderData?.providerLatitude != null &&
                        bidderData?.providerLongitude != null
                  : cartData?.distance != null &&
                        cartData?.providerLatitude != null &&
                        cartData?.providerLongitude != null))
            ProviderDistanceBanner(
              distanceInKm: isCustomJobRequest
                  ? bidderData!.distance!
                  : cartData!.distance!,
              providerAddress: isCustomJobRequest
                  ? (bidderData?.providerAddress ?? '')
                  : (cartData?.providerAddress ?? ''),
              providerLatitude: isCustomJobRequest
                  ? bidderData!.providerLatitude!
                  : cartData!.providerLatitude!,
              providerLongitude: isCustomJobRequest
                  ? bidderData!.providerLongitude!
                  : cartData!.providerLongitude!,
            ),
          if (selectedDeliverableOption == deliverableOptions[0]["title"])
            ValueListenableBuilder<bool>(
              valueListenable: _isLocationUnavailableAtDoorstep,
              builder: (context, isUnavailable, child) => isUnavailable
                  ? ServiceUnavailableBanner(
                      latitude: selectedAddress?.lattitude.toString() ?? '',
                      longitude: selectedAddress?.longitude.toString() ?? '',
                      address: selectedAddress?.address ?? '',
                    )
                  : const CustomSizedBox(),
            ),

          if (!isCustomJobRequest) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CheckoutServicesCard(
                isFrom: widget.isFrom,
                footerBuilder: _buildServicesFooter,
              ),
            ),
          ],
          if (hasCartServices)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 16.rw(context),
                end: 16.rw(context),
                top: !isCustomJobRequest ? 0.rh(context) : 16.rh(context),
              ),
              child: CheckoutDateSelector(
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                message: message,
                isFrom: widget.isFrom,
                providerId: widget.providerId,
                providerAdvanceBookingDays: widget.providerAdvanceBookingDays,
                orderId: widget.orderID,
                customJobRequestId: widget.customJobRequestId,
                onSaved: _onDateTimeSaved,
              ),
            ),
          if (isCustomJobRequest) ...[
            const CustomSizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _instructionController,
                builder: (context, value, child) => value.text.trim().isEmpty
                    ? GestureDetector(
                        onTap: _openProviderInstructionBottomSheet,
                        child: _buildViewProviderInstructionField(
                          fullWidth: true,
                        ),
                      )
                    : CustomContainer(
                        color: context.colors.backgroundPrimary,
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: _buildFilledProviderInstructionField(value.text),
                      ),
              ),
            ),
          ],
          if (!isCustomJobRequest &&
              hasCartServices &&
              hasPromocodesToShow) ...[
            const CustomSizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainer(
                padding: const EdgeInsets.all(12),
                color: context.colors.surfacePrimary,
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            'offerAndCoupons'.translate(context: context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        CustomInkWellContainer(
                          onTap: () {
                            if (widget.providerId == "0") {
                              UiUtils.showMessage(
                                context,
                                'somethingWentWrong'.translate(
                                  context: context,
                                ),
                                ToastificationType.warning,
                              );
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              promocodeScreen,
                              arguments: {
                                "isFrom": widget.isFrom,
                                "providerID": widget.providerId,
                                "isAtStoreOptionSelected":
                                    selectedDeliverableOption == "atStore"
                                    ? "1"
                                    : "0",
                              },
                            ).then((final Object? value) {
                              if (value != null) {
                                final parameter = value as Map;
                                promoCodeDiscount = double.parse(
                                  parameter["discount"],
                                );
                                appliedPromocode =
                                    parameter["appliedPromocode"];
                                setState(() {});
                                _syncPromoToCart();
                              }
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomText(
                                'viewAll'.translate(context: context),
                                fontSize: 14,
                                color: context.colors.textBrand,
                              ),
                              const CustomSizedBox(width: 4),
                              CustomSvgPicture(
                                svgImage:
                                    Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? AppAssets.backArrow
                                    : AppAssets.backArrowLtr,
                                height: 20,
                                width: 20,
                                color: context.colors.iconBrand,
                                avoideResponsive: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const CustomSizedBox(height: 12),
                    Divider(height: 1, color: context.colors.borderDefault),
                    const CustomSizedBox(height: 12),
                    if (appliedPromocode != null) ...[
                      _buildOfferRow(
                        discountLabel: _promoDiscountLabel(appliedPromocode!),
                        subtitleLabel: _promoMinOrderLabel(appliedPromocode!),
                        buttonLabel: 'remove'.translate(context: context),
                        buttonColor: context.colors.textError,
                        onButtonTap: () {
                          promoCodeDiscount = 0.0;
                          appliedPromocode = null;
                          setState(() {});
                          _syncPromoToCart();
                        },
                      ),
                      _buildPromoErrorText(),
                    ] else
                      _buildSuggestedPromoRow(),
                  ],
                ),
              ),
            ),
          ],
          if (widget.isFrom == "customJobRequest") ...[
            const CustomSizedBox(height: 16),
            BlocBuilder<MyRequestCartCubit, MyRequestCartState>(
              builder: (final BuildContext context, final MyRequestCartState state) {
                if (state is MyRequestCartInProgress) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.iconBrand,
                    ),
                  );
                }
                if (state is MyRequestCartSuccess) {
                  final Cart? pricing = state.pricing;
                  if (pricing != null) {
                    return _buildCustomJobPricedBill(pricing);
                  }
                  final double customFinalTotal =
                      (double.tryParse(
                            state.bidderData.finalTotal ??
                                state.bidderData.counterPrice,
                          ) ??
                          0) +
                      (selectedDeliverableOption != "atStore"
                          ? (double.tryParse(
                                  state.bidderData.visitingCharges ?? "0",
                                ) ??
                                0)
                          : 0);
                  final String customFinalTotalText = customFinalTotal
                      .toStringAsFixed(2)
                      .priceFormat(context);
                  final List<Widget> rows = [
                    ChargesTile(
                      title: 'subTotal'.translate(context: context),
                      value:
                          (context.read<SystemSettingCubit>().showTaxOnCheckout
                                  ? state.bidderData.counterPrice
                                  : state.bidderData.finalTotal ??
                                        state.bidderData.counterPrice)
                              .priceFormat(context),
                      fontSize: 14,
                      fontweight: FontWeight.w400,
                    ),
                    if (context.read<SystemSettingCubit>().showTaxOnCheckout &&
                        (double.tryParse(state.bidderData.taxAmount ?? "0") ??
                                0.0) >
                            0) ...[
                      const CustomSizedBox(height: 8),
                      ChargesTile(
                        title: 'tax'.translate(context: context),
                        value:
                            "+ ${(state.bidderData.taxAmount ?? "0").priceFormat(context)}",
                        fontSize: 14,
                      ),
                    ],
                    if (state.bidderData.visitingCharges != null &&
                        state.bidderData.visitingCharges != '0' &&
                        state.bidderData.visitingCharges != '' &&
                        state.bidderData.visitingCharges != 'null' &&
                        selectedDeliverableOption != "atStore") ...[
                      const CustomSizedBox(height: 8),
                      ChargesTile(
                        title: 'visitingCharge'.translate(context: context),
                        value:
                            '+ ${state.bidderData.visitingCharges!.priceFormat(context)}',
                        fontSize: 14,
                        fontweight: FontWeight.w400,
                      ),
                    ],
                    if (selectedDeliverableOption != "atStore") ...[
                      const CustomSizedBox(height: 8),
                      Divider(height: 1, color: context.colors.borderDefault),
                      const CustomSizedBox(height: 8),
                      ChargesTile(
                        title: 'totalAmount'.translate(context: context),
                        value: customFinalTotalText,
                        fontSize: 16,
                        fontweight: FontWeight.w700,
                        titleColor: context.colors.textPrimary,
                        valueColor: context.colors.textBrand,
                      ),
                    ],
                  ];
                  return CheckoutBillDetailsCard(
                    isExpanded: isBillDetailsExpanded,
                    onToggle: _toggleBillDetails,

                    rows: rows,
                    showSavedBanner: false,
                    savedAmountText: '',
                    finalTotalText: customFinalTotalText,
                  );
                }
                return const CustomSizedBox();
              },
            ),
          ],
          if (widget.isFrom != "customJobRequest") ...[
            const CustomSizedBox(height: 16),
            BlocBuilder<CartCubit, CartState>(
              builder: (final BuildContext context, final CartState state) {
                if (state is CartFetchSuccess) {
                  if (state.cartData.cartDetails == null &&
                      state.reOrderCartData?.cartDetails == null) {
                    return const CustomSizedBox();
                  }
                  final bool showTax = context
                      .read<SystemSettingCubit>()
                      .showTaxOnCheckout;
                  final bool isCart = widget.isFrom == "cart";

                  String getSubTotal() {
                    if (isCart) {
                      if (showTax) {
                        return state.cartData.subTotalWithoutTax ?? "0";
                      }
                      return state.cartData.subTotal ?? "0";
                    } else {
                      if (showTax) {
                        return state.reOrderCartData?.subTotalWithoutTax ?? "0";
                      }
                      return state.reOrderCartData?.subTotal ?? "0";
                    }
                  }

                  final double preDiscountTotal =
                      (isCart ? state.cartData : state.reOrderCartData)
                          ?.payableAmount(
                            atStore: selectedDeliverableOption == "atStore",
                            withPromo: false,
                          ) ??
                      0;
                  final Cart? shownCart = isCart
                      ? state.cartData
                      : state.reOrderCartData;

                  // The backend prices the promo into the cart (`promo`,
                  // `final_total`); with `promo_error` it is priced without it.
                  // Reorder carts are not re-priced, so those keep the amount
                  // from validate_promo_code.
                  final bool promoApplied =
                      shownCart != null &&
                      shownCart.hasBackendPromo &&
                      (shownCart.promoError ?? '').isEmpty;
                  final double localDiscount =
                      promoApplied || (shownCart?.promoError ?? '').isNotEmpty
                      ? 0
                      : promoCodeDiscount;
                  // `promo.discount` comes off the services' price before tax,
                  // so the promo also removes `promo_tax_reduction` of tax.
                  // Shown as two lines; every "saved" label uses their sum.
                  final double promoDiscount = promoApplied
                      ? shownCart.promoDiscount ?? 0
                      : localDiscount;
                  final double promoTaxReduction = promoApplied
                      ? shownCart.promoTaxReduction
                      : 0;
                  final double savedAmount = promoDiscount + promoTaxReduction;
                  final double finalTotal = promoApplied
                      ? shownCart.payableAmount(
                          atStore: selectedDeliverableOption == "atStore",
                        )
                      : preDiscountTotal - localDiscount;
                  final String finalTotalText = finalTotal
                      .toStringAsFixed(2)
                      .countryPriceFormat(context);
                  final String? originalTotalText = savedAmount > 0
                      ? preDiscountTotal
                            .toStringAsFixed(2)
                            .countryPriceFormat(context)
                      : null;
                  final String savedAmountValue = savedAmount
                      .toStringAsFixed(2)
                      .countryPriceFormat(context);
                  final String? savedBadgeText = savedAmount > 0
                      ? '${'saved'.translate(context: context)} $savedAmountValue'
                      : null;

                  final Cart? billCart = isCart
                      ? state.cartData
                      : state.reOrderCartData;

                  final bool useBreakdown =
                      showTax &&
                      billCart?.taxBreakdown != null &&
                      billCart!.taxBreakdown!.groups.isNotEmpty;

                  final bool atStoreSelected =
                      selectedDeliverableOption == "atStore";
                  final String visitingText =
                      (isCart
                          ? state.cartData.visitingCharges
                          : state.reOrderCartData?.visitingCharges) ??
                      '';
                  final double legacyTax =
                      double.tryParse(billCart?.taxValue ?? '0') ?? 0;

                  Widget legacyRow(final String title, final String value) =>
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ChargesTile(
                          title: title,
                          value: value,
                          fontSize: 14,
                          fontweight: FontWeight.w400,
                        ),
                      );

                  final List<Widget> rows = [
                    if (useBreakdown)
                      TaxBreakdownRows(cart: billCart, atStore: atStoreSelected)
                    else ...[
                      ChargesTile(
                        title: 'itemTotal'.translate(context: context),
                        value: getSubTotal().countryPriceFormat(context),
                        fontSize: 14,
                      ),
                      if (showTax && legacyTax > 0)
                        legacyRow(
                          'tax'.translate(context: context),
                          '+ ${legacyTax.toStringAsFixed(2).countryPriceFormat(context)}',
                        ),
                      for (final Fees fee in billCart?.fees ?? const <Fees>[])
                        legacyRow(
                          fee.title ?? '',
                          '+ ${(fee.amount ?? "0").countryPriceFormat(context)}',
                        ),
                    ],
                    // One quiet row; its arrow explains why the saving is more
                    // than the promo's own discount.
                    if (promoTaxReduction > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ExpandableChargeRow(
                          key: const ValueKey('promo'),
                          title: "couponDiscount".translate(context: context),
                          amount: '- $savedAmountValue',
                          details: [
                            for (final (String, double) line in [
                              ('discount', promoDiscount),
                              ('promoTaxReduction', promoTaxReduction),
                            ])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: ChargesTile(
                                  title: line.$1.translate(context: context),
                                  value:
                                      '- ${line.$2.toStringAsFixed(2).countryPriceFormat(context)}',
                                  fontSize: 12,
                                  fontweight: FontWeight.w400,
                                  titleColor: context.colors.textTertiary,
                                  valueColor: context.colors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      )
                    else if (promoDiscount > 0)
                      legacyRow(
                        "couponDiscount".translate(context: context),
                        '- ${promoDiscount.toStringAsFixed(2).countryPriceFormat(context)}',
                      ),
                    if (!useBreakdown &&
                        !atStoreSelected &&
                        visitingText.isNotEmpty &&
                        visitingText != '0' &&
                        visitingText != 'null')
                      legacyRow(
                        'visitingCharge'.translate(context: context),
                        '+ ${visitingText.countryPriceFormat(context)}',
                      ),
                    const CustomSizedBox(height: 8),
                    Divider(height: 1, color: context.colors.borderDefault),
                    const CustomSizedBox(height: 8),
                    ChargesTile(
                      title: 'totalAmount'.translate(context: context),
                      value: finalTotalText,
                      fontSize: 16,
                      fontweight: FontWeight.w700,
                      titleColor: context.colors.textPrimary,
                      valueColor: context.colors.textBrand,
                    ),
                  ];

                  return CheckoutBillDetailsCard(
                    isExpanded: isBillDetailsExpanded,
                    onToggle: _toggleBillDetails,

                    rows: rows,
                    showSavedBanner: savedAmount > 0,
                    savedAmountText:
                        '${'youSaved'.translate(context: context)} $savedAmountValue ${'onThisBooking'.translate(context: context)}',
                    finalTotalText: finalTotalText,
                    originalTotalText: originalTotalText,
                    savedBadgeText: savedBadgeText,
                  );
                }
                return const CustomSizedBox();
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Custom job bill from get_cart pricing: the tax, fee and visiting charge
  /// lines place_order will charge, same shape as the cart bill without a promo.
  Widget _buildCustomJobPricedBill(final Cart cart) {
    final bool showTax = context.read<SystemSettingCubit>().showTaxOnCheckout;
    final bool atStore = selectedDeliverableOption == "atStore";
    final bool useBreakdown =
        showTax && (cart.taxBreakdown?.groups.isNotEmpty ?? false);
    final double tax = double.tryParse(cart.taxValue ?? '') ?? 0;
    final double visiting = double.tryParse(cart.visitingCharges ?? '') ?? 0;
    final String totalText = cart
        .payableAmount(atStore: atStore)
        .toStringAsFixed(2)
        .countryPriceFormat(context);

    String money(final String? value) =>
        (value == null || value.isEmpty ? '0' : value).countryPriceFormat(
          context,
        );

    Widget row(final String title, final String value) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ChargesTile(
        title: title,
        value: value,
        fontSize: 14,
        fontweight: FontWeight.w400,
      ),
    );

    return CheckoutBillDetailsCard(
      isExpanded: isBillDetailsExpanded,
      onToggle: _toggleBillDetails,
      rows: [
        if (useBreakdown)
          TaxBreakdownRows(cart: cart, atStore: atStore)
        else ...[
          ChargesTile(
            title: 'subTotal'.translate(context: context),
            value: money(showTax ? cart.subTotalWithoutTax : cart.subTotal),
            fontSize: 14,
          ),
          if (showTax && tax > 0)
            row('tax'.translate(context: context), '+ ${money(cart.taxValue)}'),
          for (final Fees fee in cart.fees ?? const <Fees>[])
            row(fee.title ?? '', '+ ${money(fee.amount)}'),
          if (!atStore && visiting > 0)
            row(
              'visitingCharge'.translate(context: context),
              '+ ${money(cart.visitingCharges)}',
            ),
        ],
        const CustomSizedBox(height: 8),
        Divider(height: 1, color: context.colors.borderDefault),
        const CustomSizedBox(height: 8),
        ChargesTile(
          title: 'totalAmount'.translate(context: context),
          value: totalText,
          fontSize: 16,
          fontweight: FontWeight.w700,
          titleColor: context.colors.textPrimary,
          valueColor: context.colors.textBrand,
        ),
      ],
      showSavedBanner: false,
      savedAmountText: '',
      finalTotalText: totalText,
    );
  }

  void _openWebviewPaymentGateway({required String webviewLink}) {
    ClarityService.logAction(ClarityActions.paymentGatewayRedirected, {
      ..._buildCartAnalyticsPayload(
        paymentMethod: selectedPaymentMethod,
        paymentAmount: _currentCartTotalAmount(),
      ),
      'payment_url': webviewLink,
    });
    ClarityService.setTag(
      'payment_gateway',
      selectedPaymentMethod ?? 'webview',
    );
    Navigator.pushNamed(
      context,
      webviewPaymentScreen,
      arguments: {'paymentURL': webviewLink},
    ).then((final Object? value) {
      final parameter = value as Map;
      if (parameter['paymentStatus'] == 'Completed') {
        _navigateToOrderConfirmation(isSuccess: true);
      } else if (parameter['paymentStatus'] == 'Failed') {
        _navigateToOrderConfirmation(isSuccess: false);
      }
    });
  }

  @override
  void dispose() {
    _instructionController.dispose();
    paymentButtonName.dispose();
    _isLocationUnavailableAtDoorstep.dispose();
    _cartSubscription?.cancel();
    _razorpay.clear();
    CartRepository.activeAddressId = null;
    CartRepository.activePromoCodeId = null;
    super.dispose();
  }
}
