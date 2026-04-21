import 'package:fixit_user/models/service_details_model.dart';

class CheckoutModel {
  List<SingleServices>? services;
  List<ServicesPackage>? servicesPackage;
  FinalTotal? total;
  bool? isAdvancePayment;
  String? advancePaymentPercentage;

  CheckoutModel(
      {this.services,
      this.servicesPackage,
      this.total,
      this.isAdvancePayment,
      this.advancePaymentPercentage});

  CheckoutModel.fromJson(Map<String, dynamic> json) {
    isAdvancePayment =
        json['is_advance_payment_enabled'] ?? json['is_advance_payment'];
    advancePaymentPercentage = json['advance_payment_percentage']?.toString();
    if (json['services'] != null) {
      services = <SingleServices>[];
      json['services'].forEach((v) {
        services!.add(SingleServices.fromJson(v));
      });
    }
    if (json['services_package'] != null) {
      servicesPackage = <ServicesPackage>[];
      json['services_package'].forEach((v) {
        servicesPackage!.add(ServicesPackage.fromJson(v));
      });
    }
    total = json['total'] != null ? FinalTotal.fromJson(json['total']) : null;
    if (isAdvancePayment == null && total != null) {
      isAdvancePayment = total!.isAdvancePayment;
    }
    if (advancePaymentPercentage == null && total != null) {
      advancePaymentPercentage = total!.advancePaymentPercentage;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    if (servicesPackage != null) {
      data['services_package'] =
          servicesPackage!.map((v) => v.toJson()).toList();
    }
    data['is_advance_payment'] = isAdvancePayment;
    data['advance_payment_percentage'] = advancePaymentPercentage;
    if (total != null) {
      data['total'] = total!.toJson();
    }
    return data;
  }
}

class SingleServices {
  int? providerId;
  int? serviceId;
  double? servicePrice;
  int? addressId;
  dynamic price;
  double? perServicemanCharge;
  String? dateTime;
  List<AdditionalService>? additionalServices;
  List<Tax>? taxes;
  Total? total;
  String? type;
  bool? isScheduledBooking;
  String? bookingFrequency;
  String? scheduleStartDate;
  String? scheduleEndDate;
  String? scheduleTime;
  List<String>? selectedWeekdays;
  List<ScheduledDatesJson>? scheduledDatesJson;
  int? scheduledServicesCount;
  dynamic baseSubtotal;
  int? baseTax;
  int? basePlatformFees;
  dynamic baseTotal;

  SingleServices(
      {this.providerId,
      this.serviceId,
      this.servicePrice,
      this.addressId,
      this.price,
      this.taxes,
      this.type,
      this.perServicemanCharge,
      this.dateTime,
      this.additionalServices,
      this.total,
      this.isScheduledBooking,
      this.bookingFrequency,
      this.scheduleStartDate,
      this.scheduleEndDate,
      this.scheduleTime,
      this.selectedWeekdays,
      this.scheduledDatesJson,
      this.scheduledServicesCount,
      this.baseSubtotal,
      this.baseTax,
      this.basePlatformFees,
      this.baseTotal});

