import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class PaymentGatewayManager {
  final Razorpay _razorpay = Razorpay();

  //----------------------------------- Cashfree Payment Gateway start ----------------------------
  final CFPaymentGatewayService _cfPaymentGatewayService =
      CFPaymentGatewayService();

  late final PaymentGatewaysSettings? paymentGatewaySetting;
  late final BuildContext context;
  String placedOrderId;

  PaymentGatewayManager({
    required this.context,
    required this.paymentGatewaySetting,
    required this.placedOrderId,
  }) {
    _initializeRazorpay();
    _initializeCashfree();
  }

  void _initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
  }

  void _initializeCashfree() {
    _cfPaymentGatewayService.setCallback(
      _handleCashfreePaymentSuccess,
      _handleCashfreePaymentError,
    );
  }

  void _handleRazorPayPaymentSuccess(PaymentSuccessResponse response) {
    _navigateToOrderConfirmation(
      isSuccess: true,
      paymentGatewayName: "razorpay",
    );
  }

  void _handleRazorPayPaymentError(PaymentFailureResponse response) {}

  void _handleRazorPayExternalWallet(ExternalWalletResponse response) {}

  //----------------------------------- Cashfree Callbacks ----------------------------

  Future<void> _handleCashfreePaymentSuccess(String orderId) async {
    // The SDK fires this callback whenever the checkout session ends —
    // including when the user abandons the flow. We must verify the actual
    // payment status with our backend before treating it as a success.
    final CashfreeOrderStatus status = await CartRepository()
        .getCashfreeOrderStatus(orderId: orderId);
    _navigateToOrderConfirmation(
      isSuccess: status == CashfreeOrderStatus.paid,
      paymentGatewayName: "cashfree",
    );
  }

  void _handleCashfreePaymentError(
    CFErrorResponse errorResponse,
    String orderId,
  ) {
    UiUtils.showMessage(
      context,
      'paymentFailure'.translate(context: context),
      ToastificationType.error,
    );
    context.read<AddTransactionCubit>().addTransaction(
      status: "cancelled",
      orderID: placedOrderId,
    );
  }

  Future<void> processPayment({
    required String paymentMethod,
    required double amount,
    required String orderId,
    String? paymentUrl,
  }) async {
    placedOrderId = orderId;
    switch (paymentMethod) {
      case "cod":
        await _handleCodPayment(amount: amount);
        break;
      case "stripe":
        await _handleStripePayment(amount: amount);
        break;
      case "razorpay":
        await _handleRazorpayPayment(
          amount: amount,
          placedOrderId: placedOrderId,
        );
        break;
      case "paystack":
        await _handlePaystackPayment(paymentUrl: paymentUrl ?? '');
        break;
      case "paypal":
        await _handlePaypalPayment(paymentUrl: paymentUrl ?? '');
        break;
      case "flutterwave":
        await _handleFlutterwavePayment(paymentUrl: paymentUrl ?? '');
        break;
      case 'xendit':
        await _handleXenditPayment(paymentUrl: paymentUrl ?? '');
        break;
      case 'cashfree':
        await _handleCashfreePayment();
        break;
    }
  }

  Future<void> _handleCodPayment({required double amount}) async {
    _navigateToOrderConfirmation(isSuccess: true, paymentGatewayName: "cod");
  }

  Future<void> _handleStripePayment({required double amount}) async {
    try {
      await context.read<AddTransactionCubit>().addTransaction(
        status: "pending",
        orderID: placedOrderId,
        isAdditionalCharge: '1',
        paymentGatewayName: "stripe",
      );
      final String transactionId =
          context.read<AddTransactionCubit>().getTransactionId() ?? '';
      StripeService.init(
        paymentGatewaySetting!.stripePublishableKey,
        paymentGatewaySetting!.stripeMode,
      );

      final response = await StripeService.payWithPaymentSheet(
        orderId: placedOrderId,
        transactionId: transactionId,
      );
      if (response.status == 'succeeded') {
        _navigateToOrderConfirmation(
          isSuccess: true,
          paymentGatewayName: "stripe",
        );
      } else {
        // Closing the sheet is not a failure: show a neutral notice. A real
        // failure keeps the error toast, with Stripe's reason when known.
        final bool dismissed = response.status == 'cancelled';
        final String reason = response.message ?? '';
        UiUtils.showMessage(
          context,
          dismissed
              ? _paymentNotCompletedMessage()
              : (reason.isNotEmpty
                    ? reason
                    : 'paymentFailure'.translate(context: context)),
          dismissed ? ToastificationType.info : ToastificationType.error,
        );
        // Unchanged server-side: the attempt is recorded as cancelled and the
        // next tap starts a fresh pending charge.
        context.read<AddTransactionCubit>().addTransaction(
          status: "cancelled",
          orderID: placedOrderId,
        );
      }
    } catch (_) {
      _navigateToOrderConfirmation(
        isSuccess: false,
        paymentGatewayName: "stripe",
      );
    }
  }

  /// `paymentNotCompleted`, with an English fallback until the key exists in
  /// the server-provided language files.
  String _paymentNotCompletedMessage() {
    const String key = 'paymentNotCompleted';
    final String translated = key.translate(context: context);
    return translated == key
        ? "Payment wasn't completed. You can try again or choose another payment method."
        : translated;
  }

  Future<void> _handleRazorpayPayment({
    required final double amount,
    required final String placedOrderId,
  }) async {
    await context.read<AddTransactionCubit>().addTransaction(
      status: "pending",
      orderID: placedOrderId,
      isAdditionalCharge: '1',
      paymentGatewayName: "razorpay",
    );
    final cartRepository = CartRepository();
    final String razorpayOrderId = await cartRepository.createRazorpayOrderId(
      orderId: placedOrderId,
      isAdditionalCharge: '1',
    );
    final transactionId = context
        .read<AddTransactionCubit>()
        .getTransactionId();
    final options = {
      'key': paymentGatewaySetting!.razorpayKey,
      'amount': (amount * 100).toInt(),
      'name': appName,
      'description': 'Additional Charges Payment',
      'currency': paymentGatewaySetting!.razorpayCurrency,
      'notes': {
        'order_id': placedOrderId,
        'additional_charges_transaction_id': transactionId,
      },
      'order_id': razorpayOrderId,
    };

    _razorpay.open(options);
  }

  Future<void> _handlePaystackPayment({required String paymentUrl}) async {
    _openWebviewPaymentGateway(
      webviewLink: paymentUrl,
      paymentGatewayName: "paystack",
    );
  }

  Future<void> _handlePaypalPayment({required String paymentUrl}) async {
    _openWebviewPaymentGateway(
      webviewLink: paymentUrl,
      paymentGatewayName: "paypal",
    );
  }

  Future<void> _handleFlutterwavePayment({required String paymentUrl}) async {
    _openWebviewPaymentGateway(
      webviewLink: paymentUrl,
      paymentGatewayName: "flutterwave",
    );
  }

  Future<void> _handleXenditPayment({required String paymentUrl}) async {
    _openWebviewPaymentGateway(
      webviewLink: paymentUrl,
      paymentGatewayName: 'xendit',
    );
  }

  //----------------------------------- Cashfree Payment Gateway ----------------------------

  /// Initiates Cashfree web-checkout.
  /// - Calls our backend [createCashfreeSession] to get a payment_session_id.
  /// - Opens the Cashfree SDK checkout sheet.
  Future<void> _handleCashfreePayment() async {
    try {
      await context.read<AddTransactionCubit>().addTransaction(
        status: "pending",
        orderID: placedOrderId,
        isAdditionalCharge: '1',
        paymentGatewayName: "cashfree",
      );

      final cartRepository = CartRepository();
      final sessionData = await cartRepository.createCashfreeSession(
        orderId: placedOrderId,
        isAdditionalCharge: '1',
      );

      final String paymentSessionId = sessionData['paymentSessionId'] ?? '';
      final String cashfreeOrderId =
          sessionData['cashfreeOrderId'] ?? placedOrderId;

      if (paymentSessionId.isEmpty) {
        UiUtils.showMessage(
          context,
          'paymentFailure'.translate(context: context),
          ToastificationType.error,
        );
        return;
      }

      final CFEnvironment environment =
          (paymentGatewaySetting?.cashfreeEnvironment ?? '').toLowerCase() ==
              'production'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final CFSession session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(cashfreeOrderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      _cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      UiUtils.showMessage(context, e.message, ToastificationType.error);
      context.read<AddTransactionCubit>().addTransaction(
        status: "cancelled",
        orderID: placedOrderId,
      );
      context.read<BookingCubit>().fetchAllBookings(status: '');
    } catch (e) {
      UiUtils.showMessage(context, e.toString(), ToastificationType.error);
      context.read<AddTransactionCubit>().addTransaction(
        status: "cancelled",
        orderID: placedOrderId,
      );
      context.read<BookingCubit>().fetchAllBookings(status: '');
    }
  }

  void _openWebviewPaymentGateway({
    required String webviewLink,
    required final String? paymentGatewayName,
  }) {
    Navigator.pushNamed(
      context,
      webviewPaymentScreen,
      arguments: {'paymentURL': webviewLink},
    ).then((final Object? value) {
      final parameter = value as Map;
      if (parameter['paymentStatus'] == 'Completed') {
        _navigateToOrderConfirmation(
          isSuccess: true,
          paymentGatewayName: paymentGatewayName,
        );
      } else if (parameter['paymentStatus'] == 'Failed') {
        _navigateToOrderConfirmation(
          isSuccess: false,
          paymentGatewayName: paymentGatewayName,
        );
      }
    });
  }

  void _navigateToOrderConfirmation({
    required final bool isSuccess,
    required final String? paymentGatewayName,
  }) {
    if (!isSuccess) {
      UiUtils.showMessage(
        context,
        'paymentFailed'.translate(context: context),
        ToastificationType.error,
      );
      context.read<AddTransactionCubit>().addTransaction(
        status: "cancelled",
        orderID: placedOrderId,
      );
      return;
    }
    context.read<BookingCubit>().fetchAllBookings(status: '');
    final transactionId = context
        .read<AddTransactionCubit>()
        .getTransactionId();
    Navigator.pushNamed(
      context,
      orderConfirmation,
      arguments: {
        'isSuccess': isSuccess,
        'orderId': placedOrderId,
        'isFromAdditionalCharge': true,
        'paymentGatewayName': paymentGatewayName,
        'transactionId': transactionId ?? '',
      },
    );
  }

  void dispose() {
    _razorpay.clear();
    // CFPaymentGatewayService is a singleton and does not need explicit disposal.
  }
}
