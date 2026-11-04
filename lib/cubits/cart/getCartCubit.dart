import 'package:e_demand/app/generalImports.dart';

@immutable
abstract class CartState {}

class CartInitial extends CartState {}

class CartFetchInProgress extends CartState {
  final String? reOrderId;

  CartFetchInProgress({this.reOrderId});
}

class CartFetchSuccess extends CartState {
  CartFetchSuccess({
    this.listBooking,
    this.detailBooking,
    this.isReorderFrom,
    this.reOrderId,
    required this.isReorderCart,
    this.reOrderCartData,
    required this.cartData,
  });

  final String? reOrderId;
  final String? isReorderFrom;
  final bool isReorderCart;
  final Cart cartData;
  final Cart? reOrderCartData;
  final BookingListItem? listBooking;
  final BookingDetailModel? detailBooking;
}

class CartFetchFailure extends CartState {
  CartFetchFailure({this.reOrderBookingId, required this.errorMessage});

  final String errorMessage;
  final String? reOrderBookingId;
}

class CartCubit extends Cubit<CartState> {
  CartCubit(this.cartRepository) : super(CartInitial());
  CartRepository cartRepository;

  ///This method is used to fetch cart details
  Future<void> getCartDetails({
    final String? reOrderId,
    final String? isReorderFrom,
    required final bool isReorderCart,
    final BookingListItem? listBooking,
    final BookingDetailModel? detailBooking,
    final String? preferredCartId,

    /// Refresh the cart in place: no loading state (so the screen showing it
    /// doesn't blank out) and, if the refresh fails, the current cart stays.
    final bool silent = false,
  }) async {
    final bool keepCurrent = silent && state is CartFetchSuccess;
    try {
      if (!keepCurrent) emit(CartFetchInProgress(reOrderId: reOrderId));

      final Map<String, dynamic> cartData = await cartRepository.getUserCart(
        useAuthToken: true,
        reOrderId: reOrderId,
        cartId: preferredCartId,
      );

      final Cart cart = cartData["cartData"] as Cart;
      final Cart reOrderCart = cartData["reOrderCartData"] as Cart;

      ClarityService.logAction(ClarityActions.cartViewed, {
        'provider_id': cart.providerId ?? '',
        'provider_name': cart.translatedProviderName ?? cart.providerName ?? '',
        'total_quantity': cart.totalQuantity ?? '',
        'subtotal': cart.subTotal ?? '',
        'overall_amount': cart.overallAmount ?? '',
        'promo_code': cart.appliedPromoCodeName ?? '',
      });
      emit(
        CartFetchSuccess(
          isReorderFrom: isReorderFrom,
          listBooking: listBooking,
          detailBooking: detailBooking,
          reOrderId: reOrderId,
          isReorderCart: isReorderCart,
          cartData: cart,
          reOrderCartData: reOrderCart,
        ),
      );
    } catch (e) {
      if (keepCurrent) return;
      emit(
        CartFetchFailure(
          reOrderBookingId: reOrderId,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void updateCartDetails(final Cart cartDetails) {
    try {
      emit(
        CartFetchSuccess(
          reOrderId: "0",
          isReorderCart: false,
          cartData: cartDetails,
        ),
      );
    } catch (_) {}
  }

  bool selectPrimaryCart(final String cartId) {
    final currentState = state;
    if (currentState is! CartFetchSuccess) return false;

    final Cart current = currentState.cartData;
    if (current.carId == cartId) return true;

    final List<Cart> others = current.otherCarts ?? [];
    final int matchIndex = others.indexWhere((c) => c.carId == cartId);
    if (matchIndex == -1) return false;

    final Cart newPrimary = others[matchIndex];
    final List<Cart> newOthers = List<Cart>.from(others)..removeAt(matchIndex);
    current.otherCarts = null;
    newOthers.insert(0, current);
    newPrimary.otherCarts = newOthers;

    emit(
      CartFetchSuccess(
        reOrderId: currentState.reOrderId,
        isReorderFrom: currentState.isReorderFrom,
        isReorderCart: currentState.isReorderCart,
        listBooking: currentState.listBooking,
        detailBooking: currentState.detailBooking,
        cartData: newPrimary,
        reOrderCartData: currentState.reOrderCartData,
      ),
    );
    return true;
  }

  String getProviderIDFromCartData() {
    if (state is CartFetchSuccess) {
      final Cart cartData = (state as CartFetchSuccess).cartData;
      return cartData.providerId ?? '0';
    }
    return '0';
  }

  String getCartId({required String isFrom}) {
    if (state is CartFetchSuccess) {
      final Cart? cartData = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData
          : (state as CartFetchSuccess).reOrderCartData;

      return cartData?.carId ?? '';
    }
    return '';
  }

  String getCartTotalAmount({
    required bool isAtStoreBooked,
    required String isFrom,
  }) {
    if (state is CartFetchSuccess) {
      final Cart cartData = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData
          : (state as CartFetchSuccess).reOrderCartData!;

      return cartData.payableAmount(atStore: isAtStoreBooked).toString();
    }
    return '0';
  }

  String getCartSubTotalAmount({
    required bool isAtStoreBooked,
    required String isFrom,
  }) {
    if (state is CartFetchSuccess) {
      final Cart cartData = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData
          : (state as CartFetchSuccess).reOrderCartData!;

      // validate_promo_code wants the services total before tax (no fees or
      // visiting charge); `sub_total` already includes service tax.
      final double withoutTax =
          double.tryParse(cartData.subTotalWithoutTax ?? '') ?? 0;
      return (withoutTax > 0
              ? withoutTax
              : double.tryParse(cartData.subTotal ?? '') ?? 0)
          .toString();
    }
    return '0';
  }

  bool isPayLaterAllowed({required String isFrom}) {
    if (state is CartFetchSuccess) {
      final Cart cartData = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData
          : (state as CartFetchSuccess).reOrderCartData!;

      return cartData.isPayLaterAllowed == "1";
    }
    return false;
  }

  bool isOnlinePaymentAllowed({required String isFrom}) {
    if (state is CartFetchSuccess) {
      final Cart cartData = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData
          : (state as CartFetchSuccess).reOrderCartData!;

      return cartData.isOnlinePaymentAllowed == "1";
    }
    return false;
  }

  String getServiceCartQuantity({required final String serviceId}) {
    if (state is CartFetchSuccess) {
      final cartData = (state as CartFetchSuccess).cartData;

      final latestMatch = cartData.cartDetails?.firstWhere(
        (e) => e.serviceId == serviceId,
        orElse: () => CartDetails(),
      );
      if (latestMatch?.qty != null && (latestMatch!.qty?.isNotEmpty ?? false)) {
        return latestMatch.qty!;
      }

      if (cartData.otherCarts != null) {
        for (final otherCart in cartData.otherCarts!) {
          final otherMatch = otherCart.cartDetails?.firstWhere(
            (e) => e.serviceId == serviceId,
            orElse: () => CartDetails(),
          );
          if (otherMatch?.qty != null &&
              (otherMatch!.qty?.isNotEmpty ?? false)) {
            return otherMatch.qty!;
          }
        }
      }
    }
    return '0';
  }

  void clearCartCubit() {
    emit(
      CartFetchSuccess(
        cartData: Cart(),
        isReorderCart: false,
        reOrderCartData: Cart(),
      ),
    );
  }

  bool checkAtStoreProviderAvailable({required String isFrom}) {
    if (state is CartFetchSuccess) {
      final store = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData.isAtStoreAvailable
          : (state as CartFetchSuccess).reOrderCartData?.isAtStoreAvailable;
      return store == "1";
    }
    return false;
  }

  bool checkAtDoorstepProviderAvailable({required String isFrom}) {
    if (state is CartFetchSuccess) {
      final doorstep = isFrom == "cart"
          ? (state as CartFetchSuccess).cartData.isAtDoorstepAvailable
          : (state as CartFetchSuccess).reOrderCartData?.isAtDoorstepAvailable;
      return doorstep != "0";
    }
    return true;
  }

  int getProviderCartsCount() {
    if (state is CartFetchSuccess) {
      final cartData = (state as CartFetchSuccess).cartData;
      int count = 0;
      if (cartData.providerId != null &&
          cartData.providerId!.isNotEmpty &&
          (cartData.cartDetails?.isNotEmpty ?? false)) {
        count++;
      }
      if (cartData.otherCarts != null) {
        for (final otherCart in cartData.otherCarts!) {
          if (otherCart.providerId != null &&
              otherCart.providerId!.isNotEmpty &&
              (otherCart.cartDetails?.isNotEmpty ?? false)) {
            count++;
          }
        }
      }
      return count;
    }
    return 0;
  }

  bool isProviderCartExisting(String providerId) {
    if (state is CartFetchSuccess) {
      final cartData = (state as CartFetchSuccess).cartData;
      if (cartData.providerId == providerId &&
          (cartData.cartDetails?.isNotEmpty ?? false)) {
        return true;
      }
      if (cartData.otherCarts != null) {
        for (final otherCart in cartData.otherCarts!) {
          if (otherCart.providerId == providerId &&
              (otherCart.cartDetails?.isNotEmpty ?? false)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int getItemsCountForProvider(String providerId) {
    if (state is CartFetchSuccess) {
      final cartData = (state as CartFetchSuccess).cartData;
      if (cartData.providerId == providerId) {
        return int.tryParse(cartData.totalQuantity ?? '0') ?? 0;
      }
      if (cartData.otherCarts != null) {
        for (final otherCart in cartData.otherCarts!) {
          if (otherCart.providerId == providerId) {
            return int.tryParse(otherCart.totalQuantity ?? '0') ?? 0;
          }
        }
      }
    }
    return 0;
  }

  String? checkCartRestrictions({
    required String providerId,
    required int maxItemsPerProvider,
    required int maxCartsPerUser,
  }) {
    if (state is CartFetchSuccess) {
      final hasExistingCart = isProviderCartExisting(providerId);

      // Check maxCartsPerUser if adding a service for a new provider
      if (!hasExistingCart) {
        final currentCartsCount = getProviderCartsCount();
        if (currentCartsCount >= maxCartsPerUser) {
          return 'maxCartsPerUserLimitReached';
        }
      }

      // Check maxItemsPerProvider for this provider
      final currentItemsCount = getItemsCountForProvider(providerId);
      if (currentItemsCount >= maxItemsPerProvider) {
        return 'maxItemsPerProviderLimitReached';
      }
    }
    return null;
  }
}