  SingleServices.fromJson(Map<String, dynamic> json) {
    providerId = json['provider_id'];
    serviceId = json['service_id'];
    servicePrice = double.parse(json['service_price'].toString());
    addressId = json['address_id'];
    price = json['price'];
    type = json['type'];
    perServicemanCharge =
        double.parse(json['per_serviceman_charge'].toString());
    dateTime = json['date_time'];
    additionalServices = json["additional_services"] == null
        ? []
        : List<AdditionalService>.from(json["additional_services"]!
            .map((x) => AdditionalService.fromJson(x)));
    taxes = json["taxes"] == null
        ? []
        : List<Tax>.from(json["taxes"]!.map((x) => Tax.fromJson(x)));
    total = json['total'] != null ? Total.fromJson(json['total']) : null;
    isScheduledBooking = json['is_scheduled_booking'];
    bookingFrequency = json['booking_frequency'];
    scheduleStartDate = json['schedule_start_date'];
    scheduleEndDate = json['schedule_end_date'];
    scheduleTime = json['schedule_time'];
    selectedWeekdays =
        (json['selected_weekdays'] as List?)?.cast<String>() ?? [];
    if (json['scheduled_dates_json'] != null &&
        json['scheduled_dates_json'] is List) {
      scheduledDatesJson = (json['scheduled_dates_json'] as List)
          .map((v) => ScheduledDatesJson.fromJson(v))
          .toList();
    } else {
      scheduledDatesJson = [];
    }
    scheduledServicesCount = json['scheduled_services_count'];
    baseSubtotal = json['base_subtotal'];
    baseTax = json['base_tax'];
    basePlatformFees = json['base_platform_fees'];
    baseTotal = json['base_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['provider_id'] = providerId;
    data['service_id'] = serviceId;
    data['service_price'] = servicePrice;
    data['address_id'] = addressId;
    data['price'] = price;
    data['type'] = type;
    data['per_serviceman_charge'] = perServicemanCharge;
    data['date_time'] = dateTime;
    if (total != null) {
      data['total'] = total!.toJson();
    }
    if (additionalServices != []) {
      data['additional_services'] =
          additionalServices!.map((e) => e.toJson()).toList();
    }
    if (taxes != []) {
      data['taxes'] = taxes!.map((e) => e.toJson()).toList();
    }
    data['is_scheduled_booking'] = isScheduledBooking;
    data['booking_frequency'] = bookingFrequency;
    data['schedule_start_date'] = scheduleStartDate;
    data['schedule_end_date'] = scheduleEndDate;
    data['schedule_time'] = scheduleTime;
    data['selected_weekdays'] = selectedWeekdays;
    if (scheduledDatesJson != null) {
      data['scheduled_dates_json'] =
          scheduledDatesJson!.map((v) => v.toJson()).toList();
    }
    data['scheduled_services_count'] = scheduledServicesCount;
    data['base_subtotal'] = baseSubtotal;
    data['base_tax'] = baseTax;
    data['base_platform_fees'] = basePlatformFees;
    data['base_total'] = baseTotal;
    return data;
  }
}

class ScheduledDatesJson {
  String? date;
  String? time;

  ScheduledDatesJson({this.date, this.time});

  ScheduledDatesJson.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['time'] = time;
    return data;
  }
}

/* class AdditionalService {
  int? additionalServiceId;
  int? price;

  AdditionalService({
    this.additionalServiceId,
    this.price,
  });

  factory AdditionalService.fromJson(Map<String, dynamic> json) =>
      AdditionalService(
        additionalServiceId: json["additional_service_id"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "additional_service_id": additionalServiceId,
        "price": price,
      };
} */

class ServicesPackage {
  int? servicePackageId;
  List<PackageServices>? services;

  ServicesPackage({this.servicePackageId, this.services});

