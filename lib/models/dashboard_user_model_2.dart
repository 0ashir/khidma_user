import 'dart:convert';

import 'package:fixit_user/models/service_model.dart';

import 'category_advertisement_model.dart';

DashboardModel2 dashBoardModel2FromJson(String str) =>
    DashboardModel2.fromJson(json.decode(str));

String dashBoardModel2ToJson(DashboardModel2 data) =>
    json.encode(data.toJson());

class DashboardModel2 {
  List<HighestRatedProvider>? highestRatedProviders;
  List<Blog>? blogs;
  List<HomeAdvertisement>? homeBannerAdvertisements;
  List<HomeAdvertisement>? homeServicesAdvertisements;

  DashboardModel2({
    this.highestRatedProviders,
    this.blogs,
    this.homeBannerAdvertisements,
    this.homeServicesAdvertisements,
  });

  factory DashboardModel2.fromJson(Map<String, dynamic> json) =>
      DashboardModel2(
        highestRatedProviders: json["highestRatedProviders"] == null
            ? []
            : List<HighestRatedProvider>.from(json["highestRatedProviders"]!
                .map((x) => HighestRatedProvider.fromJson(x))),
        blogs: json["blogs"] == null
            ? []
            : List<Blog>.from(json["blogs"]!.map((x) => Blog.fromJson(x))),
        homeBannerAdvertisements: json["home_banner_advertisements"] == null
            ? []
            : List<HomeAdvertisement>.from(json["home_banner_advertisements"]!
                .map((x) => HomeAdvertisement.fromJson(x))),
        homeServicesAdvertisements: json["home_services_advertisements"] == null
            ? []
            : List<HomeAdvertisement>.from(json["home_services_advertisements"]!
                .map((x) => HomeAdvertisement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "highestRatedProviders": highestRatedProviders == null
            ? []
            : List<dynamic>.from(highestRatedProviders!.map((x) => x.toJson())),
        "blogs": blogs == null
            ? []
            : List<dynamic>.from(blogs!.map((x) => x.toJson())),
        "home_banner_advertisements": homeBannerAdvertisements == null
            ? []
            : List<dynamic>.from(
                homeBannerAdvertisements!.map((x) => x.toJson())),
        "home_services_advertisements": homeServicesAdvertisements == null
            ? []
            : List<dynamic>.from(
                homeServicesAdvertisements!.map((x) => x.toJson())),
      };
}

class Blog {
  int? id;
  String? title;
  String? description;
  // String? content;
  DateTime? createdAt;
  CreatedBy? createdBy;
  List<Tag>? tags;
  List<BlogMedia>? media;
  List<Category>? categories;

  Blog({
    this.id,
    this.title,
    this.description,
    // this.content,
    this.createdAt,
    this.createdBy,
    this.tags,
    this.media,
    this.categories,
  });

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        // content: json["content"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        createdBy: json["created_by"] == null
            ? null
            : CreatedBy.fromJson(json["created_by"]),
        tags: json["tags"] == null
            ? []
            : List<Tag>.from(json["tags"]!.map((x) => Tag.fromJson(x))),
        media: json["media"] == null
            ? []
            : List<BlogMedia>.from(
                json["media"]!.map((x) => BlogMedia.fromJson(x))),
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        // "content": content,
        "created_at": createdAt?.toIso8601String(),
        "created_by": createdBy?.toJson(),
        "tags": tags == null
            ? []
            : List<dynamic>.from(tags!.map((x) => x.toJson())),
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
      };
}

class Category {
  int? id;
  String? title;

