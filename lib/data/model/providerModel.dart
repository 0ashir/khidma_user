import 'package:e_demand/app/generalImports.dart';

class Providers {
  Providers({
    this.id,
    this.providerId,
    this.companyName,
    this.translatedCompanyName,
    this.partnerName,
    this.translatedPartnerName,
    this.image,
    this.advanceBookingDays,
    this.numberOfMembers,
    this.ratings,
    this.numberOfRatings,
    this.visitingCharge,
    this.isAvailableNow,
    this.about,
    this.translatedAbout,
    this.address,
    this.fiveStar,
    this.fourStar,
    this.threeStar,
    this.twoStar,
    this.oneStar,
    this.isBookmark,
    this.bannerImage,
    this.sundayIsOpen,
    this.sundayOpeningTime,
    this.sundayClosingTime,
    this.saturdayIsOpen,
    this.saturdayOpeningTime,
    this.saturdayClosingTime,
    this.fridayIsOpen,
    this.fridayOpeningTime,
    this.fridayClosingTime,
    this.thursdayIsOpen,
    this.thursdayOpeningTime,
    this.thursdayClosingTime,
    this.wednesdayIsOpen,
    this.wednesdayOpeningTime,
    this.wednesdayClosingTime,
    this.tuesdayIsOpen,
    this.tuesdayOpeningTime,
    this.tuesdayClosingTime,
    this.mondayIsOpen,
    this.mondayOpeningTime,
    this.mondayClosingTime,
    this.businessDayInfo,
    this.otherImagesOfTheService,
    this.longDescription,
    this.translatedLongDescription,
    this.latitude,
    this.longitude,
    this.isAvailableAtLocation,
    this.isAtStoreAvailable,
    this.isAtDoorstepAvailable,
    this.isPostBookingChatAllowed,
    this.isPreBookingChatAllowed,
    this.distance,
    this.totalServices,
    this.slug,
    this.promocode,
    this.isVerified,
    this.phone,
    this.countryCode,
    this.email,
    this.numberOfOrders,
    this.providerType,
    this.startingPrice,
    this.nextAvailableSlot,
  });

  factory Providers.fromProviderDetails(final ProviderDetailsModel d) =>
      Providers(
          id: d.partnerId,
          providerId: d.partnerId,
          companyName: d.companyName,
          translatedCompanyName: d.companyName,
          partnerName: d.companyName,
          translatedPartnerName: d.companyName,
          image: d.image ?? '',
          ratings: (double.tryParse(d.averageRating ?? '0') ?? 0)
              .toStringAsFixed(1),
          numberOfRatings: d.numberOfRatings,
          about: d.about,
          translatedAbout: d.about,
          address: d.address,
          fiveStar: (d.ratingBreakdown['5'] ?? 0).toString(),
          fourStar: (d.ratingBreakdown['4'] ?? 0).toString(),
          threeStar: (d.ratingBreakdown['3'] ?? 0).toString(),
          twoStar: (d.ratingBreakdown['2'] ?? 0).toString(),
          oneStar: (d.ratingBreakdown['1'] ?? 0).toString(),
          isBookmark: d.isBookmark ?? '0',
          bannerImage: d.banner,
          longDescription: d.longDescription,
          translatedLongDescription: d.longDescription,
          isAtStoreAvailable: d.isAtStoreAvailable ?? '0',
          isAtDoorstepAvailable: d.isAtDoorstepAvailable ?? '0',
          isPreBookingChatAllowed: d.preBookingChatAllowed,
          distance: d.distance,
          totalServices: d.totalServices ?? '0',
          slug: d.slug,
          isVerified: d.isVerified,
          phone: d.phone,
          countryCode: d.countryCode,
          email: d.email,
          numberOfOrders: d.numberOfOrders,
          providerType: d.providerType,
        )
        ..otherImagesOfTheService = d.otherImages
        ..shiftsByDay = d.shiftsByDay;

