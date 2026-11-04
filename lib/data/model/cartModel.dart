import 'package:e_demand/data/model/serviceModel.dart';

class Cart {
  List<CartDetails>? cartDetails;
  String? carId;
  String? providerName;
  String? translatedProviderName;
  String? isAtDoorstepAvailable;
  String? isAtStoreAvailable;
  String? providerId;
  String? totalQuantity;
  String? subTotal;
  String? taxValue;
  String? overallAmount;
  String? promoCodeDiscountAmount;
  String? appliedPromoCodeName;
  String? isPayLaterAllowed;
  String? isOnlinePaymentAllowed;
  String? visitingCharges;
  String? advanceBookingDays;
  String? companyName;
  String? translatedCompanyName;
  String? subTotalWithoutTax;
  List<Cart>? otherCarts;
  String? finalTotal;
  List<Fees>? fees;
  String? totalServiceCount;
  String? totalProviderCount;
  String? totalOverallAmount;
  bool? isProviderVerified;
  String? providerImage;
  String? providerAddress;
  double? providerLatitude;
  double? providerLongitude;
  double? distance;
  TaxBreakdown? taxBreakdown;
  PricingLocation? pricingLocation;
  String? promoError;
  double? promoDiscount;
  double promoTaxReduction = 0;
  double taxTotal = 0;

  Cart({
    this.carId,
    this.cartDetails,
    this.providerName,
    this.translatedProviderName,
    this.providerId,
    this.totalQuantity,
    this.subTotal,
    this.taxValue,
    this.overallAmount,
    this.appliedPromoCodeName,
    this.promoCodeDiscountAmount,
    this.visitingCharges,
    this.advanceBookingDays,
    this.companyName,
    this.translatedCompanyName,
    this.isPayLaterAllowed,
    this.isAtDoorstepAvailable,
    this.isAtStoreAvailable,
    this.isOnlinePaymentAllowed,
    this.subTotalWithoutTax,
    this.otherCarts,
    this.fees,
    this.totalServiceCount,
    this.totalProviderCount,
    this.totalOverallAmount,
    this.isProviderVerified,
    this.providerImage,
  });

  Cart.fromJson(final Map<String, dynamic> json) {
    if (json['items'] != null && json['items'] is List) {
      cartDetails = <CartDetails>[];
      (json['items'] as List).forEach((final v) {
        cartDetails!.add(CartDetails.fromJson(v));
      });
    }
    if (json['fees'] != null && json['fees'] is List) {
      fees = <Fees>[];
      (json['fees'] as List).forEach((final v) {
        if (v is Map<String, dynamic>) {
          fees!.add(Fees.fromJson(v));
        }
      });
    }
    if (json['tax_breakdown'] is Map) {
      taxBreakdown = TaxBreakdown.fromJson(
        Map<String, dynamic>.from(json['tax_breakdown'] as Map),
      );
    }
    if (json['pricing_location'] is Map) {
      pricingLocation = PricingLocation.fromJson(
        Map<String, dynamic>.from(json['pricing_location'] as Map),
      );
    }
    promoError = json['promo_error']?.toString();
    if (json['promo'] is Map) {
      promoDiscount = double.tryParse(
        (json['promo'] as Map)['discount']?.toString() ?? '',
      );
    }
    promoTaxReduction = _toDouble(json['promo_tax_reduction']);
    taxTotal = _toDouble(json['tax_total']);
    carId = json["cart_id"]?.toString() ?? '';
    providerId = json['provider_id']?.toString() ?? '';
    providerName = json['provider_name']?.toString() ?? '';
    translatedProviderName = providerName;
    companyName = json['company_name']?.toString() ?? '';
    translatedCompanyName = companyName;
    totalQuantity = json['total_quantity']?.toString() ?? '';
    subTotal = json['sub_total']?.toString() ?? '';
    subTotalWithoutTax = json['sub_total_without_tax']?.toString() ?? '';
    taxValue = json['tax_value']?.toString() ?? '0.00';
    overallAmount = json['overall_amount']?.toString() ?? '';
    finalTotal = json['final_total']?.toString() ?? '';
    visitingCharges = json['visiting_charges']?.toString() ?? '';
    advanceBookingDays = json['advance_booking_days']?.toString() ?? '';
    isPayLaterAllowed = json['is_pay_later_allowed']?.toString() ?? '';
    isOnlinePaymentAllowed =
        json['is_online_payment_allowed']?.toString() ?? '';
    isAtStoreAvailable = json['at_store']?.toString() ?? '';
    isAtDoorstepAvailable = json['at_doorstep']?.toString() ?? '';
    isProviderVerified = json['is_provider_verified']?.toString() == "1";
    providerImage = json['provider_image']?.toString() ?? '';
    totalServiceCount = json['total_service_count']?.toString() ?? '';
    totalProviderCount = json['total_provider_count']?.toString() ?? '';
    totalOverallAmount = json['total_overall_amount']?.toString() ?? '';
    providerAddress = json['provider_address']?.toString() ?? '';
    providerLatitude = double.tryParse(
      json['provider_latitude']?.toString() ?? '',
    );
    providerLongitude = double.tryParse(
      json['provider_longitude']?.toString() ?? '',
    );
    distance = double.tryParse(json['distance']?.toString() ?? '');
    if (json['other_carts'] != null && json['other_carts'] is List) {
      otherCarts = <Cart>[];
      (json['other_carts'] as List).forEach((final v) {
        if (v is Map<String, dynamic>) {
          otherCarts!.add(Cart.fromJson(v));
        }
      });
    }
  }
}

