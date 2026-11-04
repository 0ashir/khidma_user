String _normalizeFlag(final dynamic value) =>
    (value == true || value == 1 || value == '1' || value == 'true')
    ? '1'
    : '0';

class ServiceDetailsModel {
  String? id;
  String? slug;
  String? title;
  String? shortDescription;
  String? description;
  String? numberOfMembersRequired;
  String? duration;
  String? durationType;
  String? totalBookings;
  String? price;
  String? discountedPrice;
  String? discountPercentage;
  String? currencySymbol;
  String? image;
  List<String> otherImages;
  List<String> files;
  List<String> whatsIncluded;
  List<String> whatsExcluded;
  List<String> tags;
  List<ServiceFaQs> faqs;
  String? averageRating;
  String? numberOfRatings;
  Map<String, int> ratingBreakdown;
  String? isBookmarked;
  String? atDoorstep;
  String? atStore;
  String? isCancellable;
  String? payLater;
  String? maxQuantityAllowed;
  ServiceDetailsProvider? provider;
  ServiceDetailsCategory? category;
  List<RelatedService> relatedServices;

  ServiceDetailsModel.fromJson(final Map<String, dynamic> json)
    : id = json["id"]?.toString() ?? '',
      slug = json["slug"]?.toString() ?? '',
      title = json["title"]?.toString() ?? '',
      shortDescription = json["short_description"]?.toString() ?? '',
      description = json["description"]?.toString() ?? '',
      numberOfMembersRequired =
          json["number_of_members_required"]?.toString() ?? '',
      duration = json["duration"]?.toString() ?? '',
      durationType = json["duration_type"]?.toString() ?? '',
      totalBookings = json["total_bookings"]?.toString() ?? '0',
      price = json["price"]?.toString() ?? '',
      discountedPrice = json["discounted_price"]?.toString() ?? '0',
      discountPercentage = json["discount_percentage"]?.toString() ?? '0',
      currencySymbol = json["currency_symbol"]?.toString() ?? '',
      image = json["image"]?.toString() ?? '',
      otherImages = ((json["other_images"] as List?) ?? [])
          .map((final v) => v.toString())
          .toList(),
      files = ((json["files"] as List?) ?? [])
          .map((final v) => v.toString())
          .toList(),
      whatsIncluded = ((json["whats_included"] as List?) ?? [])
          .map((final v) => v.toString())
          .toList(),
      whatsExcluded = ((json["whats_excluded"] as List?) ?? [])
          .map((final v) => v.toString())
          .toList(),
      tags = ((json["tags"] as List?) ?? [])
          .map((final v) => v.toString())
          .toList(),
      faqs = ((json["faqs"] as List?) ?? [])
          .map((final v) => ServiceFaQs.fromJson(Map.from(v as Map)))
          .toList(),
      averageRating = (json["average_rating"] ?? '0').toString(),
      numberOfRatings = (json["number_of_ratings"] ?? '0').toString(),
      ratingBreakdown = ((json["rating_breakdown"] as Map?) ?? {}).map(
        (final key, final value) =>
            MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0),
      ),
      isBookmarked = _normalizeFlag(json["is_bookmarked"]),
      atDoorstep = (json["at_doorstep"] ?? '0').toString(),
      atStore = (json["at_store"] ?? '0').toString(),
      isCancellable = (json["is_cancellable"] ?? '0').toString(),
      payLater = (json["pay_later"] ?? '0').toString(),
      maxQuantityAllowed = json["max_quantity_allowed"]?.toString() ?? '10',
      provider = json["provider"] != null
          ? ServiceDetailsProvider.fromJson(Map.from(json["provider"] as Map))
          : null,
      category = json["category"] != null
          ? ServiceDetailsCategory.fromJson(Map.from(json["category"] as Map))
          : null,
      relatedServices = ((json["related_services"] as List?) ?? [])
          .map((final v) => RelatedService.fromJson(Map.from(v as Map)))
          .toList();
}

class ServiceDetailsProvider {
  String? id;
  String? slug;
  String? isVerified;
  String? companyName;
  String? about;
  String? phone;
  String? countryCode;
  String? email;
  String? averageRating;
  String? numberOfRatings;
  String? image;
  String? preBookingChatAllowed;
  String? distance;

  ServiceDetailsProvider.fromJson(final Map<String, dynamic> json)
    : id = json["id"]?.toString() ?? '',
      slug = json["slug"]?.toString() ?? '',
      isVerified = json["is_verified"]?.toString() ?? '0',
      companyName = json["company_name"]?.toString() ?? '',
      about = json["about"]?.toString() ?? '',
      phone = json["phone"]?.toString() ?? '',
      countryCode = json["country_code"]?.toString() ?? '',
      email = json["email"]?.toString() ?? '',
      averageRating = (json["average_rating"] ?? '0').toString(),
      numberOfRatings = (json["number_of_ratings"] ?? '0').toString(),
      image = json["image"]?.toString() ?? '',
      preBookingChatAllowed = (json["pre_booking_chat_allowed"] ?? '0')
          .toString(),
      distance = json["distance"]?.toString() ?? '0';
}

class ServiceDetailsCategory {
  String? id;
  String? name;
  String? slug;

  ServiceDetailsCategory.fromJson(final Map<String, dynamic> json)
    : id = json["id"]?.toString() ?? '',
      name = json["name"]?.toString() ?? '',
      slug = json["slug"]?.toString() ?? '';
}

class RelatedService {
  String? id;
  String? slug;
  String? title;
  String? description;
  String? image;
  String? categoryId;
  String? categoryName;
  String? price;
  String? discountedPrice;
  String? discountPercentage;
  String? currencySymbol;
  String? duration;
  String? durationType;
  String? numberOfMembersRequired;
  String? averageRating;
  String? numberOfRatings;
  String? companyName;
  String? isProviderVerified;
  String? isBookmarked;

  RelatedService.fromJson(final Map<String, dynamic> json)
    : id = json["id"]?.toString() ?? '',
      slug = json["slug"]?.toString() ?? '',
      title = json["title"]?.toString() ?? '',
      description = json["description"]?.toString() ?? '',
      image = json["image"]?.toString() ?? '',
      categoryId = json["category_id"]?.toString() ?? '',
      categoryName = json["category_name"]?.toString() ?? '',
      price = json["price"]?.toString() ?? '',
      discountedPrice = json["discounted_price"]?.toString() ?? '0',
      discountPercentage = json["discount_percentage"]?.toString() ?? '0',
      currencySymbol = json["currency_symbol"]?.toString() ?? '',
      duration = json["duration"]?.toString() ?? '',
      durationType = json["duration_type"]?.toString() ?? '',
      numberOfMembersRequired =
          json["number_of_members_required"]?.toString() ?? '',
      averageRating = (json["average_rating"] ?? '0').toString(),
      numberOfRatings = (json["number_of_ratings"] ?? '0').toString(),
      companyName = json["company_name"]?.toString() ?? '',
      isProviderVerified = _normalizeFlag(json["is_provider_verified"]),
      isBookmarked = _normalizeFlag(json["is_bookmarked"]);
}

class ServiceFaQs {
  String? question;
  String? answer;

  ServiceFaQs({this.question, this.answer});

  factory ServiceFaQs.fromJson(Map<String, dynamic> json) => ServiceFaQs(
    question: json["question"]?.toString() ?? '',
    answer: json["answer"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {"question": question, "answer": answer};
}
