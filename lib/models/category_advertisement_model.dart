// To parse this JSON data, do
//
//     final categoryAdvertisementModel = categoryAdvertisementModelFromJson(jsonString);

/* import 'dart:convert'; */

/* CategoryAdvertisementModel categoryAdvertisementModelFromJson(String str) => CategoryAdvertisementModel.fromJson(json.decode(str));

String categoryAdvertisementModelToJson(CategoryAdvertisementModel data) => json.encode(data.toJson()); */

class CategoryAdvertisementModel {
  List<Datum>? data;
  int? currentPage;
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

  CategoryAdvertisementModel({
    this.data,
    this.currentPage,
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

  factory CategoryAdvertisementModel.fromJson(Map<String, dynamic> json) =>
      CategoryAdvertisementModel(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        currentPage: json["current_page"],
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
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "current_page": currentPage,
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
  int? providerId;
  String? type;
  String? screen;
  String? status;
  DateTime? startDate;
  DateTime? endDate;
  List<Media>? media;
  List<dynamic>? services;
  String? videoLink;
  String? zone;

  Datum({
    this.id,
    this.providerId,
    this.type,
    this.screen,
    this.status,
    this.startDate,
    this.endDate,
    this.media,
    this.services,
    this.videoLink,
    this.zone,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        providerId: json["provider_id"],
        type: json["type"],
        screen: json["screen"],
        status: json["status"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        media: json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
        services: json["services"] == null
            ? []
            : List<dynamic>.from(json["services"]!.map((x) => x)),
        videoLink: json["video_link"],
        zone: json["zone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "provider_id": providerId,
        "type": type,
        "screen": screen,
        "status": status,
        "start_date":
            "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "end_date":
            "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
        "services":
            services == null ? [] : List<dynamic>.from(services!.map((x) => x)),
        "video_link": videoLink,
        "zone": zone,
      };
}

class Media {
  int? id;
  String? collectionName;
  String? name;
  CustomProperties? customProperties;
  List<dynamic>? responsiveImages;
  DateTime? createdAt;
  String? originalUrl;

  Media({
    this.id,
    this.collectionName,
    this.name,
    this.customProperties,
    this.responsiveImages,
    this.createdAt,
    this.originalUrl,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        id: json["id"],
        collectionName: json["collection_name"],
        name: json["name"],
        customProperties: json["custom_properties"] == null
            ? null
            : CustomProperties.fromJson(json["custom_properties"]),
        responsiveImages: json["responsive_images"] == null
            ? []
            : List<dynamic>.from(json["responsive_images"]!.map((x) => x)),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        originalUrl: json["original_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "collection_name": collectionName,
        "name": name,
        "custom_properties": customProperties?.toJson(),
        "responsive_images": responsiveImages == null
            ? []
            : List<dynamic>.from(responsiveImages!.map((x) => x)),
        "created_at": createdAt?.toIso8601String(),
        "original_url": originalUrl,
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
