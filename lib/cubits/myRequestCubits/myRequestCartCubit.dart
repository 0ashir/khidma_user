import 'package:e_demand/app/generalImports.dart';

@immutable
abstract class MyRequestCartState {}

class MyRequestCartInitial extends MyRequestCartState {}

class MyRequestCartInProgress extends MyRequestCartState {
  final String? bidderId;

  MyRequestCartInProgress({this.bidderId});
}

class MyRequestCartSuccess extends MyRequestCartState {
  MyRequestCartSuccess({
    this.bidderId,
    required this.isBidderCart,
    required this.bidderData,
    this.pricedCart,
  });

  final String? bidderId;
  final bool isBidderCart;
  final BidProvider bidderData;

  /// get_cart's pricing of this bid (tax, fees, visiting charge), once loaded.
  final Cart? pricedCart;

  /// [pricedCart] when it carries a payable amount, else null so callers fall
  /// back to the bid's stored estimate.
  Cart? get pricing {
    final Cart? cart = pricedCart;
    return cart != null && (double.tryParse(cart.overallAmount ?? '') ?? 0) > 0
        ? cart
        : null;
  }
}

class MyRequestCartFailure extends MyRequestCartState {
  MyRequestCartFailure({this.bidderId, required this.errorMessage});

  final String errorMessage;
  final String? bidderId;
}

class MyRequestCartCubit extends Cubit<MyRequestCartState> {
  MyRequestCartCubit(this.cartRepository, this.pricingRepository)
    : super(MyRequestCartInitial());
  MyRequestRepository cartRepository;
  final CartRepository pricingRepository;

  /// Only the newest [loadPricing] call may land, so a slower earlier request
  /// (e.g. priced before the address resolved) can't overwrite a later one.
  int _pricingRequest = 0;

  void emitSuccess(final BidProvider bidder) {
    _pricingRequest++;
    emit(MyRequestCartSuccess(isBidderCart: true, bidderData: bidder));
  }

  /// Reprices [bidder] through get_cart. Silent: the bid's stored estimate
  /// stays on screen until the result lands, and stays if the call fails.
  Future<void> loadPricing(final BidProvider bidder) async {
    final String customJobRequestId = bidder.customJobRequestId ?? '';
    if (customJobRequestId.isEmpty || bidder.providerId == 0) return;

    final int request = ++_pricingRequest;
    try {
      final Cart? cart = await pricingRepository.getCustomJobCart(
        customJobRequestId: customJobRequestId,
        bidderId: bidder.providerId.toString(),
      );
      final MyRequestCartState current = state;
      if (cart == null ||
          isClosed ||
          request != _pricingRequest ||
          current is! MyRequestCartSuccess) {
        return;
      }
      emit(
        MyRequestCartSuccess(
          isBidderCart: current.isBidderCart,
          bidderData: current.bidderData,
          pricedCart: cart,
        ),
      );
    } catch (_) {}
  }

  String getProviderIDFromCartData() {
    if (state is MyRequestCartSuccess) {
      final BidProvider cartData = (state as MyRequestCartSuccess).bidderData;
      return cartData.providerId.toString();
    }
    return '0';
  }

  String getCartTotalAmount({
    required bool isAtStoreBooked,
    required String isFrom,
  }) {
    if (state is MyRequestCartSuccess && isFrom == 'customJobRequest') {
      final Cart? pricing = (state as MyRequestCartSuccess).pricing;
      if (pricing != null) {
        return pricing.payableAmount(atStore: isAtStoreBooked).toString();
      }

      final BidProvider cartData = (state as MyRequestCartSuccess).bidderData;

      final double visitingCharge = isAtStoreBooked
          ? 0
          : double.parse(cartData.visitingCharges ?? "0");

      return (double.parse(cartData.finalTotal ?? cartData.counterPrice) +
              visitingCharge)
          .toString();
    }
    return '0';
  }

  String getCartSubTotalAmount({
    required bool isAtStoreBooked,
    required String isFrom,
  }) {
    if (state is MyRequestCartSuccess && isFrom == 'customJobRequest') {
      final BidProvider cartData = (state as MyRequestCartSuccess).bidderData;

      return double.parse(
        cartData.finalTotal ?? cartData.counterPrice,
      ).toString();
    }
    return '0';
  }

  void clearCartCubit() {
    _pricingRequest++;
    emit(
      MyRequestCartSuccess(
        bidderData: BidProvider.empty(),
        isBidderCart: false,
      ),
    );
  }

  bool checkAtStoreProviderAvailable({required String isFrom}) {
    if (state is MyRequestCartSuccess && isFrom == 'customJobRequest') {
      return (state as MyRequestCartSuccess).bidderData.atStore == "1";
    }
    return false;
  }

  bool checkAtDoorstepProviderAvailable({required String isFrom}) {
    if (state is MyRequestCartSuccess && isFrom == 'customJobRequest') {
      return (state as MyRequestCartSuccess).bidderData.atDoorstep == "1";
    }
    return false;
  }
}
