import 'package:fixit_user/models/service_details_model.dart';

import '../config.dart';

class Services {
  int? id;
  String? title;
  dynamic price;
  int? status;
  String? duration;
  String? durationUnit;
  List<Tax>? taxes;

  dynamic serviceRate;
  int? discount;
  List<ServiceFaqModel>? faqs;
  String? description;
  int? userId;
  String? type;
  String? tax;
  int? isFeatured;
  int? requiredServicemen;
  String? isMultipleServiceman;
  String? metaDescription;
  String? selectServiceManType;
  DateTime? serviceDate;
  List<dynamic>? reviewRatings;
  dynamic ratingCount;
  bool? advancePaymentEnabled;
  String? advancePaymentPercentage;
  List<CategoryModel>? categories;
  List<Services>? relatedServices;
  List<dynamic>? media;
  ProviderModel? user;
  List<dynamic>? reviews;
  List<ProviderModel>? selectedServiceMan;
  List<AdditionalService>? additionalServices;
  List<AdditionalService>? selectedAdditionalServices;
  int? selectedRequiredServiceMan;
  String? selectDateTimeOption;
  String? selectedDateTimeFormat;
  String? selectedServiceNote;
  PrimaryAddress? primaryAddress;
  DestinationLocation? destinationLocation;
  String? video;
  String? discountAmount;
  ServicePivot? pivot;
  
  // Schedule booking fields
  int? isScheduledBooking;
  DateTime? scheduleStartDate;
  DateTime? scheduleEndDate;
  String? scheduleTime;
  String? bookingFrequency;
  List<DateTime>? scheduledDatesJson;
  int? scheduledServicesCount;
  List<String>? selectedWeekdays;

  Services({
    this.id,
    this.title,
    this.price,
    this.status,
    this.tax,
    this.taxes,
    this.duration,
    this.durationUnit,
    this.serviceRate,
    this.discount,
    this.description,
    this.userId,
    this.type,
    this.faqs,
    this.isFeatured,
    this.requiredServicemen,
    this.isMultipleServiceman,
    this.metaDescription,
    this.selectServiceManType,
    this.serviceDate,
    this.reviewRatings,
    this.ratingCount,
    this.advancePaymentEnabled,
    this.advancePaymentPercentage,
    this.categories,
    this.relatedServices,
    this.media,
    this.user,
    this.additionalServices,
    this.selectedAdditionalServices,
    this.reviews,
    this.selectedRequiredServiceMan,
    this.primaryAddress,
    this.selectDateTimeOption,
    this.selectedDateTimeFormat,
    this.selectedServiceNote,
    this.destinationLocation,
    this.video,
    this.discountAmount,
    this.pivot,
    this.isScheduledBooking,
    this.scheduleStartDate,
    this.scheduleEndDate,
    this.scheduleTime,
    this.bookingFrequency,
    this.scheduledDatesJson,
    this.scheduledServicesCount,
    this.selectedWeekdays,
  });

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    video = json['video'];
    pivot = json["pivot"] == null ? null : ServicePivot.fromJson(json["pivot"]);
    title = json['title'];
    tax = json['tax'];
    price =
        json['price'] != null ? double.parse(json['price'].toString()) : null;
    status = json['status'];
    duration = json['duration'];
    durationUnit = json['duration_unit'];

    serviceRate = json['service_rate'] != null
        ? double.parse(json['service_rate'].toString())
        : null;
    discount = json['discount'];
    description = json['description'];
    userId = json['user_id'];
    type = json['type'];
    isFeatured = json['is_featured'];
    requiredServicemen = json['required_servicemen'];
    isMultipleServiceman = json['isMultipleServiceman'];
    metaDescription = json['meta_description'];
    selectServiceManType = json['selectServiceManType'];
    discountAmount = json['discount_amount'];

