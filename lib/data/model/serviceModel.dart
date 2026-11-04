class Services {
  String? id;
  String? userId;
  String? categoryId;
  String? categoryName;
  String? partnerName;
  String? translatedPartnerName;
  String? title;
  String? translatedTitle;
  String? slug;
  String? description;
  String? translatedDescription;
  String? longDescription;
  String? translatedLongDescription;
  String? tags;
  String? imageOfTheService;
  List<String>? otherImagesOfTheService;
  String? price;
  String? discountedPrice;
  String? discountPercentage;
  String? currencySymbol;
  String? priceWithTax;
  String? originalPriceWithTax;
  String? taxAmount;
  String? numberOfMembersRequired;
  String? duration;
  String? durationType;
  String? averageRating;
  String? rating;
  String? numberOfRatings;
  String? maxQuantityAllowed;
  String? isPayLaterAllowed;
  String? status;
  String? oneStar;
  String? twoStar;
  String? threeStar;
  String? fourStar;
  String? fiveStar;
  String? companyName;
  bool? isProviderVerified;
  bool? isBookmarked;
  String? latitude;
  String? longitude;

  Services({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.partnerName,
    required this.translatedPartnerName,
    required this.title,
    required this.translatedTitle,
    required this.slug,
    required this.description,
    required this.translatedDescription,
    required this.tags,
    required this.imageOfTheService,
    required this.price,
    required this.discountedPrice,
    required this.originalPriceWithTax,
    required this.taxAmount,
    required this.priceWithTax,
    required this.numberOfMembersRequired,
    required this.duration,
    required this.rating,
    required this.averageRating,
    required this.numberOfRatings,
    required this.maxQuantityAllowed,
    required this.isPayLaterAllowed,
    required this.status,
    required this.longDescription,
    required this.translatedLongDescription,
    required this.otherImagesOfTheService,
    this.fiveStar,
    this.fourStar,
    this.threeStar,
    this.twoStar,
    this.oneStar,
    this.discountPercentage,
    this.currencySymbol,
    this.durationType,
    this.companyName,
    this.isProviderVerified,
    this.isBookmarked,
  });

  Services.fromJson(final Map<String?, dynamic> json) {
    id = json["id"]?.toString() ?? '';
    userId =
        json["userid"]?.toString() ?? json["provider_id"]?.toString() ?? '';
    categoryId = json["category_id"]?.toString() ?? '';
    categoryName = json["category_name"]?.toString() ?? '';
    partnerName = json["partner_name"]?.toString() ?? '';
    translatedPartnerName =
        (json["translated_partner_name"]?.toString() ?? '').isNotEmpty
        ? json["translated_partner_name"]!.toString()
        : partnerName;
    title = json["title"]?.toString() ?? '';
    translatedTitle = (json["translated_title"]?.toString() ?? '').isNotEmpty
        ? json["translated_title"]!.toString()
        : title;
    slug = json["slug"]?.toString() ?? '';
    description = json["description"]?.toString() ?? '';
    translatedDescription =
        (json["translated_description"]?.toString() ?? '').isNotEmpty
        ? json["translated_description"]!.toString()
        : description;

    imageOfTheService = json["image"]?.toString() ?? '';
    price = json["price"]?.toString() ?? '';
    discountedPrice = json["discounted_price"]?.toString() ?? '';
    discountPercentage = (json["discount_percentage"] ?? '0').toString();
    currencySymbol = json["currency_symbol"]?.toString() ?? '';
    originalPriceWithTax = json["original_price_with_tax"]?.toString() ?? '';
    taxAmount = json["tax_value"]?.toString() ?? '';
    priceWithTax = json["price_with_tax"]?.toString() ?? '';
    numberOfMembersRequired =
        json["number_of_members_required"]?.toString() ??
        json["number_of_members"]?.toString() ??
        '';
    duration = json["duration"]?.toString() ?? '0';
    durationType = json["duration_type"]?.toString() ?? '';
    averageRating = (json["average_rating"] ?? '0').toString();
    rating = (json["rating"] ?? '0').toString();
    numberOfRatings = (json["number_of_ratings"] ?? '0').toString();
    maxQuantityAllowed = json["max_quantity_allowed"]?.toString() ?? '0';
    status = json["status"]?.toString() ?? '';
    longDescription = json["long_description"]?.toString() ?? '';
    translatedLongDescription =
        (json["translated_long_description"]?.toString() ?? '').isNotEmpty
        ? json["translated_long_description"]!.toString()
        : longDescription;

    oneStar = (json["rating_1"] ?? '0').toString();
    twoStar = (json["rating_2"] ?? '0').toString();
    threeStar = (json["rating_3"] ?? '0').toString();
    fourStar = (json["rating_4"] ?? '0').toString();
    fiveStar = (json["rating_5"] ?? '0').toString();
    companyName =
        json["company_name"]?.toString() ??
        json["provider_company_name"]?.toString() ??
        '';
    isProviderVerified = json["is_provider_verified"]?.toString() == '1';
    isBookmarked = json["is_bookmarked"]?.toString() == '1';
    latitude = json["latitude"]?.toString();
    longitude = json["longitude"]?.toString();

    if (json["other_images"] != null &&
        json['other_images'] != '' &&
        json["other_images"] is List) {
      otherImagesOfTheService = <String>[];
      (json["other_images"] as List).forEach((final v) {
        otherImagesOfTheService!.add(v);
      });
    } else {
      otherImagesOfTheService = <String>[];
    }
  }
}

class ServiceCategoryGroup {
  ServiceCategoryGroup({
    required this.categoryId,
    required this.categoryName,
    required this.totalServices,
    required this.services,
  });

  factory ServiceCategoryGroup.fromJson(final Map<String, dynamic> json) =>
      ServiceCategoryGroup(
        categoryId: json["category_id"]?.toString() ?? '',
        categoryName: json["category_name"]?.toString() ?? '',
        totalServices:
            int.tryParse(json["total_services"]?.toString() ?? '0') ?? 0,
        services: ((json["services"] as List?) ?? [])
            .map((final e) => Services.fromJson(Map.from(e)))
            .toList(),
      );

  final String categoryId;
  final String categoryName;
  final int totalServices;
  final List<Services> services;

  ServiceCategoryGroup copyWith({final List<Services>? services}) =>
      ServiceCategoryGroup(
        categoryId: categoryId,
        categoryName: categoryName,
        totalServices: totalServices,
        services: services ?? this.services,
      );
}
