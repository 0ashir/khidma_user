import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static void init(final String? stripeId, final String? stripeMode) {
    final String key = stripeId ?? '';
    // Never print the key itself; its prefix is enough to spot a wrong/empty key.
    debugPrint(
      '[Stripe] init: mode=$stripeMode key=${key.isEmpty ? '<EMPTY>' : '${key.substring(0, key.length < 8 ? key.length : 8)}…'}',
    );
    Stripe.publishableKey = key;
  }

  /// Backend refusal message from the last [createPaymentIntent] call.
  static String? _lastIntentError;

  static Future<StripeTransactionResponse> payWithPaymentSheet({
    required final String orderId,
    final String? transactionId,
  }) async {
    try {
      //create Payment intent via backend
      final Map<String, dynamic>? paymentIntent =
          await StripeService.createPaymentIntent(
            orderId: orderId,
            transactionId: transactionId,
          );

      if (paymentIntent == null) {
        return StripeTransactionResponse(
          message: _lastIntentError ?? 'Failed to create payment intent',
          success: false,
          status: 'fail',
        );
      }

      //setting up Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          allowsDelayedPaymentMethods: true,
          style: ThemeMode.light,
          merchantDisplayName: appName,
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
                address: AddressCollectionMode.full,
                email: CollectionMode.always,
                name: CollectionMode.always,
                phone: CollectionMode.always,
              ),
        ),
      );

      //open payment sheet
      await Stripe.instance.presentPaymentSheet();

      //confirm payment via backend
      final statusOfTransaction = await StripeService.getPaymentStatus(
        paymentIntentId: paymentIntent['id'],
      );

      if (statusOfTransaction == 'succeeded') {
        return StripeTransactionResponse(
          message: 'Transaction successful',
          success: true,
          status: statusOfTransaction,
        );
      } else if (statusOfTransaction == 'pending' ||
          statusOfTransaction == 'captured') {
        return StripeTransactionResponse(
          message: 'Transaction pending',
          success: true,
          status: statusOfTransaction,
        );
      } else {
        return StripeTransactionResponse(
          message: 'Transaction failed',
          success: false,
          status: statusOfTransaction,
        );
      }
    } on StripeException catch (err) {
      // Sheet cancelled by the user, or rejected by Stripe (bad key, card…).
      debugPrint(
        '[Stripe] payment sheet error: ${err.error.code} ${err.error.message} ${err.error.localizedMessage}',
      );
      return StripeTransactionResponse(
        message: err.error.localizedMessage ?? err.error.message,
        success: false,
        status: err.error.code == FailureCode.Canceled ? 'cancelled' : 'fail',
      );
    } on PlatformException catch (err) {
      debugPrint('[Stripe] platform error: $err');
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (error, st) {
      debugPrint('[Stripe] payment failed: $error\n$st');
      return StripeTransactionResponse(
        message: 'Transaction failed: $error',
        success: false,
        status: 'fail',
      );
    }
  }

  static StripeTransactionResponse getPlatformExceptionErrorResult(final err) {
    // Only a real user cancel is 'cancelled'; any other platform error must
    // stay a failure so it is not silently treated as "sheet closed".
    final bool isCancel =
        err.code == 'cancelled' || err.code == FailureCode.Canceled.name;
    return StripeTransactionResponse(
      message: isCancel
          ? 'Transaction cancelled'
          : (err.message?.toString() ?? 'Something went wrong'),
      success: false,
      status: isCancel ? 'cancelled' : 'fail',
    );
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required final String orderId,
    final String? transactionId,
  }) async {
    _lastIntentError = null;
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.orderId: orderId,
      };

      if (transactionId != null && transactionId.isNotEmpty) {
        parameter[ApiParam.transactionId] = transactionId;
      }

      final response = await ApiClient.post(
        url: ApiUrl.createStripePaymentIntent,
        parameter: parameter,
        useAuthToken: true,
      );

      if (response['error'] == false && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      _lastIntentError = response['message']?.toString();
      debugPrint(
        '[Stripe] create_stripe_payment_intent rejected (order $orderId): $response',
      );
      return null;
    } catch (error) {
      _lastIntentError = error.toString();
      debugPrint('[Stripe] create_stripe_payment_intent failed: $error');
    }
    return null;
  }

  static Future<String?> getPaymentStatus({
    required final String paymentIntentId,
  }) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getStripePaymentStatus,
        parameter: {ApiParam.paymentIntentId: paymentIntentId},
        useAuthToken: true,
      );
      if (response['error'] == false && response['data'] != null) {
        final data = response['data'];
        return data['status'];
      }
      debugPrint('[Stripe] get_stripe_payment_status rejected: $response');
      return 'fail';
    } catch (error) {
      debugPrint('[Stripe] get_stripe_payment_status failed: $error');
      return 'fail';
    }
  }
}

class StripeTransactionResponse {
  StripeTransactionResponse({this.message, this.success, this.status});

  final String? message, status;
  bool? success;
}