  Category({
    this.id,
    this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}

class CreatedBy {
  int? id;
  Name? name;

  CreatedBy({
    this.id,
    this.name,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        name: nameValues.map[json["name"]]!,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": nameValues.reverse[name],
      };
}

enum Name { ADMIN }

final nameValues = EnumValues({"admin": Name.ADMIN});

class BlogMedia {
  int? id;
  String? originalUrl;

  BlogMedia({
    this.id,
    this.originalUrl,
  });

  factory BlogMedia.fromJson(Map<String, dynamic> json) => BlogMedia(
        id: json["id"],
        originalUrl: json["original_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "original_url": originalUrl,
      };
}

class Tag {
  int? id;
  String? name;
  Type? type;

  Tag({
    this.id,
    this.name,
    this.type,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        name: json["name"],
        type: typeValues.map[json["type"]]!,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": typeValues.reverse[type],
      };
}

enum Type { BLOG }

final typeValues = EnumValues({"blog": Type.BLOG});

class HighestRatedProvider {
  int? id;
  String? name;
  String? email;
  int? experienceDuration;
  String? experienceInterval;
  double? reviewRatings;
  int? isFeatured;
  int? isFavourite;
  int? isFavouriteId;
  int? isVerified;
  dynamic bookingsCount;

  List<HighestRatedProviderMedia>? media;

  HighestRatedProvider(
      {this.id,
      this.name,
      this.email,
      this.experienceInterval,
      this.experienceDuration,
      this.reviewRatings,
      this.isFeatured,
      this.isVerified,
      this.bookingsCount,
      this.media,
      this.isFavourite,
      this.isFavouriteId});

  factory HighestRatedProvider.fromJson(Map<String, dynamic> json) =>
      HighestRatedProvider(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        experienceInterval: json['experience_interval'],
        experienceDuration: json['experience_duration'],
        reviewRatings: json["review_ratings"]?.toDouble(),
        isFeatured: json["is_featured"],
        isVerified: json["is_verified"],
        isFavourite: json["is_favourite"],
        isFavouriteId: json["is_favourite_id"],
        bookingsCount: json["bookings_count"],
        media: json["media"] == null
            ? []
            : List<HighestRatedProviderMedia>.from(json["media"]!
                .map((x) => HighestRatedProviderMedia.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "experience_duration": experienceDuration,
        "experience_interval": experienceInterval,
        "review_ratings": reviewRatings,
        "is_featured": isFeatured,
        "is_verified": isVerified,
        "bookings_count": bookingsCount,
        "is_favourite": isFavourite,
        "is_favourite_id": isFavouriteId,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
      };
}

class HighestRatedProviderMedia {
  String? originalUrl;

  HighestRatedProviderMedia({
    this.originalUrl,
  });

  factory HighestRatedProviderMedia.fromJson(Map<String, dynamic> json) =>
      HighestRatedProviderMedia(
        originalUrl: json["original_url"],
      );

  Map<String, dynamic> toJson() => {
        "original_url": originalUrl,
      };
}

class HomeAdvertisement {
  int? id;
  BannerType? bannerType;
  String? videoLink;
  List<BlogMedia>? media;
  String? advertisementType;
  String? advertisementScreen;
  int? providerId;
  List<Services>? services;

  HomeAdvertisement({
    this.id,
    this.bannerType,
    this.videoLink,
    this.media,
    this.advertisementType,
    this.advertisementScreen,
    this.providerId,
    this.services,
  });

  factory HomeAdvertisement.fromJson(Map<String, dynamic> json) =>
      HomeAdvertisement(
        id: json["id"],
        bannerType: bannerTypeValues.map[json["banner_type"]],
        videoLink: json["video_link"],
        media: json["media"] == null
            ? []
            : List<BlogMedia>.from(
                json["media"]!.map((x) => BlogMedia.fromJson(x))),
        advertisementType: json["advertisement_type"],
        advertisementScreen: json["advertisement_screen"],
        providerId: json["provider_id"],
        services: json["services"] == null
            ? []
            : List<Services>.from(
                json["services"]!.map((x) => Services.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "banner_type": bannerTypeValues.reverse[bannerType],
        "video_link": videoLink,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
        "advertisement_type": advertisementType,
        "advertisement_screen": advertisementScreen,
        "provider_id": providerId,
        "services": services == null
            ? []
            : List<dynamic>.from(services!.map((x) => x.toJson())),
      };
}

enum BannerType { IMAGE, THUMBNAIL, WEB_IMAGES, WEB_THUMBNAIL }

final bannerTypeValues = EnumValues({
  "image": BannerType.IMAGE,
  "thumbnail": BannerType.THUMBNAIL,
  "web_images": BannerType.WEB_IMAGES,
  "web_thumbnail": BannerType.WEB_THUMBNAIL
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class FeaturedServices {
  int? id;
  String? duration;
  String? durationUnit;
  int? requiredServicemen;
  String? title;
  int? discount;
  dynamic price;
  dynamic serviceRate;
  String? description;
  String? type;
  List<Media>? media;
  int? status;
  User? user;

  FeaturedServices(
      {this.id,
      this.duration,
      this.durationUnit,
      this.requiredServicemen,
      this.title,
      this.discount,
      this.type,
      this.price,
      this.serviceRate,
      this.description,
      this.media,
      this.status,
      this.user});

  FeaturedServices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    duration = json['duration'];
    durationUnit = json['duration_unit'];
    requiredServicemen = json['required_servicemen'];
    title = json['title'];
    discount = json['discount'];
    price = json['price'];
    type = json['type'];
    serviceRate = json['service_rate'];
    description = json['description'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    status = json['status'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['duration'] = duration;
    data['duration_unit'] = durationUnit;
    data['required_servicemen'] = requiredServicemen;
    data['title'] = title;
    data['discount'] = discount;
    data['type'] = type;
    data['price'] = price;
    data['service_rate'] = serviceRate;
    data['description'] = description;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  dynamic reviewRatings;
  List<Media>? media;

  User({this.id, this.name, this.reviewRatings, this.media});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    reviewRatings = json['review_ratings'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['review_ratings'] = reviewRatings;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