  Providers.fromJson(final Map<String?, dynamic> json) {
    id = json["id"]?.toString() ?? "0";
    providerId = json["id"]?.toString() ?? "0";
    companyName = json["company_name"]?.toString() ?? '';
    translatedCompanyName =
        (json["translated_company_name"]?.toString() ?? '').isNotEmpty
        ? json["translated_company_name"]!.toString()
        : (json["company_name"]?.toString() ?? '');
    partnerName =
        json["partner_name"]?.toString() ?? json["username"]?.toString() ?? '';

    translatedPartnerName =
        (json["translated_username"]?.toString() ?? '').isNotEmpty
        ? json["translated_username"].toString()
        : (json["translated_partner_name"]?.toString() ?? '').isNotEmpty
        ? json["translated_partner_name"].toString()
        : partnerName;

    image =
        json["profile_image"]?.toString() ?? json["image"]?.toString() ?? '';
    about = json["about"]?.toString() ?? '';
    translatedAbout = (json["translated_about"]?.toString() ?? '').isNotEmpty
        ? json["translated_about"]!.toString()
        : (json["about"]?.toString() ?? '');
    address = json["address"]?.toString() ?? '';
    advanceBookingDays = json["advance_booking_days"]?.toString() ?? '';
    numberOfMembers = json["number_of_members"]?.toString() ?? '';
    ratings = double.parse(
      json["average_rating"]?.toString() ?? '0.0',
    ).toStringAsFixed(1);
    numberOfRatings = json["number_of_ratings"]?.toString() ?? '0';
    visitingCharge = json["visiting_charges"]?.toString() ?? '0';
    isAvailableNow = json["is_available_now"]?.toString() == "1";
    oneStar = json["1_star"]?.toString() ?? '0';
    twoStar = json["2_star"]?.toString() ?? '0';
    threeStar = json["3_star"]?.toString() ?? '0';
    fourStar = json["4_star"]?.toString() ?? '0';
    fiveStar = json["5_star"]?.toString() ?? '0';
    isBookmark = json["is_bookmarked"]?.toString() ?? "0";
    bannerImage =
        json["banner"]?.toString() ??
        json["banner_image"]?.toString() ??
        json["image"]?.toString() ??
        '';
    sundayIsOpen = json["sunday_is_open"];
    sundayOpeningTime = json["sunday_opening_time"];
    sundayClosingTime = json["sunday_closing_time"];
    saturdayIsOpen = json["saturday_is_open"];
    saturdayOpeningTime = json["saturday_opening_time"];
    saturdayClosingTime = json["saturday_closing_time"];
    fridayIsOpen = json["friday_is_open"];
    fridayOpeningTime = json["friday_opening_time"];
    fridayClosingTime = json["friday_closing_time"];
    thursdayIsOpen = json["thursday_is_open"];
    thursdayOpeningTime = json["thursday_opening_time"];
    thursdayClosingTime = json["thursday_closing_time"];
    wednesdayIsOpen = json["wednesday_is_open"];
    wednesdayOpeningTime = json["wednesday_opening_time"];
    wednesdayClosingTime = json["wednesday_closing_time"];
    tuesdayIsOpen = json["tuesday_is_open"];
    tuesdayOpeningTime = json["tuesday_opening_time"];
    tuesdayClosingTime = json["tuesday_closing_time"];
    mondayIsOpen = json["monday_is_open"];
    mondayOpeningTime = json["monday_opening_time"];
    mondayClosingTime = json["monday_closing_time"];
    longDescription = json["long_description"]?.toString() ?? '';
    translatedLongDescription =
        (json["translated_long_description"]?.toString() ?? '').isNotEmpty
        ? json["translated_long_description"]!.toString()
        : (json["long_description"]?.toString() ?? '');
    latitude = json["latitude"]?.toString();
    longitude = json["longitude"]?.toString();
    isAtDoorstepAvailable = json["at_doorstep"];
    isAtStoreAvailable = json["at_store"];
    isAvailableAtLocation = json["is_Available_at_location"] ?? "0";
    isPreBookingChatAllowed = json["pre_booking_chat"] ?? "0";
    isPostBookingChatAllowed = json["post_booking_chat"] ?? "0";
    distance = json["distance"]?.toString() ?? "0";
    slug = json['slug'] ?? "0";
    totalServices = (json["total_services"] ?? 0).toString();
    isVerified = json["is_verified"]?.toString() == "1";
    startingPrice = json["starting_price"]?.toString();
    if (json["next_available_slot"] != null) {
      nextAvailableSlot = NextAvailableSlot.fromJson(
        Map<String, dynamic>.from(json["next_available_slot"]),
      );
    }

    if (json["other_images"] != null) {
      otherImagesOfTheService = <String>[];
      json["other_images"].forEach((final v) {
        otherImagesOfTheService!.add(v);
      });
    } else {
      otherImagesOfTheService = <String>[];
    }
    if (json["services"] != null) {
      services = <Services>[];
      services = (json["services"] as List)
          .map((e) => Services.fromJson(Map.from(e)))
          .toList();
    } else {
      services = <Services>[];
    }

    if (json['promocode'] != null) {
      promocode = <Promocode>[];
      promocode = (json["promocode"] as List)
          .map((e) => Promocode.fromJson(Map.from(e)))
          .toList();
    } else {
      promocode = <Promocode>[];
    }
    businessDayInfo = [
      {
        "day": "monday",
        "isOpen": mondayIsOpen,
        "openingTime": mondayOpeningTime,
        "closingTime": mondayClosingTime,
      },
      {
        "day": "tuesday",
        "isOpen": tuesdayIsOpen,
        "openingTime": tuesdayOpeningTime,
        "closingTime": tuesdayClosingTime,
      },
      {
        "day": "wednesday",
        "isOpen": wednesdayIsOpen,
        "openingTime": wednesdayOpeningTime,
        "closingTime": wednesdayClosingTime,
      },
      {
        "day": "thursday",
        "isOpen": thursdayIsOpen,
        "openingTime": thursdayOpeningTime,
        "closingTime": thursdayClosingTime,
      },
      {
        "day": "friday",
        "isOpen": fridayIsOpen,
        "openingTime": fridayOpeningTime,
        "closingTime": fridayClosingTime,
      },
      {
        "day": "saturday",
        "isOpen": saturdayIsOpen,
        "openingTime": saturdayOpeningTime,
        "closingTime": saturdayClosingTime,
      },
      {
        "day": "sunday",
        "isOpen": sundayIsOpen,
        "openingTime": sundayOpeningTime,
        "closingTime": sundayClosingTime,
      },
    ].map((e) => DayInfo.fromMap(e)).toList();

    const _dayOrder = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    if (json['shifts_by_day'] != null) {
      final raw = Map<String, dynamic>.from(json['shifts_by_day']);
      shiftsByDay = {
        for (final day in _dayOrder)
          if (raw.containsKey(day))
            day: DayShifts.fromJson(Map<String, dynamic>.from(raw[day])),
      };
    } else {
      shiftsByDay = {
        'monday': DayShifts.fromFlat(
          isOpen: mondayIsOpen,
          openingTime: mondayOpeningTime,
          closingTime: mondayClosingTime,
        ),
        'tuesday': DayShifts.fromFlat(
          isOpen: tuesdayIsOpen,
          openingTime: tuesdayOpeningTime,
          closingTime: tuesdayClosingTime,
        ),
        'wednesday': DayShifts.fromFlat(
          isOpen: wednesdayIsOpen,
          openingTime: wednesdayOpeningTime,
          closingTime: wednesdayClosingTime,
        ),
        'thursday': DayShifts.fromFlat(
          isOpen: thursdayIsOpen,
          openingTime: thursdayOpeningTime,
          closingTime: thursdayClosingTime,
        ),
        'friday': DayShifts.fromFlat(
          isOpen: fridayIsOpen,
          openingTime: fridayOpeningTime,
          closingTime: fridayClosingTime,
        ),
        'saturday': DayShifts.fromFlat(
          isOpen: saturdayIsOpen,
          openingTime: saturdayOpeningTime,
          closingTime: saturdayClosingTime,
        ),
        'sunday': DayShifts.fromFlat(
          isOpen: sundayIsOpen,
          openingTime: sundayOpeningTime,
          closingTime: sundayClosingTime,
        ),
      };
    }
  }

