class BidProvider {
  final int customJobId;
  final int providerId;
  final String companyName;
  final String? translatedProviderName;
  final String averageRating;
  final int totalRatings;
  final double? distance;
  final String counterPrice;
  final String duration;
  final String bidDate;
  final String message;
  final bool isVerified;
  final bool isPreBookingChatAllowed;
  final bool isPostBookingChatAllowed;
  final String? providerImage;
  final String? advanceBookingDays;
  final String? customJobRequestId;
  final String? taxId;
  final String? taxAmount;
  final String? taxPercentage;
  final String? visitingCharges;
  final String? atStore;
  final String? atDoorstep;
  final String? finalTotal;
  final String? providerAddress;
  final double? providerLatitude;
  final double? providerLongitude;
  final String? bookedOn;

  BidProvider({
    required this.customJobId,
    required this.providerId,
    required this.companyName,
    this.translatedProviderName,
    required this.averageRating,
    required this.totalRatings,
    this.distance,
    required this.counterPrice,
    required this.duration,
    required this.bidDate,
    required this.message,
    required this.isVerified,
    this.isPreBookingChatAllowed = true,
    this.isPostBookingChatAllowed = false,
    this.providerImage,
    this.advanceBookingDays,
    this.customJobRequestId,
    this.taxId,
    this.taxAmount,
    this.taxPercentage,
    this.visitingCharges,
    this.atStore,
    this.atDoorstep,
    this.finalTotal,
    this.providerAddress,
    this.providerLatitude,
    this.providerLongitude,
    this.bookedOn,
  });

  BidProvider.fromJson(Map<String, dynamic> json)
    : customJobId = _int(
        json['custom_job_id'] ?? json['custom_job_request_id'],
      ),
      providerId = _int(
        json['provider_id'] ?? json['partner_id'] ?? json['id'],
      ),
      companyName =
          json['company_name']?.toString() ??
          json['provider_name']?.toString() ??
          '',
      translatedProviderName =
          json['translated_provider_name']?.toString() ??
          json['company_name']?.toString() ??
          json['provider_name']?.toString(),
      averageRating =
          json['average_rating']?.toString() ??
          json['rating']?.toString() ??
          '0',
      totalRatings = _int(json['total_ratings'] ?? json['total_orders']),
      distance = json['distance'] == null
          ? null
          : double.tryParse(json['distance'].toString()),
      counterPrice =
          json['counter_price']?.toString() ??
          json['final_total']?.toString() ??
          '0',
      duration = json['duration']?.toString() ?? '0',
      bidDate =
          json['bid_date']?.toString() ?? json['created_at']?.toString() ?? '',
      message = json['message']?.toString() ?? json['note']?.toString() ?? '',
      isVerified =
          (json['is_provider_verified']?.toString() == '1') ||
          (json['is_verified']?.toString() == '1'),
      isPreBookingChatAllowed =
          (json['pre_booking_chat']?.toString() == '1') ||
          (json['pre_booking_chat'] == true),
      isPostBookingChatAllowed =
          (json['post_booking_chat']?.toString() == '1') ||
          (json['post_booking_chat'] == true),
      providerImage =
          json['provider_image']?.toString() ??
          json['image']?.toString() ??
          json['profile_image']?.toString(),
      advanceBookingDays = json['advance_booking_days']?.toString(),
      customJobRequestId =
          json['custom_job_request_id']?.toString() ??
          json['custom_job_id']?.toString(),
      taxId = json['tax_id']?.toString(),
      taxAmount = json['tax_amount']?.toString() ?? '0',
      taxPercentage = json['tax_percentage']?.toString() ?? '0',
      visitingCharges = json['visiting_charges']?.toString() ?? '0',
      atStore = json['at_store']?.toString() ?? '0',
      atDoorstep = json['at_doorstep']?.toString() ?? '0',
      finalTotal = json['final_total']?.toString(),
      providerAddress = json['address']?.toString(),
      providerLatitude = json['latitude'] == null
          ? null
          : double.tryParse(json['latitude'].toString()),
      providerLongitude = json['longitude'] == null
          ? null
          : double.tryParse(json['longitude'].toString()),
      bookedOn = json['date_time']?.toString();

  factory BidProvider.empty() => BidProvider(
    customJobId: 0,
    providerId: 0,
    companyName: '',
    averageRating: '0',
    totalRatings: 0,
    counterPrice: '0',
    duration: '0',
    bidDate: '',
    message: '',
    isVerified: false,
  );

  static int _int(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
}
