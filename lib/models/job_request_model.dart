import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/index.dart';

class JobRequestModel {
  int? id;
  String? title;
  String? description;
  String? duration;
  String? durationUnit;
  int? requiredServicemen;
  int? initialPrice;
  int? finalPrice;
  String? status;
  List<dynamic>? category;
  int? providerId;
  int? createdById;
  String? bookingDate;
  List<dynamic>? categoryIds;
  String? createdAt;
  List<Media>? media;
  // UserModel? user;
  List<Bids>? bids;
  Services? service;

  JobRequestModel(
      {this.id,
      this.title,
      this.description,
      this.duration,
      this.durationUnit,
      this.requiredServicemen,
      this.initialPrice,
      this.finalPrice,
      this.status,
      this.providerId,
      this.createdById,
      this.bookingDate,
      this.categoryIds,
      this.createdAt,
      this.media,
      // this.user,
      this.bids,
      this.service});

  JobRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    duration = json['duration'];
    durationUnit = json['duration_unit'];
    requiredServicemen = json['required_servicemen'];
    initialPrice = json['initial_price'];
    finalPrice = json['final_price'];
    status = json['status'];
    category = json["categories"] == null
        ? []
        : List<dynamic>.from(json["categories"]!.map((x) => x));
    providerId = json['provider_id'];
    createdById = json['created_by_id'];
    bookingDate = json['booking_date'];
    categoryIds = json['category_ids'];

    createdAt = json['created_at'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    // user = json['user'] !=
    // null ?  UserModel.fromJson(json['user']) : null;
    service =
        json['service'] != null ? Services.fromJson(json['service']) : null;
    if (json['bids'] != null) {
      bids = <Bids>[];
      json['bids'].forEach((v) {
        bids!.add(Bids.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['duration'] = duration;
    data['duration_unit'] = durationUnit;
    data['required_servicemen'] = requiredServicemen;
    data['initial_price'] = initialPrice;
    data['final_price'] = finalPrice;
    data['status'] = status;

    data['provider_id'] = providerId;
    data['created_by_id'] = createdById;
    data['booking_date'] = bookingDate;
    data['category_ids'] = categoryIds;
    data['created_at'] = createdAt;
    if (category != null) {
      data['categories'] = category!.map((v) => v).toList();
    }
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    // if (user != null) {
    //   data['user'] = user!.toJson();
    // }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (bids != null) {
      data['bids'] = bids!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationCoordinates {
  String? lat;
  String? lng;

  LocationCoordinates({this.lat, this.lng});

  LocationCoordinates.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Bids {
  int? id;
  int? serviceRequestId;
  int? providerId;
  int? amount;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  ProviderModel? provider;

  Bids(
      {this.id,
      this.serviceRequestId,
      this.providerId,
      this.amount,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.provider});

  Bids.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceRequestId = json['service_request_id'];
    providerId = json['provider_id'];
    amount = json['amount'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    provider = json['provider'] != null
        ? ProviderModel.fromJson(json['provider'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_request_id'] = serviceRequestId;
    data['provider_id'] = providerId;
    data['amount'] = amount;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    return data;
  }
}
