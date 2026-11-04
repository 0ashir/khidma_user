import 'package:e_demand/app/generalImports.dart';
import 'package:intl/intl.dart';

enum CashfreeOrderStatus { paid, pending, failed }

class CartRepository {
  /// Address the customer picked at checkout. While set, cart calls send
  /// `address_id` so the backend resolves country/tax from it (coordinates stay
  /// as fallback), keeping get_cart, manage_cart and remove_from_cart on the
  /// same country. Cleared when checkout closes.
  static String? activeAddressId;

  /// Promo applied at checkout; sent as `promo_code_id` so the returned cart is
  /// priced with it (discount, tax reduction, `final_total`). Cleared with the
  /// address when checkout closes.
  static String? activePromoCodeId;

  Map<String, dynamic> get _addressParam => {
    if ((activeAddressId ?? '').isNotEmpty) ApiParam.addressId: activeAddressId,
    if ((activePromoCodeId ?? '').isNotEmpty)
      ApiParam.promocodeId: activePromoCodeId,
  };

  Cart? _primaryCartFromList(
    final List cartsList, {
    final String? matchCartId,
    final String? matchProviderId,
    final Map<String, dynamic>? totals,
  }) {
    if (cartsList.isEmpty) return null;

    var primaryIndex = 0;
    if (matchCartId != null && matchCartId.isNotEmpty) {
      final matchedIndex = cartsList.indexWhere(
        (final c) => c is Map && c["cart_id"]?.toString() == matchCartId,
      );
      if (matchedIndex != -1) primaryIndex = matchedIndex;
    } else if (matchProviderId != null && matchProviderId.isNotEmpty) {
      final matchedIndex = cartsList.indexWhere(
        (final c) =>
            c is Map && c["provider_id"]?.toString() == matchProviderId,
      );
      if (matchedIndex != -1) primaryIndex = matchedIndex;
    }

    if (cartsList[primaryIndex] is! Map) return null;

    final primaryCart = Cart.fromJson(
      Map<String, dynamic>.from(cartsList[primaryIndex] as Map),
    );
    primaryCart.otherCarts = [
      for (var i = 0; i < cartsList.length; i++)
        if (i != primaryIndex && cartsList[i] is Map)
          Cart.fromJson(Map<String, dynamic>.from(cartsList[i] as Map)),
    ];
    if (totals != null) {
      primaryCart.totalServiceCount =
          totals["total_service_count"]?.toString() ?? '';
      primaryCart.totalProviderCount =
          totals["total_provider_count"]?.toString() ?? '';
      primaryCart.totalOverallAmount =
          totals["total_overall_amount"]?.toString() ?? '';
    }
    return primaryCart;
  }