  ServicesPackage.fromJson(Map<String, dynamic> json) {
    servicePackageId = json['service_package_id'];
    if (json['services'] != null) {
      services = <PackageServices>[];
      json['services'].forEach((v) {
        services!.add(PackageServices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_package_id'] = servicePackageId;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageServices {
  int? servicePackageId;
  int? providerId;
  int? serviceId;
  double? servicePackagePrice;
  int? addressId;
  double? tax;
  double? servicePrice;
  double? perServicemanCharge;
  String? dateTime;
  Total? total;

  PackageServices(
      {this.servicePackageId,
      this.providerId,
      this.serviceId,
      this.servicePackagePrice,
      this.addressId,
      this.tax,
      this.servicePrice,
      this.perServicemanCharge,
      this.dateTime,
      this.total});

  PackageServices.fromJson(Map<String, dynamic> json) {
    servicePackageId = json['service_package_id'];
    providerId = json['provider_id'];
    serviceId = json['service_id'];
    servicePackagePrice =
        double.parse(json['service_package_price'].toString());
    addressId = json['address_id'];
    tax = double.parse(json['tax'].toString());
    servicePrice = double.parse(json['service_price'].toString());
    perServicemanCharge =
        double.parse(json['per_serviceman_charge'].toString());
    dateTime = json['date_time'];
    total = json['total'] != null ? Total.fromJson(json['total']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_package_id'] = servicePackageId;
    data['provider_id'] = providerId;
    data['service_id'] = serviceId;
    data['service_package_price'] = servicePackagePrice;
    data['address_id'] = addressId;
    data['tax'] = tax;
    data['service_price'] = servicePrice;
    data['per_serviceman_charge'] = perServicemanCharge;
    data['date_time'] = dateTime;
    if (total != null) {
      data['total'] = total!.toJson();
    }
    return data;
  }
}

class Total {
  int? requiredServicemen;
  int? totalExtraServicemen;
  int? totalServicemen;
  double? totalServicemanCharge;
  double? couponTotalDiscount;
  double? platformFees;
  String? platformFeesType;
  double? tax;
  double? subtotal;
  double? total;

  Total(
      {this.requiredServicemen,
      this.totalExtraServicemen,
      this.totalServicemen,
      this.totalServicemanCharge,
      this.couponTotalDiscount,
      this.platformFees,
      this.platformFeesType,
      this.tax,
      this.subtotal,
      this.total});

  Total.fromJson(Map<String, dynamic> json) {
    requiredServicemen = json['required_servicemen'];
    totalExtraServicemen = json['total_extra_servicemen'];
    totalServicemen = int.parse(json['total_servicemen'].toString());
    totalServicemanCharge =
        double.parse(json['total_serviceman_charge'].toString());
    couponTotalDiscount =
        double.parse(json['coupon_total_discount'].toString());
    platformFees = double.parse(json['platform_fees'].toString());
    platformFeesType = json['platform_fees_type'];
    tax = double.parse(json['tax'].toString());
    subtotal = double.parse(json['subtotal'].toString());
    total = double.parse(json['total'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['required_servicemen'] = requiredServicemen;
    data['total_extra_servicemen'] = totalExtraServicemen;
    data['total_servicemen'] = totalServicemen;
    data['total_serviceman_charge'] = totalServicemanCharge;
    data['coupon_total_discount'] = couponTotalDiscount;
    data['platform_fees'] = platformFees;
    data['platform_fees_type'] = platformFeesType;
    data['tax'] = tax;
    data['subtotal'] = subtotal;
    data['total'] = total;
    return data;
  }
}

class FinalTotal {
  int? requiredServicemen;
  int? totalExtraServicemen;
  int? totalServicemen;
  double? totalServicemanCharge;
  double? couponTotalDiscount;
  double? tax;
  double? platformFees;
  String? platformFeesType;
  double? subtotal;
  double? total;
  bool? isAdvancePayment;
  String? advancePaymentPercentage;

  FinalTotal(
      {this.requiredServicemen,
      this.totalExtraServicemen,
      this.totalServicemen,
      this.totalServicemanCharge,
      this.couponTotalDiscount,
      this.tax,
      this.platformFees,
      this.platformFeesType,
      this.subtotal,
      this.total,
      this.isAdvancePayment,
      this.advancePaymentPercentage});

  FinalTotal.fromJson(Map<String, dynamic> json) {
    isAdvancePayment =
        json['is_advance_payment_enabled'] ?? json['is_advance_payment'];
    advancePaymentPercentage = json['advance_payment_percentage']?.toString();
    requiredServicemen = json['required_servicemen'];
    totalExtraServicemen = json['total_extra_servicemen'];
    totalServicemen = json['total_servicemen'];
    totalServicemanCharge =
        double.parse(json['total_serviceman_charge'].toString());
    couponTotalDiscount =
        double.parse(json['coupon_total_discount'].toString());
    tax = double.parse(json['tax'].toString());
    platformFees = double.parse(json['platform_fees'].toString());
    platformFeesType = json['platform_fees_type'];
    subtotal = double.parse(json['subtotal'].toString());
    total = double.parse(json['total'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['required_servicemen'] = requiredServicemen;
    data['total_extra_servicemen'] = totalExtraServicemen;
    data['total_servicemen'] = totalServicemen;
    data['total_serviceman_charge'] = totalServicemanCharge;
    data['coupon_total_discount'] = couponTotalDiscount;
    data['tax'] = tax;
    data['platform_fees'] = platformFees;
    data['platform_fees_type'] = platformFeesType;
    data['subtotal'] = subtotal;
    data['total'] = total;
    data['is_advance_payment'] = isAdvancePayment;
    data['advance_payment_percentage'] = advancePaymentPercentage;
    return data;
  }
}