  String? id;
  String? providerId;
  String? companyName;
  String? translatedCompanyName;
  String? partnerName;
  String? translatedPartnerName;
  String? image;
  String? advanceBookingDays;
  String? numberOfMembers;
  String? ratings;
  String? numberOfRatings;
  String? visitingCharge;
  String? about;
  String? translatedAbout;
  String? address;
  bool? isAvailableNow;
  String? oneStar;
  String? twoStar;
  String? threeStar;
  String? fourStar;
  String? fiveStar;
  String? isBookmark;
  String? bannerImage;
  String? sundayIsOpen;
  String? sundayOpeningTime;
  String? sundayClosingTime;
  String? saturdayIsOpen;
  String? saturdayOpeningTime;
  String? saturdayClosingTime;
  String? fridayIsOpen;
  String? fridayOpeningTime;
  String? fridayClosingTime;
  String? thursdayIsOpen;
  String? thursdayOpeningTime;
  String? thursdayClosingTime;
  String? wednesdayIsOpen;
  String? wednesdayOpeningTime;
  String? wednesdayClosingTime;
  String? tuesdayIsOpen;
  String? tuesdayOpeningTime;
  String? tuesdayClosingTime;
  String? mondayIsOpen;
  String? mondayOpeningTime;
  String? mondayClosingTime;
  List<String>? otherImagesOfTheService;
  List<DayInfo>? businessDayInfo;
  Map<String, DayShifts> shiftsByDay = {};
  List<Services>? services;
  String? longDescription;
  String? translatedLongDescription;
  String? latitude;
  String? longitude;
  String? isAvailableAtLocation;
  String? isAtStoreAvailable;
  String? isPreBookingChatAllowed;
  String? isPostBookingChatAllowed;
  String? isAtDoorstepAvailable;
  String? distance;
  String? totalServices;
  String? slug;
  List<Promocode>? promocode;
  bool? isVerified;
  String? phone;
  String? countryCode;
  String? email;
  String? numberOfOrders;
  String? providerType;
  String? startingPrice;
  NextAvailableSlot? nextAvailableSlot;
}