    serviceDate = json["serviceDate"] == null
        ? null
        : DateTime.parse(json["serviceDate"]);
    reviewRatings = json['review_ratings'] /* .cast<int>() */;
    ratingCount = json['rating_count'];
    advancePaymentEnabled = json['is_advance_payment_enabled'];
    advancePaymentPercentage = json['advance_payment_percentage'];
    selectedRequiredServiceMan = json['required_servicemen'];
    if (json['selectedAdditionalServices'] != null) {
      selectedAdditionalServices = <AdditionalService>[];
      json['selectedAdditionalServices'].forEach((v) {
        selectedAdditionalServices!.add(AdditionalService.fromJson(v));
      });
    }
    if (json['taxes'] != null) {
      taxes = <Tax>[];
      json['taxes'].forEach((v) {
        taxes!.add(Tax.fromJson(v));
      });
    }
    selectDateTimeOption = json['selectDateTimeOption'];
    selectedDateTimeFormat = json['selectedDateTimeFormat'];
    selectedServiceNote = json['selectedServiceNote'];
    if (json['categories'] != null) {
      categories = <CategoryModel>[];
      json['categories'].forEach((v) {
        categories!.add(CategoryModel.fromJson(v));
      });
    }
    if (json['related_services'] != null) {
      relatedServices = <Services>[];
      json['related_services'].forEach((v) {
        relatedServices!.add(Services.fromJson(v));
      });
    }
    if (json['media'] != null && json["media"] is List) {
      media = <dynamic>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    // media: (json["media"] != null && json["media"] is List)
    //     ? (json["media"] as List).map((x) => Media.fromJson(x)).toList()
    //     : [];
    user = json['user'] != null ? ProviderModel.fromJson(json['user']) : null;
    primaryAddress = json['primary_address'] != null
        ? PrimaryAddress.fromJson(json['primary_address'])
        : null;
    destinationLocation = json['destination_location'] != null
        ? DestinationLocation.fromJson(json['destination_location'])
        : null;
    faqs = json['faqs'] != null
        ? (json['faqs'] as List<dynamic>)
            .map((e) => ServiceFaqModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
    if (json['additional_services'] != null) {
      additionalServices = <AdditionalService>[];
      json['additional_services'].forEach((v) {
        additionalServices!.add(AdditionalService.fromJson(v));
      });
    }
    if (json['selectedServiceMan'] != null) {
      selectedServiceMan = <ProviderModel>[];
      json['selectedServiceMan'].forEach((v) {
        selectedServiceMan!.add(ProviderModel.fromJson(v));
      });
    }
    
    // Parse schedule booking fields
    isScheduledBooking = json['isScheduledBooking'];
    scheduleStartDate = json['scheduleStartDate'] != null 
        ? DateTime.parse(json['scheduleStartDate']) 
        : null;
    scheduleEndDate = json['scheduleEndDate'] != null 
        ? DateTime.parse(json['scheduleEndDate']) 
        : null;
    scheduleTime = json['scheduleTime'];
    bookingFrequency = json['bookingFrequency'];
    scheduledServicesCount = json['scheduledServicesCount'];
    
    if (json['scheduledDatesJson'] != null) {
      scheduledDatesJson = (json['scheduledDatesJson'] as List)
          .map((e) => DateTime.parse(e.toString()))
          .toList();
    }
    
    if (json['selectedWeekdays'] != null) {
      selectedWeekdays = List<String>.from(json['selectedWeekdays']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['video'] = video;
    if (pivot != null) data["pivot"] = pivot?.toJson();
    data['title'] = title;
    data['price'] = price;
    data['status'] = status;
    data['tax'] = tax;
    data['duration'] = duration;
    data['duration_unit'] = durationUnit;
    data['service_rate'] = serviceRate;
    data['discount'] = discount;
    data['description'] = description;
    data['user_id'] = userId;
    data['type'] = type;
    data['is_featured'] = isFeatured;
    data['discount_amount'] = discountAmount;
    data['required_servicemen'] = requiredServicemen;
    data['isMultipleServiceman'] = isMultipleServiceman;
    data['meta_description'] = metaDescription;
    data['selectServiceManType'] = selectServiceManType;
    data['serviceDate'] = serviceDate?.toIso8601String();
    if (taxes != null) {
      data['taxes'] = taxes!.map((v) => v.toJson()).toList();
    }
    data['review_ratings'] = reviewRatings;
    data['rating_count'] = ratingCount;
    data['is_advance_payment_enabled'] = advancePaymentEnabled;
    data['advance_payment_percentage'] = advancePaymentPercentage;
    data['required_servicemen'] = selectedRequiredServiceMan;
    data['selectDateTimeOption'] = selectDateTimeOption;
    data['selectedDateTimeFormat'] = selectedDateTimeFormat;
    data['selectedServiceNote'] = selectedServiceNote;
    data['faqs'] = faqs?.map((e) => e.toJson()).toList();

    if (primaryAddress != null) {
      data['primary_address'] = primaryAddress!.toJson();
    }
    if (destinationLocation != null) {
      data['destination_location'] = destinationLocation!.toJson();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (relatedServices != null) {
      data['related_services'] =
          relatedServices!.map((v) => v.toJson()).toList();
    }
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    if (selectedServiceMan != null) {
      data['selectedServiceMan'] =
          selectedServiceMan!.map((v) => v.toJson()).toList();
    }
    if (additionalServices != null) {
      data['additional_services'] =
          additionalServices!.map((v) => v.toJson()).toList();
    }
    if (selectedAdditionalServices != null) {
      data['selectedAdditionalServices'] =
          selectedAdditionalServices!.map((v) => v.toJson()).toList();
    }
    
    // Add schedule booking fields to JSON
    data['isScheduledBooking'] = isScheduledBooking;
    data['scheduleStartDate'] = scheduleStartDate?.toIso8601String();
    data['scheduleEndDate'] = scheduleEndDate?.toIso8601String();
    data['scheduleTime'] = scheduleTime;
    data['bookingFrequency'] = bookingFrequency;
    data['scheduledServicesCount'] = scheduledServicesCount;
    
    if (scheduledDatesJson != null) {
      data['scheduledDatesJson'] = 
          scheduledDatesJson!.map((v) => v.toIso8601String()).toList();
    }
    
    if (selectedWeekdays != null) {
      data['selectedWeekdays'] = selectedWeekdays;
    }
    
    return data;
  }

  double getSelectedAdditionalServicesPrice() {
    if (selectedAdditionalServices == null) return 0.0;
    return selectedAdditionalServices!.fold(0.0,
        (sum, item) => sum + (item.price is num ? item.price!.toDouble() : 0));
  }
}

class DestinationLocation {
  dynamic lat;
  dynamic lng;
  String? area;
  String? address;
  String? stateId;
  String? countryId;
  String? postalCode;
  String? city;

  DestinationLocation(
      {this.lat,
      this.lng,
      this.area,
      this.address,
      this.stateId,
      this.countryId,
      this.postalCode,
      this.city});

  DestinationLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    area = json['area'];
    address = json['address'];
    stateId = json['state_id'];
    countryId = json['country_id'];
    postalCode = json['postal_code'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    data['area'] = area;
    data['address'] = address;
    data['state_id'] = stateId;
    data['country_id'] = countryId;
    data['postal_code'] = postalCode;
    data['city'] = city;
    return data;
  }
}

class Tax {
  int? id;
  String? name;
  double? rate;
  dynamic amount;

  Tax({this.id, this.name, this.rate, this.amount});

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        id: json['id'],
        name: json['name'],
        rate: (json['rate'] as num?)?.toDouble(),
        amount: json['amount'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rate': rate,
        'amount': amount,
      };
}

class CategoryService {
  int? id;
  List<Services>? serviceList;

  CategoryService({this.id, this.serviceList});

  CategoryService.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (json['serviceList'] != null) {
      serviceList = <Services>[];
      json['serviceList'].forEach((v) {
        serviceList!.add(Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    if (serviceList != null) {
      data['serviceList'] = serviceList!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ServicePivot {
  int? advertisementId;
  int? serviceId;

  ServicePivot({
    this.advertisementId,
    this.serviceId,
  });

  factory ServicePivot.fromJson(Map<String, dynamic> json) => ServicePivot(
        advertisementId: json["advertisement_id"],
        serviceId: json["service_id"],
      );

  Map<String, dynamic> toJson() => {
        "advertisement_id": advertisementId,
        "service_id": serviceId,
      };
}
