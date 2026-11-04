import 'package:e_demand/app/generalImports.dart';

class ProviderDetailsModel {
  String? partnerId;
  String? slug;
  String? companyName;
  bool? isVerified;
  String? numberOfOrders;
  String? about;
  String? longDescription;
  String? averageRating;
  String? numberOfRatings;
  Map<String, int> ratingBreakdown;
  String? distance;
  String? countryCode;
  String? phone;
  String? email;
  Map<String, DayShifts> shiftsByDay;
  String? address;
  String? banner;
  List<String> otherImages;
  String? preBookingChatAllowed;
  String? image;
  String? isBookmark;
  String? isAtStoreAvailable;
  String? isAtDoorstepAvailable;
  String? totalServices;
  String? providerType;

  ProviderDetailsModel.fromJson(final Map<String, dynamic> json)
    : partnerId = json["partner_id"]?.toString() ?? '',
      slug = json["slug"]?.toString() ?? '',
      companyName = json["company_name"]?.toString() ?? '',
      isVerified = json["is_verified"]?.toString() == "1",
      numberOfOrders = json["number_of_orders"]?.toString() ?? '0',
      about = json["about"]?.toString() ?? '',
      longDescription = json["long_description"]?.toString() ?? '',
      averageRating = json["average_rating"]?.toString() ?? '0',
      numberOfRatings = json["number_of_ratings"]?.toString() ?? '0',
      ratingBreakdown = ((json["rating_breakdown"] as Map?) ?? {}).map(
        (final key, final value) =>
            MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0),
      ),
      distance = json["distance"]?.toString() ?? '0',
      countryCode = json["country_code"]?.toString() ?? '',
      phone = json["phone"]?.toString() ?? '',
      email = json["email"]?.toString() ?? '',
      shiftsByDay = ((json["shifts_by_day"] as Map?) ?? {}).map(
        (final key, final value) => MapEntry(
          key.toString(),
          DayShifts.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
      address = json["address"]?.toString() ?? '',
      banner = json["banner"]?.toString() ?? '',
      otherImages = ((json["other_images"] as List?) ?? [])
          .map((final v) => v.toString())
          .toList(),
      preBookingChatAllowed =
          json["pre_booking_chat_allowed"]?.toString() ?? '0',
      image = json["profile_image"]?.toString() ?? '',
      isBookmark = json["is_bookmarked"]?.toString() ?? '0',
      isAtStoreAvailable = json["at_store"]?.toString() ?? '0',
      isAtDoorstepAvailable = json["at_doorstep"]?.toString() ?? '0',
      totalServices = json["total_services"]?.toString() ?? '0',
      providerType = json["provider_type"]?.toString() ?? '';
}
