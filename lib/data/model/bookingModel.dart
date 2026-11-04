///Models for get_all_bookings (bucketed list) and get_booking_details (single booking)
import 'package:e_demand/data/model/cartModel.dart';

class BookingBuckets {
  List<BookingListItem>? ongoingBookings;
  List<BookingListItem>? upcomingBookings;
  List<BookingListItem>? completedBookings;
  List<BookingListItem>? cancelledBookings;

  BookingBuckets({
    this.ongoingBookings,
    this.upcomingBookings,
    this.completedBookings,
    this.cancelledBookings,
  });

  BookingBuckets.fromJson(final Map<String, dynamic> json) {
    if (json['ongoing_bookings'] != null) {
      ongoingBookings = <BookingListItem>[];
      json['ongoing_bookings'].forEach((final v) {
        ongoingBookings!.add(BookingListItem.fromJson(v));
      });
    }
    if (json['upcoming_bookings'] != null) {
      upcomingBookings = <BookingListItem>[];
      json['upcoming_bookings'].forEach((final v) {
        upcomingBookings!.add(BookingListItem.fromJson(v));
      });
    }
    if (json['completed_bookings'] != null) {
      completedBookings = <BookingListItem>[];
      json['completed_bookings'].forEach((final v) {
        completedBookings!.add(BookingListItem.fromJson(v));
      });
    }
    if (json['cancelled_bookings'] != null) {
      cancelledBookings = <BookingListItem>[];
      json['cancelled_bookings'].forEach((final v) {
        cancelledBookings!.add(BookingListItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (ongoingBookings != null) {
      data['ongoing_bookings'] = ongoingBookings!
          .map((v) => v.toJson())
          .toList();
    }
    if (upcomingBookings != null) {
      data['upcoming_bookings'] = upcomingBookings!
          .map((v) => v.toJson())
          .toList();
    }
    if (completedBookings != null) {
      data['completed_bookings'] = completedBookings!
          .map((v) => v.toJson())
          .toList();
    }
    if (cancelledBookings != null) {
      data['cancelled_bookings'] = cancelledBookings!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }

  List<BookingListItem> get allBookings => [
    ...?ongoingBookings,
    ...?upcomingBookings,
    ...?completedBookings,
    ...?cancelledBookings,
  ];
}

class BookingListItem {
  BookingListItem({
    this.id,
    this.status,
    this.startDate,
    this.startTime,
    this.serviceName,
    this.otherServicesCount,
    this.finalTotal,
    this.currencySymbol,
    this.currencyDecimalPlaces,
    this.provider,
    this.averageRating,
    this.isReorderAllowed,
    this.isCustomJobRequest = false,
  });

  BookingListItem.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    status = json['status']?.toString() ?? '';
    startDate = json['start_date']?.toString() ?? '';
    startTime = json['start_time']?.toString() ?? '';
    serviceName = json['service_name']?.toString() ?? '';
    otherServicesCount =
        int.tryParse(json['other_services_count']?.toString() ?? '') ?? 0;
    finalTotal = json['final_total']?.toString() ?? '';
    currencySymbol = json['currency_symbol']?.toString() ?? '';
    currencyDecimalPlaces = int.tryParse(
      json['currency_decimal_places']?.toString() ?? '',
    );
    if (json['provider'] != null) {
      provider = BookingListProvider.fromJson(json['provider']);
    }
    averageRating =
        json['rating']?.toString() ?? json['average_rating']?.toString();
    isReorderAllowed =
        json['is_reorder_allowed'] == true ||
        json['is_reorder_allowed']?.toString() == '1';
    isCustomJobRequest = json['custom_job_request'] != null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['status'] = status;
    data['start_date'] = startDate;
    data['start_time'] = startTime;
    data['service_name'] = serviceName;
    data['other_services_count'] = otherServicesCount;
    data['final_total'] = finalTotal;
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    data['rating'] = averageRating;
    data['is_reorder_allowed'] = isReorderAllowed;
    return data;
  }

  String? id;
  String? status;
  String? startDate;
  String? startTime;
  String? serviceName;
  int? otherServicesCount;
  String? finalTotal;
  String? currencySymbol;
  int? currencyDecimalPlaces;
  BookingListProvider? provider;
  String? averageRating;
  bool? isReorderAllowed;
  bool isCustomJobRequest = false;
}

class BookingListProvider {
  BookingListProvider({
    this.providerId,
    this.companyName,
    this.isProviderVerified,
    this.postBookingAllowed,
    this.profileImage,
  });

  BookingListProvider.fromJson(final Map<String, dynamic> json) {
    providerId = json['provider_id']?.toString() ?? '';
    companyName = json['company_name']?.toString() ?? '';
    isProviderVerified =
        json['is_provider_verified'] == true ||
        json['is_provider_verified']?.toString() == '1';
    postBookingAllowed =
        json['post_booking_allowed'] == true ||
        json['post_booking_allowed']?.toString() == '1';
    profileImage =
        json['profile_image']?.toString() ?? json['provider_image']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['provider_id'] = providerId;
    data['company_name'] = companyName;
    data['is_provider_verified'] = isProviderVerified;
    data['post_booking_allowed'] = postBookingAllowed;
    data['profile_image'] = profileImage;
    return data;
  }

  String? providerId;
  String? companyName;
  bool? isProviderVerified;
  bool? postBookingAllowed;
  String? profileImage;
}

class BookingDetailModel {
  BookingDetailModel({
    this.id,
    this.status,
    this.date,
    this.startTime,
    this.endTime,
    this.bookingType,
    this.address,
    this.addressId,
    this.services,
    this.serviceStatusTimeline,
    this.nextStatusAvailable,
    this.provider,
    this.assignedHandymen,
    this.totalServicesCount,
    this.ratedServicesCount,
    this.ratedHandymenCount,
    this.totalHandymenCount,
    this.baseTotal,
    this.visitingCharges,
    this.visitingChargesTax,
    this.promoCode,
    this.promoDiscount,
    this.promoTaxReduction,
    this.paymentMethod,
    this.paymentStatus,
    this.tax,
    this.finalTotal,
    this.currencySymbol,
    this.currencyDecimalPlaces,
    this.fees,
    this.additionalCharges,
    this.additionalChargesPaymentMethod,
    this.additionalChargesPaymentStatus,
    this.workStartedProof,
    this.workCompletedProof,
    this.cancellation,
    this.otp,
    this.multipleDaysBooking,
    this.isReorderAllowed,
    this.isPayLaterAllowed,
    this.isCancelable,
    this.remarks,
    this.liveTrackingStarted,
    this.customJobRequest,
  });

  BookingDetailModel.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    status = json['status']?.toString() ?? '';
    date = json['date']?.toString() ?? '';
    startTime = json['start_time']?.toString() ?? '';
    endTime = json['end_time']?.toString() ?? '';
    bookingType = json['booking_type']?.toString() ?? '';
    otp = json['otp']?.toString();
    isReorderAllowed =
        json['is_reorder_allowed'] == true ||
        json['is_reorder_allowed']?.toString() == '1';
    isPayLaterAllowed =
        json['is_pay_later_allowed'] == true ||
        json['is_pay_later_allowed']?.toString() == '1';
    isCancelable =
        json['is_cancelable'] == true ||
        json['is_cancelable']?.toString() == '1';
    remarks = json['remarks']?.toString() ?? '';
    liveTrackingStarted =
        json['live_tracking_started'] == true ||
        json['live_tracking_started']?.toString() == '1';
    if (json['custom_job_request'] != null) {
      customJobRequest = BookingCustomJobRequest.fromJson(
        json['custom_job_request'],
      );
    }
    if (json['multiple_days_booking'] != null) {
      multipleDaysBooking = MultipleDaysBookingRange.fromJson(
        json['multiple_days_booking'],
      );
    }
    address = json['address']?.toString() ?? '';
    addressId = json['address_id']?.toString() ?? '';
    totalServicesCount =
        int.tryParse(json['total_services_count']?.toString() ?? '') ?? 0;
    ratedServicesCount =
        int.tryParse(json['rated_services_count']?.toString() ?? '') ?? 0;
    ratedHandymenCount =
        int.tryParse(json['rated_handymen_count']?.toString() ?? '') ?? 0;
    totalHandymenCount =
        int.tryParse(json['total_handymen_count']?.toString() ?? '') ?? 0;
    baseTotal = json['base_total']?.toString() ?? '';
    visitingCharges = json['visiting_charges']?.toString() ?? '';
    visitingChargesTax = json['visiting_charges_tax']?.toString() ?? '0';
    promoCode = json['promo_code']?.toString() ?? '';
    promoDiscount = json['promo_discount']?.toString() ?? '';
    promoTaxReduction = json['promo_tax_reduction']?.toString() ?? '0';
    paymentMethod = json['payment_method']?.toString() ?? '';
    paymentStatus = json['payment_status']?.toString() ?? '';
    finalTotal = json['final_total']?.toString() ?? '';
    currencySymbol = json['currency_symbol']?.toString() ?? '';
    currencyDecimalPlaces = int.tryParse(
      json['currency_decimal_places']?.toString() ?? '',
    );
    additionalChargesPaymentMethod =
        json['additional_charges_payment_method']?.toString() ?? '';
    additionalChargesPaymentStatus =
        json['additional_charges_payment_status']?.toString() ?? '';
    workStartedProof =
        (json['work_started_proof'] as List?)
            ?.map((final e) => e.toString())
            .toList() ??
        [];
    workCompletedProof =
        (json['work_completed_proof'] as List?)
            ?.map((final e) => e.toString())
            .toList() ??
        [];
    nextStatusAvailable =
        (json['next_status_available'] as List?)
            ?.map((final e) => e.toString())
            .toList() ??
        [];

    if (json['services'] != null) {
      services = <BookingDetailsService>[];
      json['services'].forEach((final v) {
        services!.add(BookingDetailsService.fromJson(v));
      });
    }
    if (json['service_status_timeline'] != null) {
      serviceStatusTimeline = <ServiceStatusTimelineEntry>[];
      json['service_status_timeline'].forEach((final v) {
        serviceStatusTimeline!.add(ServiceStatusTimelineEntry.fromJson(v));
      });
    }
    if (json['provider'] != null) {
      provider = BookingDetailsProvider.fromJson(json['provider']);
    }
    if (json['assigned_handymen'] != null) {
      assignedHandymen = <BookingAssignedHandyman>[];
      json['assigned_handymen'].forEach((final v) {
        assignedHandymen!.add(BookingAssignedHandyman.fromJson(v));
      });
    }
    if (json['tax'] != null) {
      tax = BookingTax.fromJson(json['tax']);
    }
    if (json['fees'] != null) {
      fees = <BookingFee>[];
      json['fees'].forEach((final v) {
        fees!.add(BookingFee.fromJson(v));
      });
    }
    if (json['additional_charges'] != null) {
      additionalCharges = <BookingAdditionalCharge>[];
      json['additional_charges'].forEach((final v) {
        additionalCharges!.add(BookingAdditionalCharge.fromJson(v));
      });
    }
    if (json['cancellation'] != null) {
      cancellation = BookingCancellation.fromJson(json['cancellation']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['status'] = status;
    data['date'] = date;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['booking_type'] = bookingType;
    data['address'] = address;
    data['address_id'] = addressId;
    data['total_services_count'] = totalServicesCount;
    data['rated_services_count'] = ratedServicesCount;
    data['rated_handymen_count'] = ratedHandymenCount;
    data['total_handymen_count'] = totalHandymenCount;
    data['base_total'] = baseTotal;
    data['visiting_charges'] = visitingCharges;
    data['visiting_charges_tax'] = visitingChargesTax;
    data['promo_code'] = promoCode;
    data['promo_discount'] = promoDiscount;
    data['promo_tax_reduction'] = promoTaxReduction;
    data['payment_method'] = paymentMethod;
    data['payment_status'] = paymentStatus;
    data['final_total'] = finalTotal;
    data['additional_charges_payment_method'] = additionalChargesPaymentMethod;
    data['additional_charges_payment_status'] = additionalChargesPaymentStatus;
    data['work_started_proof'] = workStartedProof;
    data['work_completed_proof'] = workCompletedProof;
    data['next_status_available'] = nextStatusAvailable;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    if (serviceStatusTimeline != null) {
      data['service_status_timeline'] = serviceStatusTimeline!
          .map((v) => v.toJson())
          .toList();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    if (assignedHandymen != null) {
      data['assigned_handymen'] = assignedHandymen!
          .map((v) => v.toJson())
          .toList();
    }
    if (tax != null) {
      data['tax'] = tax!.toJson();
    }
    if (fees != null) {
      data['fees'] = fees!.map((v) => v.toJson()).toList();
    }
    if (additionalCharges != null) {
      data['additional_charges'] = additionalCharges!
          .map((v) => v.toJson())
          .toList();
    }
    if (cancellation != null) {
      data['cancellation'] = cancellation!.toJson();
    }
    data['otp'] = otp;
    data['is_reorder_allowed'] = isReorderAllowed;
    data['is_pay_later_allowed'] = isPayLaterAllowed;
    data['is_cancelable'] = isCancelable;
    data['remarks'] = remarks;
    data['live_tracking_started'] = liveTrackingStarted;
    if (customJobRequest != null) {
      data['custom_job_request'] = customJobRequest!.toJson();
    }
    if (multipleDaysBooking != null) {
      data['multiple_days_booking'] = multipleDaysBooking!.toJson();
    }
    return data;
  }

  String? id;
  String? status;
  String? date;
  String? startTime;
  String? endTime;
  String? bookingType;
  String? address;
  String? addressId;
  List<BookingDetailsService>? services;
  List<ServiceStatusTimelineEntry>? serviceStatusTimeline;
  List<String>? nextStatusAvailable;
  BookingDetailsProvider? provider;
  List<BookingAssignedHandyman>? assignedHandymen;
  int? totalServicesCount;
  int? ratedServicesCount;
  int? ratedHandymenCount;
  int? totalHandymenCount;
  String? baseTotal;
  String? otp;
  MultipleDaysBookingRange? multipleDaysBooking;
  bool? isReorderAllowed;
  bool? isPayLaterAllowed;
  bool? isCancelable;
  String? remarks;
  bool? liveTrackingStarted;
  BookingCustomJobRequest? customJobRequest;

  bool get isCustomJobRequest => customJobRequest != null;
  String? visitingCharges;
  String? visitingChargesTax;
  String? promoCode;
  String? promoDiscount;
  String? promoTaxReduction;
  String? paymentMethod;
  String? paymentStatus;
  BookingTax? tax;
  String? finalTotal;
  String? currencySymbol;
  int? currencyDecimalPlaces;
  List<BookingFee>? fees;
  List<BookingAdditionalCharge>? additionalCharges;
  String? additionalChargesPaymentMethod;
  String? additionalChargesPaymentStatus;
  List<String>? workStartedProof;
  List<String>? workCompletedProof;
  BookingCancellation? cancellation;
}

class BookingCustomJobRequest {
  BookingCustomJobRequest({
    this.id,
    this.providerBidNote,
    this.customerJobDescription,
  });

  BookingCustomJobRequest.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    providerBidNote = json['provider_bid_note']?.toString() ?? '';
    customerJobDescription = json['customer_job_description']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['provider_bid_note'] = providerBidNote;
    data['customer_job_description'] = customerJobDescription;
    return data;
  }

  String? id;
  String? providerBidNote;
  String? customerJobDescription;
}

class BookingDetailsService {
  BookingDetailsService({
    this.serviceId,
    this.title,
    this.categoryName,
    this.quantity,
    this.price,
    this.image,
    this.ratingId,
    this.rating,
    this.review,
    this.reviewImages,
  });

  BookingDetailsService copyWith({
    String? serviceId,
    String? title,
    String? categoryName,
    String? quantity,
    String? price,
    String? image,
    String? ratingId,
    int? rating,
    String? review,
    List<String>? reviewImages,
  }) => BookingDetailsService(
    serviceId: serviceId ?? this.serviceId,
    title: title ?? this.title,
    categoryName: categoryName ?? this.categoryName,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    image: image ?? this.image,
    ratingId: ratingId ?? this.ratingId,
    rating: rating ?? this.rating,
    review: review ?? this.review,
    reviewImages: reviewImages ?? this.reviewImages,
  );

  BookingDetailsService.fromJson(final Map<String, dynamic> json) {
    serviceId = json['service_id']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    categoryName = json['category_name']?.toString() ?? '';
    quantity = json['quantity']?.toString() ?? '';
    price = json['price']?.toString() ?? '';
    image = json['image']?.toString() ?? '';
    ratingId = json['rating_id']?.toString() ?? '';
    rating = int.tryParse(json['rating']?.toString() ?? '');
    review = json['review']?.toString() ?? '';
    reviewImages =
        (json['review_images'] as List?)
            ?.map((final e) => e.toString())
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['service_id'] = serviceId;
    data['title'] = title;
    data['category_name'] = categoryName;
    data['quantity'] = quantity;
    data['price'] = price;
    data['image'] = image;
    data['rating_id'] = ratingId;
    data['rating'] = rating;
    data['review'] = review;
    data['review_images'] = reviewImages;
    return data;
  }

  String? serviceId;
  String? title;
  String? categoryName;
  String? quantity;
  String? price;
  String? image;
  String? ratingId;
  int? rating;
  String? review;
  List<String>? reviewImages;

  bool get hasReview => rating != null && rating! > 0;
}

class ServiceStatusTimelineEntry {
  ServiceStatusTimelineEntry({this.status, this.timestamp});

  ServiceStatusTimelineEntry.fromJson(final Map<String, dynamic> json) {
    status = json['status']?.toString() ?? '';
    timestamp = json['timestamp']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['timestamp'] = timestamp;
    return data;
  }

  String? status;
  String? timestamp;
}

class BookingDetailsProvider {
  BookingDetailsProvider({
    this.providerId,
    this.companyName,
    this.profileImage,
    this.averageRating,
    this.distance,
    this.postBookingChat,
    this.isVerified,
    this.countryCode,
    this.phone,
    this.latitude,
    this.longitude,
    this.advanceBookingDays,
  });

  BookingDetailsProvider.fromJson(final Map<String, dynamic> json) {
    providerId = json['provider_id']?.toString() ?? '';
    companyName = json['company_name']?.toString() ?? '';
    profileImage = json['profile_image']?.toString() ?? '';
    averageRating = json['average_rating']?.toString() ?? '';
    distance = json['distance']?.toString() ?? '';
    postBookingChat =
        json['post_booking_chat'] == true ||
        json['post_booking_chat']?.toString() == '1';
    isVerified =
        json['is_verified'] == true || json['is_verified']?.toString() == '1';
    countryCode = json['country_code']?.toString() ?? '';
    phone = json['phone']?.toString() ?? '';
    latitude = json['latitude']?.toString() ?? '';
    longitude = json['longitude']?.toString() ?? '';
    advanceBookingDays = json['advance_booking_days']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['provider_id'] = providerId;
    data['company_name'] = companyName;
    data['profile_image'] = profileImage;
    data['average_rating'] = averageRating;
    data['distance'] = distance;
    data['post_booking_chat'] = postBookingChat;
    data['is_verified'] = isVerified;
    data['country_code'] = countryCode;
    data['phone'] = phone;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['advance_booking_days'] = advanceBookingDays;
    return data;
  }

  String? providerId;
  String? companyName;
  String? profileImage;
  String? averageRating;
  String? distance;
  bool? postBookingChat;
  bool? isVerified;
  String? countryCode;
  String? phone;
  String? latitude;
  String? longitude;
  String? advanceBookingDays;
}

class BookingAssignedHandyman {
  BookingAssignedHandyman({
    this.id,
    this.username,
    this.profileImage,
    this.isLead,
    this.ratingId,
    this.rating,
    this.review,
    this.reviewImages,
  });

  BookingAssignedHandyman.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    username = json['username']?.toString() ?? '';
    profileImage = json['profile_image']?.toString() ?? '';
    isLead = int.tryParse(json['is_lead'].toString()) ?? 0;
    ratingId = json['rating_id']?.toString() ?? '';
    rating = int.tryParse(json['rating']?.toString() ?? '');
    review = json['review']?.toString() ?? '';
    reviewImages =
        (json['review_images'] as List?)
            ?.map((final e) => e.toString())
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['username'] = username;
    data['profile_image'] = profileImage;
    data['is_lead'] = isLead;
    data['rating_id'] = ratingId;
    data['rating'] = rating;
    data['review'] = review;
    data['review_images'] = reviewImages;
    return data;
  }

  String? id;
  String? username;
  String? profileImage;
  int? isLead;
  String? ratingId;
  int? rating;
  String? review;
  List<String>? reviewImages;

  bool get isLeadHandyman => isLead == 1;

  bool get hasReview => rating != null && rating! > 0;
}

class BookingTax {
  BookingTax({this.taxType, this.taxAmount, this.breakdown});

  BookingTax.fromJson(final Map<String, dynamic> json) {
    taxType = json['tax_type']?.toString() ?? '';
    taxAmount = json['tax_amount']?.toString() ?? '';
    if (json['breakdown'] is Map) {
      breakdown = TaxBreakdown.fromJson(
        Map<String, dynamic>.from(json['breakdown'] as Map),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['tax_type'] = taxType;
    data['tax_amount'] = taxAmount;
    return data;
  }

  String? taxType;
  String? taxAmount;
  TaxBreakdown? breakdown;

  bool get isIncluded => taxType == 'included';
}

class BookingFee {
  int? id;
  int? feeId;
  String? title;
  String? valueType;
  String? value;
  String? calculatedAmount;
  int? isRefundable;
  bool isTaxable = false;
  String? taxAmount;

  BookingFee({
    this.id,
    this.feeId,
    this.title,
    this.valueType,
    this.value,
    this.calculatedAmount,
    this.isRefundable,
    this.isTaxable = false,
    this.taxAmount,
  });

  BookingFee.fromJson(final Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    feeId = int.tryParse(json['fee_id']?.toString() ?? '');
    title = json['title']?.toString() ?? '';
    valueType = json['value_type']?.toString() ?? '';
    value = json['value']?.toString() ?? '';
    calculatedAmount = json['calculated_amount']?.toString() ?? '';
    isRefundable = int.tryParse(json['is_refundable']?.toString() ?? '0') ?? 0;
    isTaxable = json['is_taxable']?.toString() == '1';
    taxAmount = json['tax_amount']?.toString() ?? '0';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['fee_id'] = feeId;
    data['title'] = title;
    data['value_type'] = valueType;
    data['value'] = value;
    data['calculated_amount'] = calculatedAmount;
    data['is_refundable'] = isRefundable;
    data['is_taxable'] = isTaxable ? 1 : 0;
    data['tax_amount'] = taxAmount;
    return data;
  }
}

class BookingAdditionalCharge {
  String? name;
  String? charge;

  BookingAdditionalCharge({this.name, this.charge});

  BookingAdditionalCharge.fromJson(final Map<String, dynamic> json) {
    name = json['name']?.toString() ?? '';
    charge = json['charge']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['charge'] = charge;
    return data;
  }
}

class BookingCancellation {
  String? cancelReasonId;
  String? cancelReason;
  String? cancelAdditionalInfo;
  String? cancelledAt;

  BookingCancellation({
    this.cancelReasonId,
    this.cancelReason,
    this.cancelAdditionalInfo,
    this.cancelledAt,
  });

  BookingCancellation.fromJson(final Map<String, dynamic> json) {
    cancelReasonId = json['cancel_reason_id']?.toString() ?? '';
    cancelReason = json['reason']?.toString() ?? '';
    cancelAdditionalInfo = json['additional_info']?.toString() ?? '';
    cancelledAt = json['cancelled_at']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cancel_reason_id'] = cancelReasonId;
    data['reason'] = cancelReason;
    data['additional_info'] = cancelAdditionalInfo;
    data['cancelled_at'] = cancelledAt;
    return data;
  }
}

class MultipleDaysBookingRange {
  MultipleDaysBookingRange({
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  MultipleDaysBookingRange.fromJson(final Map<String, dynamic> json) {
    startDate = json['start_date']?.toString() ?? '';
    endDate = json['end_date']?.toString() ?? '';
    startTime = json['start_time']?.toString() ?? '';
    endTime = json['end_time']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }

  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
}