extension CartPayable on Cart {
  /// True when the backend priced a promo into this cart (`promo` + discounted
  /// `final_total`), so the client must not subtract the discount again.
  bool get hasBackendPromo => promoDiscount != null;

  /// Amount to pay. `overall_amount` already includes service, visiting and fee
  /// tax but not the promo; `final_total` is after the promo. At-store
  /// bookings drop the visiting charge and its tax.
  double payableAmount({
    required final bool atStore,
    final bool withPromo = true,
  }) {
    final double overall = double.tryParse(overallAmount ?? '') ?? 0;
    final double afterPromo = double.tryParse(finalTotal ?? '') ?? overall;
    final double base = withPromo && hasBackendPromo ? afterPromo : overall;
    if (!atStore) return base;
    final double visiting = double.tryParse(visitingCharges ?? '') ?? 0;
    return base - visiting - (taxBreakdown?.visitingCharges?.totalTax ?? 0);
  }
}

class Fees {
  String? id;
  String? title;
  String? valueType;
  String? value;
  String? isRefundable;
  String? amount;
  bool isTaxable = false;
  String? taxAmount;

  Fees({
    this.id,
    this.title,
    this.valueType,
    this.value,
    this.isRefundable,
    this.amount,
    this.isTaxable = false,
    this.taxAmount,
  });

  Fees.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    valueType = json['value_type']?.toString() ?? '';
    value = json['value']?.toString() ?? '';
    isRefundable = json['is_refundable']?.toString() ?? '';
    amount = json['amount']?.toString() ?? '';
    isTaxable = json['is_taxable']?.toString() == '1';
    taxAmount = json['tax_amount']?.toString() ?? '0';
  }
}

/// `tax_breakdown` of a cart from `get_cart`: one entry per charge —
/// `services`, `visiting_charges` and `fee_<id>`.
class TaxBreakdown {
  TaxBreakdown.fromJson(final Map<String, dynamic> json)
    : groups = {
        for (final MapEntry e in json.entries)
          if (e.value is Map)
            e.key.toString(): TaxGroup.fromJson(
              Map<String, dynamic>.from(e.value as Map),
            ),
      };

  /// In response order.
  final Map<String, TaxGroup> groups;

  TaxGroup? get visitingCharges => groups['visiting_charges'];
}

class TaxGroup {
  TaxGroup.fromJson(final Map<String, dynamic> json)
    : title = json['title']?.toString() ?? '',
      baseAmount = _toDouble(json['base_amount']),
      totalTax = _toDouble(json['total_tax']),
      totalWithTax = _toDouble(json['total_with_tax']),
      taxType = json['tax_type']?.toString() ?? '',
      feePriceWithoutTax = _toDouble(json['fee_price_without_tax']),
      components = [
        for (final c in (json['tax_components'] as List? ?? []))
          if (c is Map) TaxComponent.fromJson(Map<String, dynamic>.from(c)),
      ];

  /// Translated by the backend.
  final String title;
  final double baseAmount;
  final double totalTax;

  /// Amount shown for the charge (tax included).
  final double totalWithTax;

  /// `included` (inside the price) or `excluded` (added on top).
  final String taxType;
  final double feePriceWithoutTax;
  final List<TaxComponent> components;
}

class TaxComponent {
  TaxComponent.fromJson(final Map<String, dynamic> json)
    : name = json['name']?.toString() ?? '',
      percentage = _toDouble(json['percentage']),
      amount = _toDouble(json['tax_amount'] ?? json['amount']);

  final String name;
  final double percentage;
  final double amount;
}

class PricingLocation {
  PricingLocation.fromJson(final Map<String, dynamic> json)
    : countryId = json['country_id']?.toString() ?? '',
      regionId = json['region_id']?.toString() ?? '',
      source = json['source']?.toString() ?? '';

  final String countryId;
  final String regionId;
  final String source;
}

double _toDouble(final dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

class CartDetails {
  String? id;
  String? serviceId;
  String? qty;
  Services? serviceDetails;

  CartDetails({this.id, this.serviceId, this.qty, this.serviceDetails});

  CartDetails.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    serviceId = json['service_id']?.toString() ?? '';
    qty = json['qty']?.toString() ?? '';
    serviceDetails = Services.fromJson({
      'id': json['service_id'],
      'title': json['service_title'],
      'translated_title': json['service_title'],
      'price': json['price'],
      'discounted_price': json['discounted_price'],
      'image': json['image_of_the_service'],
      'max_quantity_allowed': json['max_quantity_allowed'],
    });
  }
}