  //This method is used to get user cart details
  Future<Map<String, dynamic>> getUserCart({
    required final bool useAuthToken,
    final String? reOrderId,
    final String? cartId,
  }) async {
    try {
      if (reOrderId == null) {
        final cartData = await ApiClient.post(
          url: ApiUrl.getCart,
          parameter: {
            ApiParam.fromNewApp: 1,
            ..._addressParam,
            ApiParam.latitude: HiveRepository.getLatitude,
            ApiParam.longitude: HiveRepository.getLongitude,
          },
          useAuthToken: useAuthToken,
        );

        final cartDataMap = cartData["data"]?["cart_data"];
        if (cartData["data"] is! Map || cartDataMap is! Map) {
          return {
            "error": cartData["error"],
            "message": cartData["message"],
            "cartData": Cart(),
            "reOrderCartData": Cart(),
          };
        }
        final cartsList = cartDataMap["carts"];
        final primaryCart = cartsList is List
            ? _primaryCartFromList(
                cartsList,
                matchCartId: cartId,
                totals: Map<String, dynamic>.from(cartDataMap),
              )
            : null;

        return {
          "error": cartData["error"],
          "message": cartData["message"],
          "cartData": primaryCart ?? Cart(),
          "reOrderCartData": Cart(),
        };
      }

      final cartData = await ApiClient.post(
        url: ApiUrl.getCart,
        parameter: {
          ApiParam.orderId: reOrderId,
          ApiParam.fromNewApp: 1,
          ..._addressParam,
          ApiParam.latitude: HiveRepository.getLatitude,
          ApiParam.longitude: HiveRepository.getLongitude,
        },
        useAuthToken: useAuthToken,
      );

      if (cartData["data"] is! Map) {
        return {
          "error": cartData["error"],
          "message": cartData["message"],
          "cartData": Cart(),
          "reOrderCartData": Cart(),
        };
      }

      final cartDataMap = cartData["data"]["cart_data"];
      final reorderDataMap = cartData["data"]["reorder_data"];

      final cartsList = cartDataMap is Map ? cartDataMap["carts"] : null;
      final primaryCart = cartsList is List
          ? _primaryCartFromList(
              cartsList,
              totals: Map<String, dynamic>.from(cartDataMap as Map),
            )
          : null;

      final reorderCartsList = reorderDataMap is Map
          ? reorderDataMap["carts"]
          : null;
      final primaryReorderCart = reorderCartsList is List
          ? _primaryCartFromList(
              reorderCartsList,
              totals: Map<String, dynamic>.from(reorderDataMap as Map),
            )
          : null;

      return {
        "error": cartData["error"],
        "message": cartData["message"],
        "cartData": primaryCart ?? Cart(),
        "reOrderCartData": primaryReorderCart ?? Cart(),
      };
    } catch (e) {
      throw ApiException(
        "somethingWentWrong".translate(
          context: UiUtils.rootNavigatorKey.currentContext!,
        ),
      );
    }
  }

  /// Prices a custom job bid the way place_order will charge it: get_cart with
  /// `custom_job_request_id` + `bidder_id` returns `custom_job_data`, taxed from
  /// the picked address (the bid's stored estimate is not used). Null when the
  /// bid isn't found, isn't pending or isn't the customer's.
  Future<Cart?> getCustomJobCart({
    required final String customJobRequestId,
    required final String bidderId,
  }) async {
    final response = await ApiClient.post(
      url: ApiUrl.getCart,
      parameter: {
        ApiParam.fromNewApp: 1,
        ApiParam.customJobRequestId: customJobRequestId,
        ApiParam.bidderId: bidderId,
        ..._addressParam,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      },
      useAuthToken: true,
    );

    final customJobData = response['data'] is Map
        ? response['data']['custom_job_data']
        : null;
    if (customJobData is! Map) return null;
    final carts = customJobData['carts'];
    return carts is List
        ? _primaryCartFromList(
            carts,
            totals: Map<String, dynamic>.from(customJobData),
          )
        : null;
  }

