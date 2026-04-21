import 'dart:convert';

import '../config.dart';
import 'media_model.dart';

class BlogModel {
  int? id;
  String? title;
  String? slug;
  String? description;
  String? content;
  String? metaTitle;
  String? metaDescription;
  int? isFeatured;
  int? status;
  int? createdById;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? commentsCount;
  String? webImgThumbUrl;
  List<Media>? media;
  List<Category>? categories;
  CreatedBy? createdBy;
  List<Tag>? tags;


  BlogModel({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.content,
    this.metaTitle,
    this.metaDescription,
    this.isFeatured,
    this.status,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.commentsCount,
    this.webImgThumbUrl,
    this.media,
    this.categories,
    this.createdBy,
    this.tags,
  });

  BlogModel copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    String? content,
    String? metaTitle,
    String? metaDescription,
    int? isFeatured,
    int? status,
    int? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    int? commentsCount,
    String? webImgThumbUrl,
    List<Media>? media,
    List<Category>? categories,
    CreatedBy? createdBy,
    List<Tag>? tags,
  }) =>
      BlogModel(
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        description: description ?? this.description,
        content: content ?? this.content,
        metaTitle: metaTitle ?? this.metaTitle,
        metaDescription: metaDescription ?? this.metaDescription,
        isFeatured: isFeatured ?? this.isFeatured,
        status: status ?? this.status,
        createdById: createdById ?? this.createdById,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        commentsCount: commentsCount ?? this.commentsCount,
        webImgThumbUrl: webImgThumbUrl ?? this.webImgThumbUrl,
        media: media ?? this.media,
        categories: categories ?? this.categories,
        createdBy: createdBy ?? this.createdBy,
        tags: tags ?? this.tags,
      );

  factory BlogModel.fromRawJson(String str) => BlogModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogModel.fromJson(Map<String, dynamic> json) => BlogModel(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    content: json["content"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    isFeatured: json["is_featured"],
    status: json["status"],
    createdById: json["created_by_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    commentsCount: json["comments_count"],
    webImgThumbUrl: json["web_img_thumb_url"],
    media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    createdBy: json["created_by"] == null ? null : CreatedBy.fromJson(json["created_by"]),
    tags: json["tags"] == null ? [] : List<Tag>.from(json["tags"]!.map((x) => Tag.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "description": description,
    "content": content,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "is_featured": isFeatured,
    "status": status,
    "created_by_id": createdById,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "comments_count": commentsCount,
    "web_img_thumb_url": webImgThumbUrl,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "created_by": createdBy?.toJson(),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
  };
}

class Category {
  int? id;
  String? title;
  String? slug;
  String? description;
  dynamic parentId;
  dynamic metaTitle;
  dynamic metaDescription;
  int? commission;
  int? status;
  int? isFeatured;
  String? categoryType;
  int? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? servicesCount;
  CategoryPivot? pivot;
  List<dynamic>? media;
  List<dynamic>? zones;

  Category({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.parentId,
    this.metaTitle,
    this.metaDescription,
    this.commission,
    this.status,
    this.isFeatured,
    this.categoryType,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.servicesCount,
    this.pivot,
    this.media,
    this.zones,
  });

  Category copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    dynamic parentId,
    dynamic metaTitle,
    dynamic metaDescription,
    int? commission,
    int? status,
    int? isFeatured,
    String? categoryType,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    int? servicesCount,
    CategoryPivot? pivot,
    List<dynamic>? media,
    List<dynamic>? zones,
  }) =>
      Category(
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        description: description ?? this.description,
        parentId: parentId ?? this.parentId,
        metaTitle: metaTitle ?? this.metaTitle,
        metaDescription: metaDescription ?? this.metaDescription,
        commission: commission ?? this.commission,
        status: status ?? this.status,
        isFeatured: isFeatured ?? this.isFeatured,
        categoryType: categoryType ?? this.categoryType,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        servicesCount: servicesCount ?? this.servicesCount,
        pivot: pivot ?? this.pivot,
        media: media ?? this.media,
        zones: zones ?? this.zones,
      );

  factory Category.fromRawJson(String str) => Category.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    parentId: json["parent_id"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    commission: json["commission"],
    status: json["status"],
    isFeatured: json["is_featured"],
    categoryType: json["category_type"],
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    servicesCount: json["services_count"],
    pivot: json["pivot"] == null ? null : CategoryPivot.fromJson(json["pivot"]),
    media: json["media"] == null ? [] : List<dynamic>.from(json["media"]!.map((x) => x)),
    zones: json["zones"] == null ? [] : List<dynamic>.from(json["zones"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "description": description,
    "parent_id": parentId,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "commission": commission,
    "status": status,
    "is_featured": isFeatured,
    "category_type": categoryType,
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "services_count": servicesCount,
    "pivot": pivot?.toJson(),
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
    "zones": zones == null ? [] : List<dynamic>.from(zones!.map((x) => x)),
  };
}

class CategoryPivot {
  int? blogId;
  int? categoryId;

  CategoryPivot({
    this.blogId,
    this.categoryId,
  });

  CategoryPivot copyWith({
    int? blogId,
    int? categoryId,
  }) =>
      CategoryPivot(
        blogId: blogId ?? this.blogId,
        categoryId: categoryId ?? this.categoryId,
      );

  factory CategoryPivot.fromRawJson(String str) => CategoryPivot.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoryPivot.fromJson(Map<String, dynamic> json) => CategoryPivot(
    blogId: json["blog_id"],
    categoryId: json["category_id"],
  );

  Map<String, dynamic> toJson() => {
    "blog_id": blogId,
    "category_id": categoryId,
  };
}

class CreatedBy {
  int? id;
  String? name;
  String? slug;
  String? email;
  int? systemReserve;
  int? served;
  int? phone;
  int? code;
  dynamic firebaseUid;
  dynamic providerId;
  int? status;
  int? isFeatured;
  int? isVerified;
  dynamic type;
  DateTime? emailVerifiedAt;
  dynamic fcmToken;
  dynamic experienceInterval;
  dynamic experienceDuration;
  dynamic description;
  int? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  dynamic companyId;
  dynamic locationCordinates;
  int? bookingsCount;
  int? reviewsCount;
  // Role? role;
  int? reviewRatings;
  List<int>? providerRatingList;
  List<int>? serviceManRatingList;
  // PrimaryAddress? primaryAddress;
  int? totalDaysExperience;
  int? servicemanReviewRatings;
  List<dynamic>? media;
  dynamic wallet;
  dynamic providerWallet;
  dynamic servicemanWallet;
  List<dynamic>? knownLanguages;
  List<dynamic>? expertise;
  List<dynamic>? zones;
  dynamic provider;
  // List<Role>? roles;
  List<dynamic>? reviews;
  List<dynamic>? servicemanreviews;

  CreatedBy({
    this.id,
    this.name,
    this.slug,
    this.email,
    this.systemReserve,
    this.served,
    this.phone,
    this.code,
    this.firebaseUid,
    this.providerId,
    this.status,
    this.isFeatured,
    this.isVerified,
    this.type,
    this.emailVerifiedAt,
    this.fcmToken,
    this.experienceInterval,
    this.experienceDuration,
    this.description,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.companyId,
    this.locationCordinates,
    this.bookingsCount,
    this.reviewsCount,
    // this.role,
    this.reviewRatings,
    this.providerRatingList,
    this.serviceManRatingList,

    this.totalDaysExperience,
    this.servicemanReviewRatings,
    this.media,
    this.wallet,
    this.providerWallet,
    this.servicemanWallet,
    this.knownLanguages,
    this.expertise,
    this.zones,
    this.provider,
    // this.roles,
    this.reviews,
    this.servicemanreviews,
  });

  CreatedBy copyWith({
    int? id,
    String? name,
    String? slug,
    String? email,
    int? systemReserve,
    int? served,
    int? phone,
    int? code,
    dynamic firebaseUid,
    dynamic providerId,
    int? status,
    int? isFeatured,
    int? isVerified,
    dynamic type,
    DateTime? emailVerifiedAt,
    dynamic fcmToken,
    dynamic experienceInterval,
    dynamic experienceDuration,
    dynamic description,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    dynamic companyId,
    dynamic locationCordinates,
    int? bookingsCount,
    int? reviewsCount,
    // Role? role,
    int? reviewRatings,
    List<int>? providerRatingList,
    List<int>? serviceManRatingList,
    // PrimaryAddress? primaryAddress,
    int? totalDaysExperience,
    int? servicemanReviewRatings,
    List<dynamic>? media,
    dynamic wallet,
    dynamic providerWallet,
    dynamic servicemanWallet,
    List<dynamic>? knownLanguages,
    List<dynamic>? expertise,
    List<dynamic>? zones,
    dynamic provider,
    // List<Role>? roles,
    List<dynamic>? reviews,
    List<dynamic>? servicemanreviews,
  }) =>
      CreatedBy(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        email: email ?? this.email,
        systemReserve: systemReserve ?? this.systemReserve,
        served: served ?? this.served,
        phone: phone ?? this.phone,
        code: code ?? this.code,
        firebaseUid: firebaseUid ?? this.firebaseUid,
        providerId: providerId ?? this.providerId,
        status: status ?? this.status,
        isFeatured: isFeatured ?? this.isFeatured,
        isVerified: isVerified ?? this.isVerified,
        type: type ?? this.type,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        fcmToken: fcmToken ?? this.fcmToken,
        experienceInterval: experienceInterval ?? this.experienceInterval,
        experienceDuration: experienceDuration ?? this.experienceDuration,
        description: description ?? this.description,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        companyId: companyId ?? this.companyId,
        locationCordinates: locationCordinates ?? this.locationCordinates,
        bookingsCount: bookingsCount ?? this.bookingsCount,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        // role: role ?? this.role,
        reviewRatings: reviewRatings ?? this.reviewRatings,
        providerRatingList: providerRatingList ?? this.providerRatingList,
        serviceManRatingList: serviceManRatingList ?? this.serviceManRatingList,
        // primaryAddress: primaryAddress ?? this.primaryAddress,
        totalDaysExperience: totalDaysExperience ?? this.totalDaysExperience,
        servicemanReviewRatings: servicemanReviewRatings ?? this.servicemanReviewRatings,
        media: media ?? this.media,
        wallet: wallet ?? this.wallet,
        providerWallet: providerWallet ?? this.providerWallet,
        servicemanWallet: servicemanWallet ?? this.servicemanWallet,
        knownLanguages: knownLanguages ?? this.knownLanguages,
        expertise: expertise ?? this.expertise,
        zones: zones ?? this.zones,
        provider: provider ?? this.provider,
        // roles: roles ?? this.roles,
        reviews: reviews ?? this.reviews,
        servicemanreviews: servicemanreviews ?? this.servicemanreviews,
      );

  factory CreatedBy.fromRawJson(String str) => CreatedBy.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    email: json["email"],
    systemReserve: json["system_reserve"],
    served: json["served"],
    phone: json["phone"],
    code: json["code"],
    firebaseUid: json["firebase_uid"],
    providerId: json["provider_id"],
    status: json["status"],
    isFeatured: json["is_featured"],
    isVerified: json["is_verified"],
    type: json["type"],
    emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
    fcmToken: json["fcm_token"],
    experienceInterval: json["experience_interval"],
    experienceDuration: json["experience_duration"],
    description: json["description"],
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    companyId: json["company_id"],
    locationCordinates: json["location_cordinates"],
    bookingsCount: json["bookings_count"],
    reviewsCount: json["reviews_count"],
    // role: json["role"] == null ? null : Role.fromJson(json["role"]),
    reviewRatings: json["review_ratings"],
    providerRatingList: json["provider_rating_list"] == null ? [] : List<int>.from(json["provider_rating_list"]!.map((x) => x)),
    serviceManRatingList: json["service_man_rating_list"] == null ? [] : List<int>.from(json["service_man_rating_list"]!.map((x) => x)),
    // primaryAddress: json["primary_address"] == null ? null : PrimaryAddress.fromJson(json["primary_address"]),
    totalDaysExperience: json["total_days_experience"],
    servicemanReviewRatings: json["ServicemanReviewRatings"],
    media: json["media"] == null ? [] : List<dynamic>.from(json["media"]!.map((x) => x)),
    wallet: json["wallet"],
    providerWallet: json["provider_wallet"],
    servicemanWallet: json["serviceman_wallet"],
    knownLanguages: json["known_languages"] == null ? [] : List<dynamic>.from(json["known_languages"]!.map((x) => x)),
    expertise: json["expertise"] == null ? [] : List<dynamic>.from(json["expertise"]!.map((x) => x)),
    zones: json["zones"] == null ? [] : List<dynamic>.from(json["zones"]!.map((x) => x)),
    provider: json["provider"],
    // roles: json["roles"] == null ? [] : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
    reviews: json["reviews"] == null ? [] : List<dynamic>.from(json["reviews"]!.map((x) => x)),
    servicemanreviews: json["servicemanreviews"] == null ? [] : List<dynamic>.from(json["servicemanreviews"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "email": email,
    "system_reserve": systemReserve,
    "served": served,
    "phone": phone,
    "code": code,
    "firebase_uid": firebaseUid,
    "provider_id": providerId,
    "status": status,
    "is_featured": isFeatured,
    "is_verified": isVerified,
    "type": type,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "fcm_token": fcmToken,
    "experience_interval": experienceInterval,
    "experience_duration": experienceDuration,
    "description": description,
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "company_id": companyId,
    "location_cordinates": locationCordinates,
    "bookings_count": bookingsCount,
    "reviews_count": reviewsCount,
    // "role": role?.toJson(),
    "review_ratings": reviewRatings,
    "provider_rating_list": providerRatingList == null ? [] : List<dynamic>.from(providerRatingList!.map((x) => x)),
    "service_man_rating_list": serviceManRatingList == null ? [] : List<dynamic>.from(serviceManRatingList!.map((x) => x)),
    // "primary_address": primaryAddress?.toJson(),
    "total_days_experience": totalDaysExperience,
    "ServicemanReviewRatings": servicemanReviewRatings,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
    "wallet": wallet,
    "provider_wallet": providerWallet,
    "serviceman_wallet": servicemanWallet,
    "known_languages": knownLanguages == null ? [] : List<dynamic>.from(knownLanguages!.map((x) => x)),
    "expertise": expertise == null ? [] : List<dynamic>.from(expertise!.map((x) => x)),
    "zones": zones == null ? [] : List<dynamic>.from(zones!.map((x) => x)),
    "provider": provider,
    // "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x.toJson())),
    "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x)),
    "userservicemanreviews": servicemanreviews == null ? [] : List<dynamic>.from(servicemanreviews!.map((x) => x)),
  };
}


class Tag {
  int? id;
  String? name;
  String? slug;
  String? type;
  String? description;
  int? createdById;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  TagPivot? pivot;

  Tag({
    this.id,
    this.name,
    this.slug,
    this.type,
    this.description,
    this.createdById,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.pivot,
  });

  Tag copyWith({
    int? id,
    String? name,
    String? slug,
    String? type,
    String? description,
    int? createdById,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    TagPivot? pivot,
  }) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        type: type ?? this.type,
        description: description ?? this.description,
        createdById: createdById ?? this.createdById,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        pivot: pivot ?? this.pivot,
      );

  factory Tag.fromRawJson(String str) => Tag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    type: json["type"],
    description: json["description"],
    createdById: json["created_by_id"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    pivot: json["pivot"] == null ? null : TagPivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "type": type,
    "description": description,
    "created_by_id": createdById,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "pivot": pivot?.toJson(),
  };
}

class TagPivot {
  int? blogId;
  int? tagId;

  TagPivot({
    this.blogId,
    this.tagId,
  });

  TagPivot copyWith({
    int? blogId,
    int? tagId,
  }) =>
      TagPivot(
        blogId: blogId ?? this.blogId,
        tagId: tagId ?? this.tagId,
      );

  factory TagPivot.fromRawJson(String str) => TagPivot.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TagPivot.fromJson(Map<String, dynamic> json) => TagPivot(
    blogId: json["blog_id"],
    tagId: json["tag_id"],
  );

  Map<String, dynamic> toJson() => {
    "blog_id": blogId,
    "tag_id": tagId,
  };
}