class NextAvailableSlot {
  NextAvailableSlot({this.date, this.startingTime, this.endingTime});

  factory NextAvailableSlot.fromJson(final Map<String, dynamic> json) =>
      NextAvailableSlot(
        date: json["date"]?.toString(),
        startingTime: json["starting_time"]?.toString(),
        endingTime: json["ending_time"]?.toString(),
      );

  final String? date;
  final String? startingTime;
  final String? endingTime;
}

class DayInfo {
  String? day;
  String? isOpen;
  String? openingTime;
  String? closingTime;

  DayInfo({this.day, this.isOpen, this.openingTime, this.closingTime});

  factory DayInfo.fromMap(Map<String, dynamic> json) => DayInfo(
    day: json["day"],
    isOpen: json["isOpen"],
    openingTime: json["openingTime"],
    closingTime: json["closingTime"],
  );
}

class ProviderShift {
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final bool onLeave;

  ProviderShift({
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
    required this.onLeave,
  });

  factory ProviderShift.fromJson(Map<String, dynamic> json) => ProviderShift(
    openingTime: json['opening_time']?.toString() ?? '',
    closingTime: json['closing_time']?.toString() ?? '',
    isOpen: json['is_open']?.toString() == '1',
    onLeave: json['on_leave']?.toString() == '1',
  );
}

class DayShifts {
  final bool isOpen;
  final List<ProviderShift> shifts;

  DayShifts({required this.isOpen, required this.shifts});

  bool get isOnLeave => shifts.isNotEmpty && shifts.every((s) => s.onLeave);

  List<ProviderShift> get activeShifts =>
      shifts.where((s) => s.isOpen && !s.onLeave).toList();

  factory DayShifts.fromJson(Map<String, dynamic> json) => DayShifts(
    isOpen: json['is_open']?.toString() == '1',
    shifts: json['shifts'] != null
        ? (json['shifts'] as List)
              .map((e) => ProviderShift.fromJson(Map<String, dynamic>.from(e)))
              .where((s) => s.isOpen)
              .toList()
        : [],
  );

  factory DayShifts.fromFlat({
    required String? isOpen,
    required String? openingTime,
    required String? closingTime,
  }) {
    final open = isOpen == '1';
    return DayShifts(
      isOpen: open,
      shifts: open && openingTime != null && closingTime != null
          ? [
              ProviderShift(
                openingTime: openingTime,
                closingTime: closingTime,
                isOpen: true,
                onLeave: false,
              ),
            ]
          : [],
    );
  }
}
