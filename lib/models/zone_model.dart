// To parse this JSON data, do
//
//     final zoneModel = zoneModelFromJson(jsonString);

/* import 'dart:convert';

ZoneModel zoneModelFromJson(String str) => ZoneModel.fromJson(json.decode(str));

String zoneModelToJson(ZoneModel data) => json.encode(data.toJson()); */

import 'package:fixit_user/models/currency_model.dart';

class ZoneModel {
  int? currentPage;
  List<Datum>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  ZoneModel({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) => ZoneModel(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Datum {
  int? id;
  String? name;
  PlacePoints? placePoints;
  List<Location>? locations;
  String? status;
  int? createdById;
  int? currencyId;
  List<String>? paymentMethods;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  CurrencyModel? currency;

  Datum({
    this.id,
    this.name,
    this.placePoints,
    this.locations,
    this.status,
    this.createdById,
    this.currencyId,
    this.paymentMethods,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.currency,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        placePoints: json["place_points"] == null
            ? null
            : PlacePoints.fromJson(json["place_points"]),
        locations: json["locations"] == null
            ? []
            : List<Location>.from(
                json["locations"]!.map((x) => Location.fromJson(x))),
        status: json["status"],
        createdById: json["created_by_id"],
        currencyId: json["currency_id"],
        paymentMethods: json["payment_methods"] == null
            ? []
            : List<String>.from(json["payment_methods"]!.map((x) => x)),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        currency: json["currency"] == null
            ? null
            : CurrencyModel.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "place_points": placePoints?.toJson(),
        "locations": locations == null
            ? []
            : List<dynamic>.from(locations!.map((x) => x.toJson())),
        "status": status,
        "created_by_id": createdById,
        "currency_id": currencyId,
        "payment_methods": paymentMethods == null
            ? []
            : List<dynamic>.from(paymentMethods!.map((x) => x)),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "currency": currency?.toJson(),
      };
}

class Currency {
  int? id;
  String? code;
  String? symbol;
  int? noOfDecimal;
  int? exchangeRate;
  String? thousandsSeparator;
  String? decimalSeparator;
  int? systemReserve;
  int? status;
  dynamic createdById;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<Media>? media;

  Currency({
    this.id,
    this.code,
    this.symbol,
    this.noOfDecimal,
    this.exchangeRate,
    this.thousandsSeparator,
    this.decimalSeparator,
    this.systemReserve,
    this.status,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.media,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        id: json["id"],
        code: json["code"],
        symbol: json["symbol"],
        noOfDecimal: json["no_of_decimal"],
        exchangeRate: json["exchange_rate"],
        thousandsSeparator: json["thousands_separator"],
        decimalSeparator: json["decimal_separator"],
        systemReserve: json["system_reserve"],
        status: json["status"],
        createdById: json["created_by_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        media: json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "symbol": symbol,
        "no_of_decimal": noOfDecimal,
        "exchange_rate": exchangeRate,
        "thousands_separator": thousandsSeparator,
        "decimal_separator": decimalSeparator,
        "system_reserve": systemReserve,
        "status": status,
        "created_by_id": createdById,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
      };
}

class Media {
  int? id;
  String? modelType;
  int? modelId;
  String? uuid;
  String? collectionName;
  String? name;
  String? fileName;
  String? mimeType;
  String? disk;
  String? conversionsDisk;
  int? size;
  List<dynamic>? manipulations;
  CustomProperties? customProperties;
  List<dynamic>? generatedConversions;
  List<dynamic>? responsiveImages;
  int? orderColumn;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? originalUrl;
  String? previewUrl;

  Media({
    this.id,
    this.modelType,
    this.modelId,
    this.uuid,
    this.collectionName,
    this.name,
    this.fileName,
    this.mimeType,
    this.disk,
    this.conversionsDisk,
    this.size,
    this.manipulations,
    this.customProperties,
    this.generatedConversions,
    this.responsiveImages,
    this.orderColumn,
    this.createdAt,
    this.updatedAt,
    this.originalUrl,
    this.previewUrl,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        id: json["id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        uuid: json["uuid"],
        collectionName: json["collection_name"],
        name: json["name"],
        fileName: json["file_name"],
        mimeType: json["mime_type"],
        disk: json["disk"],
        conversionsDisk: json["conversions_disk"],
        size: json["size"],
        manipulations: json["manipulations"] == null
            ? []
            : List<dynamic>.from(json["manipulations"]!.map((x) => x)),
        customProperties: json["custom_properties"] == null
            ? null
            : CustomProperties.fromJson(json["custom_properties"]),
        generatedConversions: json["generated_conversions"] == null
            ? []
            : List<dynamic>.from(json["generated_conversions"]!.map((x) => x)),
        responsiveImages: json["responsive_images"] == null
            ? []
            : List<dynamic>.from(json["responsive_images"]!.map((x) => x)),
        orderColumn: json["order_column"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        originalUrl: json["original_url"],
        previewUrl: json["preview_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "model_type": modelType,
        "model_id": modelId,
        "uuid": uuid,
        "collection_name": collectionName,
        "name": name,
        "file_name": fileName,
        "mime_type": mimeType,
        "disk": disk,
        "conversions_disk": conversionsDisk,
        "size": size,
        "manipulations": manipulations == null
            ? []
            : List<dynamic>.from(manipulations!.map((x) => x)),
        "custom_properties": customProperties?.toJson(),
        "generated_conversions": generatedConversions == null
            ? []
            : List<dynamic>.from(generatedConversions!.map((x) => x)),
        "responsive_images": responsiveImages == null
            ? []
            : List<dynamic>.from(responsiveImages!.map((x) => x)),
        "order_column": orderColumn,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "original_url": originalUrl,
        "preview_url": previewUrl,
      };
}

class CustomProperties {
  String? language;

  CustomProperties({
    this.language,
  });

  factory CustomProperties.fromJson(Map<String, dynamic> json) =>
      CustomProperties(
        language: json["language"],
      );

  Map<String, dynamic> toJson() => {
        "language": language,
      };
}

class Location {
  double? lat;
  double? lng;

  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class PlacePoints {
  String? type;
  List<List<List<double>>>? coordinates;

  PlacePoints({
    this.type,
    this.coordinates,
  });

  factory PlacePoints.fromJson(Map<String, dynamic> json) => PlacePoints(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<List<List<double>>>.from(json["coordinates"]!.map((x) =>
                List<List<double>>.from(x.map(
                    (x) => List<double>.from(x.map((x) => x?.toDouble())))))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(
                x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
      };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