  ///This method is used to addService into Cart
  Future<Map<String, dynamic>> addServiceIntoCart({
    required final bool useAuthToken,
    required final int serviceId,
    required final int quantity,
    required final String providerId,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.qty: quantity,
        ApiParam.serviceId: serviceId,
        ApiParam.providerId: providerId,
        ApiParam.fromNewApp: 1,
        ..._addressParam,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };
      final Map<String, dynamic> cartData = await ApiClient.post(
        url: ApiUrl.manageCart,
        parameter: parameter,
        useAuthToken: useAuthToken,
      );

      Cart updatedCartData = Cart();
      if (cartData['data'] is Map) {
        final cartDataMap = Map<String, dynamic>.from(
          cartData['data'] as Map,
        )['cart_data'];
        if (cartDataMap is Map) {
          final dataMap = Map<String, dynamic>.from(cartDataMap);
          final cartsList = dataMap['carts'];
          if (cartsList is List) {
            // Pin the provider being edited as primary — without this,
            // _primaryCartFromList falls back to carts[0], which can be a
            // different provider once the user has more than one cart, and
            // silently swaps out the cart the checkout screen is showing.
            updatedCartData =
                _primaryCartFromList(
                  cartsList,
                  matchProviderId: providerId,
                  totals: dataMap,
                ) ??
                Cart();
          }
        }
      }
      return {
        'error': cartData['error'],
        'message': cartData['message'],
        'cartData': updatedCartData,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to remove service from Cart
  Future<Map<String, dynamic>> removeServiceFromCart({
    required final bool useAuthToken,
    required final int serviceId,
    required final String providerId,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.serviceId: serviceId,
        ApiParam.providerId: providerId,
        ApiParam.fromNewApp: 1,
        ..._addressParam,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };
      final cartData = await ApiClient.post(
        url: ApiUrl.removeFromCart,
        parameter: parameter,
        useAuthToken: useAuthToken,
      );

      //to store updated cart data
      Cart updatedCartData = Cart();
      if (cartData['data'] is Map) {
        final cartDataMap = Map<String, dynamic>.from(
          cartData['data'] as Map,
        )['cart_data'];
        if (cartDataMap is Map) {
          final dataMap = Map<String, dynamic>.from(cartDataMap);
          final cartsList = dataMap['carts'];
          if (cartsList is List) {
            // Same pin as addServiceIntoCart — keep the edited provider's
            // cart primary instead of whatever carts[0] happens to be.
            updatedCartData =
                _primaryCartFromList(
                  cartsList,
                  matchProviderId: providerId,
                  totals: dataMap,
                ) ??
                Cart();
          }
        }
      }

      return {
        'error': cartData['error'],
        'message': cartData['message'],
        'cartData': updatedCartData,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to remove Cart
  Future<Map<String, dynamic>> removeCart({
    required final bool useAuthToken,
    required final String providerId,
    final bool clearAll = false,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.providerId: providerId,
        ApiParam.fromNewApp: 1,
        ..._addressParam,
        ApiParam.clearAll: clearAll ? 1 : 0,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };
      final cartData = await ApiClient.post(
        url: ApiUrl.removeFromCart,
        parameter: parameter,
        useAuthToken: useAuthToken,
      );

      Cart updatedCartData = Cart();
      if (cartData['data'] is Map) {
        final cartDataMap = Map<String, dynamic>.from(
          cartData['data'] as Map,
        )['cart_data'];
        if (cartDataMap is Map) {
          final dataMap = Map<String, dynamic>.from(cartDataMap);
          final cartsList = dataMap['carts'];
          if (cartsList is List) {
            updatedCartData =
                _primaryCartFromList(cartsList, totals: dataMap) ?? Cart();
          }
        }
      }

      return {
        'error': cartData['error'],
        'message': cartData['message'],
        'cartData': updatedCartData,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch timeslot of specific date
  Future<Map<String, dynamic>> fetchTimeSlots({
    required final bool useAuthToken,
    required final int providerId,
    required final String selectedDate,
    final String? customJobRequestId,
  }) async {
    try {
      final parameter = <String, dynamic>{
        ApiParam.partnerId: providerId,
        ApiParam.date: selectedDate,
        ApiParam.customJobRequestId: customJobRequestId,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };
      parameter.removeWhere(
        (key, value) => value == null || value == "null" || value == '',
      );
      final cartData = await ApiClient.post(
        url: ApiUrl.getAvailableSlots,
        parameter: parameter,
        useAuthToken: useAuthToken,
      );

      final Map<String, dynamic> response = <String, dynamic>{
        'error': cartData['error'],
        'message': cartData['message'],
        'slots': <AllSlots>[],
      };

      if (!cartData['error']) {
        response['slots'] = (cartData['data']['all_slots'] as List)
            .map((final e) => AllSlots.fromJson(Map.from(e)))
            .toList();
      }

      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// `billing_*` fields of place_order. Tax uses the billing country/region,
  /// so a separate billing address sends its country, region, saved custom
  /// field values (JSON `[{custom_field_id, value}]`), mobile and label.
  /// The fields are sent even when [sameAsShipping] is set (billing is the
  /// service address), so the backend always has the billing details.
  Map<String, dynamic> _billingParams(
    final GetAddressModel? billing, {
    required final bool sameAsShipping,
  }) {
    if (billing == null) return {ApiParam.billingSameAsShipping: 1};
    final List<Map<String, dynamic>> customFields = [
      for (final MapEntry<String, dynamic> e
          in (billing.customFieldValues ?? const <String, dynamic>{}).entries)
        {'custom_field_id': int.tryParse(e.key) ?? e.key, 'value': e.value},
    ];
    return {
      ApiParam.billingSameAsShipping: sameAsShipping ? 1 : 0,
      ApiParam.billingCountryId: billing.countryId,
      ApiParam.billingRegionId: billing.regionId,
      ApiParam.billingCustomFields: jsonEncode(customFields),
      ApiParam.billingMobile: billing.mobile?.replaceAll(RegExp(r'\D'), ''),
      ApiParam.billingType: billing.type,
    };
  }

  ///this method is used to place an order
  Future<Map<String, dynamic>> placeOrder({
    final String? promoCodeId,
    required final String paymentMethod,
    required final String? selectedAddressID,
    required final String isAtStoreOptionSelected,
    required final String status,
    required final String orderNote,
    required final String startingTime,
    required final String dateOfService,
    final String? orderID,
    final String? customJobRequestId,
    final String? bidderId,
    final String? cartId,

    /// Billing address to send (country, region, custom fields, mobile).
    final GetAddressModel? billingAddress,

    /// True when [billingAddress] is just the service address.
    final bool billingSameAsShipping = false,
  }) async {
    try {
      final parameter = <String, dynamic>{
        ApiParam.promocodeId: promoCodeId ?? '',
        ApiParam.paymentMethod: paymentMethod,
        ApiParam.addressId: selectedAddressID,
        ApiParam.status: status,
        ApiParam.orderNote: orderNote,
        ApiParam.dateOfService: DateFormat(
          "yyyy-MM-dd",
        ).format(DateTime.parse("$dateOfService 00:00:00.000Z")),
        ApiParam.startingTime: startingTime,
        ApiParam.atStore: isAtStoreOptionSelected,
        ApiParam.orderId: orderID,
        ApiParam.customJobRequestId: customJobRequestId,
        ApiParam.bidderId: bidderId,
        ApiParam.orderFrom: "1",
        ApiParam.cartId: cartId,
        ..._billingParams(
          billingAddress,
          sameAsShipping: billingSameAsShipping,
        ),
      };

      parameter.removeWhere(
        (key, value) => value == null || value == "null" || value == '',
      );

      final orderData = await ApiClient.post(
        url: ApiUrl.placeOrder,
        parameter: parameter,
        useAuthToken: true,
      );
      if (orderData['error'] == true) {
        final errorMessage =
            orderData['message']?.toString() ??
            'somethingWentWrong'.translate(
              context: UiUtils.rootNavigatorKey.currentContext!,
            );
        throw ApiException(errorMessage);
      }
      return {
        'orderId': orderData['data']['order_id'],
        'error': orderData['error'],
        'message': orderData['message'] ?? '',
        'paypalLink': orderData['data']['paypal_link'] ?? '',
        'paystackLink': orderData['data']['paystack_link'] ?? '',
        'flutterwaveLink': orderData['data']['flutterwave'] ?? '',
        'xenditLink': orderData['data']['xendit'] ?? '',
      };
    } catch (e) {
      if (e is ApiException) {
        throw e;
      }
      // For other exceptions, convert to ApiException
      throw ApiException(e.toString());
    }
  }

  ///This method is used to create razorpay order Id
  Future<String> createRazorpayOrderId({
    required final String orderId,
    required final String isAdditionalCharge,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.orderId: orderId,
        ApiParam.isAdditionalCharge: isAdditionalCharge,
      };
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.createRazorpayOrder,
        useAuthToken: true,
      );

      return result['data']['id'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Creates a Cashfree payment session for the given order.
  ///
  /// The backend is expected to:
  /// 1. Create / fetch the order on Cashfree servers using the Cashfree order API.
  /// 2. Return a `payment_session_id` (and optionally `cf_order_id`) in the
  ///    `data` field.
  ///
  /// Returns a map with:
  /// - `paymentSessionId` – the Cashfree payment session token
  /// - `cfOrderId`        – the order_id as known by Cashfree (= our orderId)
  Future<Map<String, String>> createCashfreeSession({
    required final String orderId,
    required final String isAdditionalCharge,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.orderId: orderId,
        ApiParam.isAdditionalCharge: isAdditionalCharge,
      };
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.createCashfreeOrder,
        useAuthToken: true,
      );

      return {
        'paymentSessionId':
            result['data']['payment_session_id']?.toString() ?? '',
        'cashfreeOrderId': result['data']['order_id']?.toString() ?? orderId,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Fetches the Cashfree order status from our backend. Paid only when the
  /// order is PAID or its transaction status is "success"; pending when the
  /// order is still ACTIVE or its transaction status is "pending" — a
  /// transaction record existing is not itself proof of payment, since one
  /// is created for pending/failed attempts too. Anything else (or a failed
  /// lookup) is treated as failed.
  Future<CashfreeOrderStatus> getCashfreeOrderStatus({
    required final String orderId,
  }) async {
    try {
      final result = await ApiClient.post(
        url: ApiUrl.getCashfreeOrderStatus,
        useAuthToken: true,
        parameter: {ApiParam.orderId: orderId},
      );

      final transactionStatus = result['data']['transaction']?['status']
          ?.toString()
          .toLowerCase();

      if (transactionStatus == 'success' ||
          result['data']['order']['order_status'] == 'PAID') {
        return CashfreeOrderStatus.paid;
      }
      if (transactionStatus == 'pending' ||
          result['data']['order']['order_status'] == 'ACTIVE') {
        return CashfreeOrderStatus.pending;
      }
      return CashfreeOrderStatus.failed;
    } catch (_) {
      return CashfreeOrderStatus.failed;
    }
  }

  ///This method is used to fetch the promo code catalog, optionally scoped
  ///to a provider (backend accepts the same partner_id/provider_slug filter
  ///as the old get_promo_codes endpoint)
  Future<Map<String, dynamic>> fetchAllPromocodes({
    required final String offset,
    required final String limit,
    final String? search,
    final String? providerIdOrSlug,
    final ProviderDetailsParamType? type,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.limit: limit,
        ApiParam.offset: offset,
        if (search != null && search.isNotEmpty) ApiParam.search: search.trim(),
        if (providerIdOrSlug != null && providerIdOrSlug.isNotEmpty)
          if (type == ProviderDetailsParamType.slug)
            ApiParam.providerSlug: providerIdOrSlug
          else
            ApiParam.providerId: providerIdOrSlug,
      };

      final result = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getAllPromocodes,
        useAuthToken: false,
      );

      return {
        'totalPromocodes': result['total']?.toString() ?? "0",
        'promocodeList': (result['data'] as List? ?? [])
            .map((final e) => Promocode.fromJson(Map.from(e)))
            .toList(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to validate promocodes of partner
  Future<Map<String, dynamic>> validatePromocode({
    required final String promocodeId,
    required final String totalAmount,
    final String? providerId,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.promocodeId: promocodeId,
        ApiParam.totalAmount: totalAmount,
        // A promo is only valid with the provider that owns it.
        if ((providerId ?? '').isNotEmpty && providerId != '0')
          ApiParam.partnerId: providerId,
      };
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.validatePromocode,
        useAuthToken: true,
      );

      final Map<String, dynamic> response = <String, dynamic>{
        'error': result['error'],
        'message': result['message'],
      };
      if (!result['error']) {
        response['discountAmount'] = result['data'][0]['final_discount'];
        response['finalOrderAmount'] = result['data'][0]['final_total'];
      }
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to validate custom time for booking
  Future<Map<String, dynamic>> validateCustomTime({
    required final String providerId,
    required final String selectedDate,
    required final String selectedTime,
    final String? orderId,
    final String? customJobRequestId,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.date: selectedDate,
        ApiParam.time: selectedTime,
        ApiParam.partnerId: providerId,
        ApiParam.orderId: orderId,
        ApiParam.customJobRequestId: customJobRequestId,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };

      parameters.removeWhere(
        (key, value) => value == null || value == "null" || value == '',
      );
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.validateCustomTime,
        useAuthToken: true,
      );

      final Map<String, dynamic> response = <String, dynamic>{
        'error': result['error'],
        'message': result['message'],
      };
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
