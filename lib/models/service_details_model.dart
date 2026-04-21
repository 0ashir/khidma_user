/* class ServiceDetailsModel {
  ServiceDetailsModel({
    this.id,
    this.title,
    this.price,
    this.status,
    this.duration,
    this.taxes,
    this.description,
    this.durationUnit,
    this.discount,
    this.parentId,
    this.type,
    this.isFavourite,
    this.isFavouriteId,
    this.video,
    this.isFeatured,
    this.isAdvertised,
    this.serviceRate,
    this.requiredServicemen,
    this.selectedRequiredServiceMan,
    this.additionalServices,
    this.selectedAdditionalServices,
    this.media,
    this.user,
    this.relatedServices,
    this.reviews,
    this.categories,
  });

  final dynamic id;
  final String? title;
  final dynamic price;
  final dynamic status;
  final String? duration;
  final String? description;
  final String? durationUnit;
  final dynamic discount;
  final dynamic parentId;
  final String? type;
  final String? video;
  final List<Tax>? taxes;
  final dynamic isFeatured;
  int? isFavourite;
  final List<Category>? categories;
  final int? isFavouriteId;
  final dynamic isAdvertised;
  final dynamic serviceRate;
  final dynamic requiredServicemen;
  dynamic selectedRequiredServiceMan;
  final List<AdditionalService>? additionalServices;
  List<AdditionalService>? selectedAdditionalServices;
  final List<ServiceDetailsModelMedia>? media;
  final User? user;
  final List<RelatedService>? relatedServices;
  final List<dynamic>? reviews;

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      status: json["status"],
      duration: json["duration"],
      description: json["content"],
      durationUnit: json["duration_unit"],
      discount: json["discount"],
      parentId: json["parent_id"],
      type: json["type"],
      video: json["video"],
      taxes: json["taxes"] == null
          ? []
          : List<Tax>.from(json["taxes"]!.map((x) => Tax.fromJson(x))),
      isFeatured: json["is_featured"],
      isFavourite: json["is_favourite"],
      isFavouriteId: json["is_favourite_id"],
      isAdvertised: json["is_advertised"],
      selectedAdditionalServices: json['selectedAdditionalServices'],
      serviceRate: json["service_rate"],
      requiredServicemen: json["required_servicemen"],
      selectedRequiredServiceMan: json["required_servicemen"],
      additionalServices: json["additional_services"] == null
          ? []
          : List<AdditionalService>.from(json["additional_services"]!
              .map((x) => AdditionalService.fromJson(x))),
      media: json["media"] == null
          ? []
          : List<ServiceDetailsModelMedia>.from(
              json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      relatedServices: json["related_services"] == null
          ? []
          : List<RelatedService>.from(
              json["related_services"]!.map((x) => RelatedService.fromJson(x))),
      reviews: json["reviews"] == null
          ? []
          : List<dynamic>.from(json["reviews"]!.map((x) => x)),
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "status": status,
        "duration": duration,
        "content": description,
        "taxes": taxes?.map((x) => x.toJson()).toList(),
        "duration_unit": durationUnit,
        "discount": discount,
        "parent_id": parentId,
        "type": type,
        "is_favourite": isFavourite,
        "is_favourite_id": isFavouriteId,
        "video": video,
        "is_featured": isFeatured,
        "is_advertised": isAdvertised,
        "service_rate": serviceRate,
        "required_servicemen": requiredServicemen,
        "selectedRequiredServiceMan": selectedRequiredServiceMan,
        "categories": categories!.map((x) => x.toJson()).toList(),
        if (selectedAdditionalServices != null)
          'selectedAdditionalServices':
              selectedAdditionalServices!.map((v) => v.toJson()).toList(),
        "additional_services":
            additionalServices!.map((x) => x.toJson()).toList(),
        "media": media!.map((x) => x.toJson()).toList(),
        "user": user?.toJson(),
        "related_services": relatedServices!.map((x) => x.toJson()).toList(),
        "reviews": reviews!.map((x) => x).toList(),
      };

  @override
  String toString() {
    return "$id, $title, $price, $status, $duration, $description, $durationUnit, $discount, $parentId, $type, $video, $isFeatured, $isAdvertised, $serviceRate, $requiredServicemen, $additionalServices, $media, $user, $relatedServices, $reviews, ";
  }
}

class AdditionalService {
  AdditionalService({
    required this.id,
    required this.title,
    required this.price,
    this.qty = 1,
    this.media,
    this.totalPrice,
  });

  final dynamic id;
  final String? title;
  final dynamic price;
  int? qty;
  dynamic totalPrice;
  final List<AdditionalServiceMedia>? media;

  factory AdditionalService.fromJson(Map<String, dynamic> json) {
    return AdditionalService(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      qty: (json["qty"] ?? 1),
      totalPrice: json['total_price'],
      media: json["media"] == null
          ? []
          : List<AdditionalServiceMedia>.from(
              json["media"].map((x) => AdditionalServiceMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "qty": qty,
        "total_price": totalPrice,
        "media": media?.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$title, $price, $media, $qty, $totalPrice";
  }
}

class AdditionalServiceMedia {
  AdditionalServiceMedia({
    required this.originalId,
  });

  final String? originalId;

  factory AdditionalServiceMedia.fromJson(Map<String, dynamic> json) {
    return AdditionalServiceMedia(
      originalId: json["original_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "original_id": originalId,
      };

  @override
  String toString() {
    return "$originalId, ";
  }
}

class ServiceDetailsModelMedia {
  ServiceDetailsModelMedia({
    required this.originalUrl,
  });

  final String? originalUrl;

  factory ServiceDetailsModelMedia.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModelMedia(
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "original_url": originalUrl,
      };

  @override
  String toString() {
    return "$originalUrl, ";
  }
}

class RelatedService {
  RelatedService({
    required this.id,
    required this.title,
    required this.isFavourite,
    required this.isFavouriteId,
    required this.categories,
    required this.serviceRate,
    required this.requiredServicemen,
    required this.selectedRequiredServiceMan,
    required this.price,
    required this.media,
  });

  final dynamic id;
  final String? title;
  final int? isFavourite;
  final int? isFavouriteId;
  final List<Category> categories;
  final dynamic serviceRate;
  final dynamic requiredServicemen;
  int? selectedRequiredServiceMan;
  final dynamic price;
  final List<ServiceDetailsModelMedia> media;

  factory RelatedService.fromJson(Map<String, dynamic> json) {
    return RelatedService(
      id: json["id"],
      title: json["title"],
      isFavourite: json["is_favourite"],
      isFavouriteId: json["is_favourite_id"],
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
      serviceRate: json["service_rate"] is int
          ? (json["service_rate"] as int).toDouble()
          : json["service_rate"] is double
              ? json["service_rate"]
              : null,
      requiredServicemen: json["required_servicemen"],
      selectedRequiredServiceMan: json["required_servicemen"],
      price: json["price"],
      media: json["media"] == null
          ? []
          : List<ServiceDetailsModelMedia>.from(
              json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "is_favourite": isFavourite,
        "is_favourite_id": isFavouriteId,
        "categories": categories.map((x) => x.toJson()).toList(),
        "service_rate": serviceRate,
        "required_servicemen": requiredServicemen,
        "selectedRequiredServiceMan": selectedRequiredServiceMan,
        "price": price,
        "media": media.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$id, $title, $isFavourite, $categories, $serviceRate, $requiredServicemen, $price, $media, ";
  }
}

class Tax {
  final int? id;
  final String? name;
  final double? rate;
  final dynamic? amount;

  Tax({this.id, this.name, this.rate, this.amount});

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        rate: (json['rate'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rate': rate,
        'amount': amount,
      };
}

class Category {
  Category({
    required this.title,
  });

  final String? title;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
      };

  @override
  String toString() {
    return "$title, ";
  }
}

class User {
  User({
    required this.id,
    required this.name,
    required this.reviewRatings,
    required this.media,
    required this.experienceInterval,
    required this.experienceDuration,
    required this.served,
    required this.fcmToken,
  });

  final dynamic id;
  final String? name;
  final dynamic reviewRatings;
  final List<ServiceDetailsModelMedia> media;
  final String? experienceInterval;
  final dynamic experienceDuration;
  final dynamic served;
  final dynamic fcmToken;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      reviewRatings: json["review_ratings"],
      media: json["media"] == null
          ? []
          : List<ServiceDetailsModelMedia>.from(
              json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
      experienceInterval: json["experience_interval"],
      experienceDuration: json["experience_duration"],
      served: json["served"],
      fcmToken: json["fcm_token"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "review_ratings": reviewRatings,
        "media": media.map((x) => x.toJson()).toList(),
        "experience_interval": experienceInterval,
        "experience_duration": experienceDuration,
        "served": served,
        "fcm_token": fcmToken,
      };

  @override
  String toString() {
    return "$id, $name, $reviewRatings, $media, $experienceInterval, $experienceDuration, $served,$fcmToken ";
  }
}

/*
class ServiceDetailsModel {
  ServiceDetailsModel({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.duration,
    required this.description,
    required this.durationUnit,
    required this.discount,
    required this.parentId,
    required this.type,
    required this.video,
    required this.isFeatured,
    required this.isAdvertised,
    required this.isRandomRelatedServices,
    required this.serviceRate,
    required this.requiredServicemen,
    required this.serviceType,
    required this.media,
    required this.user,
    required this.relatedServices,
  });

  final dynamic id;
  final String? title;
  final dynamic price;
  final dynamic status;
  final String? duration;
  final String? description;
  final String? durationUnit;
  final String? video;
  final dynamic discount;
  final dynamic parentId;
  final String? type;
  final dynamic isFeatured;
  final dynamic isAdvertised;
  final dynamic isRandomRelatedServices;
  final dynamic serviceRate;
  final dynamic requiredServicemen;
  final dynamic serviceType;
  final List<ServiceDetailsModelMedia> media;
  final User? user;
  final List<RelatedService> relatedServices;

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json){
    return ServiceDetailsModel(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      status: json["status"],
      duration: json["duration"],
      description: json["description"],
      video: json["video"],
      durationUnit: json["duration_unit"],
      discount: json["discount"],
      parentId: json["parent_id"],
      type: json["type"],
      isFeatured: json["is_featured"],
      isAdvertised: json["is_advertised"],
      isRandomRelatedServices: json["is_random_related_services"],
      serviceRate: json["service_rate"],
      requiredServicemen: json["required_servicemen"],
      serviceType: json["service_type"],
      media: json["media"] == null ? [] : List<ServiceDetailsModelMedia>.from(json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      relatedServices: json["related_services"] == null ? [] : List<RelatedService>.from(json["related_services"]!.map((x) => RelatedService.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "status": status,
    "duration": duration,
    "description": description,
    "duration_unit": durationUnit,
    "discount": discount,
    "parent_id": parentId,
    "type": type,
    "video": video,
    "is_featured": isFeatured,
    "is_advertised": isAdvertised,
    "is_random_related_services": isRandomRelatedServices,
    "service_rate": serviceRate,
    "required_servicemen": requiredServicemen,
    "service_type": serviceType,
    "media": media.map((x) => x.toJson()).toList(),
    "user": user?.toJson(),
    "related_services": relatedServices.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $title, $price, $status, $duration, $description, $durationUnit, $discount, $parentId, $type, $isFeatured, $isAdvertised, $isRandomRelatedServices, $serviceRate, $requiredServicemen, $serviceType, $media, $user, $relatedServices, ";
  }
}

class ServiceDetailsModelMedia {
  ServiceDetailsModelMedia({
    required this.id,
    required this.collectionName,
    required this.originalUrl,
  });

  final dynamic id;
  final String? collectionName;
  final String? originalUrl;

  factory ServiceDetailsModelMedia.fromJson(Map<String, dynamic> json){
    return ServiceDetailsModelMedia(
      id: json["id"],
      collectionName: json["collection_name"],
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "collection_name": collectionName,
    "original_url": originalUrl,
  };

  @override
  String toString(){
    return "$id, $collectionName, $originalUrl, ";
  }
}

class RelatedService {
  RelatedService({
    required this.id,
    required this.title,
    required this.categories,
    required this.serviceRate,
    required this.price,
    required this.media,
  });

  final dynamic id;
  final String? title;
  final List<Category> categories;
  final double? serviceRate;
  final dynamic price;
  final List<RelatedServiceMedia> media;

  factory RelatedService.fromJson(Map<String, dynamic> json){
    return RelatedService(
      id: json["id"],
      title: json["title"],
      categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
      serviceRate: json["service_rate"] is int
          ? (json["service_rate"] as int).toDouble()
          : json["service_rate"] is double
          ? json["service_rate"]
          : null,
      price: json["price"],
      media: json["media"] == null ? [] : List<RelatedServiceMedia>.from(json["media"]!.map((x) => RelatedServiceMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "categories": categories.map((x) => x.toJson()).toList(),
    "service_rate": serviceRate,
    "price": price,
    "media": media.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $title, $categories, $serviceRate, $price, $media, ";
  }
}

class Category {
  Category({
    required this.title,
  });

  final String? title;

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
  };

  @override
  String toString(){
    return "$title, ";
  }
}

class RelatedServiceMedia {
  RelatedServiceMedia({
    required this.originalUrl,
  });

  final String? originalUrl;

  factory RelatedServiceMedia.fromJson(Map<String, dynamic> json){
    return RelatedServiceMedia(
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "original_url": originalUrl,
  };

  @override
  String toString(){
    return "$originalUrl, ";
  }
}

class User {
  User({
    required this.id,
    required this.name,
    required this.reviewRatings,
    required this.media,
    required this.experienceInterval,
    required this.experienceDuration,
    required this.served,
  });

  final dynamic id;
  final String? name;
  final dynamic reviewRatings;
  final List<RelatedServiceMedia> media;
  final String? experienceInterval;
  final dynamic experienceDuration;
  final dynamic served;

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json["id"],
      name: json["name"],
      reviewRatings: json["review_ratings"],
      media: json["media"] == null ? [] : List<RelatedServiceMedia>.from(json["media"]!.map((x) => RelatedServiceMedia.fromJson(x))),
      experienceInterval: json["experience_interval"],
      experienceDuration: json["experience_duration"],
      served: json["served"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "review_ratings": reviewRatings,
    "media": media.map((x) => x.toJson()).toList(),
    "experience_interval": experienceInterval,
    "experience_duration": experienceDuration,
    "served": served,
  };

  @override
  String toString(){
    return "$id, $name, $reviewRatings, $media, $experienceInterval, $experienceDuration, $served, ";
  }
}
*/
 */
class ServiceDetailsModel {
  ServiceDetailsModel({
    this.id,
    this.title,
    this.price,
    this.status,
    this.duration,
    this.taxes,
    this.description,
    this.durationUnit,
    this.discount,
    this.parentId,
    this.type,
    this.isFavourite,
    this.isFavouriteId,
    this.video,
    this.isFeatured,
    this.isAdvertised,
    this.serviceRate,
    this.requiredServicemen,
    this.selectedRequiredServiceMan,
    this.additionalServices,
    this.selectedAdditionalServices,
    this.media,
    this.user,
    this.relatedServices,
    this.content,
    this.reviews,
    this.categories,
  });

  final dynamic id;
  final String? title;
  final dynamic price;
  final dynamic status;
  final String? duration;
  final String? description;
  final String? durationUnit;
  final dynamic discount;
  final dynamic parentId;
  final String? type;
  final String? content;
  final String? video;
  final List<Tax>? taxes;
  final dynamic isFeatured;
  int? isFavourite;
  final List<Category>? categories;
  final int? isFavouriteId;
  final dynamic isAdvertised;
  final dynamic serviceRate;
  final dynamic requiredServicemen;
  dynamic selectedRequiredServiceMan;
  final List<AdditionalService>? additionalServices;
  List<AdditionalService>? selectedAdditionalServices;
  final List<ServiceDetailsModelMedia>? media;
  final User? user;
  final List<RelatedService>? relatedServices;
  final List<dynamic>? reviews;

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      status: json["status"],
      duration: json["duration"],
      description: json["description"],
      durationUnit: json["duration_unit"],
      discount: json["discount"],
      parentId: json["parent_id"],
      content: json["content"],
      type: json["type"],
      video: json["video"],
      taxes: json["taxes"] == null
          ? []
          : List<Tax>.from(json["taxes"]!.map((x) => Tax.fromJson(x))),
      isFeatured: json["is_featured"],
      isFavourite: json["is_favourite"],
      isFavouriteId: json["is_favourite_id"],
      isAdvertised: json["is_advertised"],
      selectedAdditionalServices: json['selectedAdditionalServices'] == null
          ? []
          : List<AdditionalService>.from(
              json['selectedAdditionalServices']!.map((x) => AdditionalService.fromJson(x))),
      serviceRate: json["service_rate"],
      requiredServicemen: json["required_servicemen"],
      selectedRequiredServiceMan: json["required_servicemen"],
      additionalServices: json["additional_services"] == null
          ? []
          : List<AdditionalService>.from(json["additional_services"]!
              .map((x) => AdditionalService.fromJson(x))),
      media: json["media"] == null
          ? []
          : List<ServiceDetailsModelMedia>.from(
              json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      relatedServices: json["related_services"] == null
          ? []
          : List<RelatedService>.from(
              json["related_services"]!.map((x) => RelatedService.fromJson(x))),
      reviews: json["reviews"] == null
          ? []
          : List<dynamic>.from(json["reviews"]!.map((x) => x)),
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "status": status,
        "duration": duration,
        "description": description,
        "content": content,
        "taxes": taxes?.map((x) => x.toJson()).toList() ?? [],
        "duration_unit": durationUnit,
        "discount": discount,
        "parent_id": parentId,
        "type": type,
        "is_favourite": isFavourite,
        "is_favourite_id": isFavouriteId,
        "video": video,
        "is_featured": isFeatured,
        "is_advertised": isAdvertised,
        "service_rate": serviceRate,
        "required_servicemen": requiredServicemen,
        "selectedRequiredServiceMan": selectedRequiredServiceMan,
        "categories": categories?.map((x) => x.toJson()).toList() ?? [],
        if (selectedAdditionalServices != null)
          'selectedAdditionalServices':
              selectedAdditionalServices!.map((v) => v.toJson()).toList(),
        "additional_services":
            additionalServices?.map((x) => x.toJson()).toList() ?? [],
        "media": media?.map((x) => x.toJson()).toList() ?? [],
        "user": user?.toJson(),
        "related_services":
            relatedServices?.map((x) => x.toJson()).toList() ?? [],
        "reviews": reviews?.map((x) => x).toList() ?? [],
      };

  @override
  String toString() {
    return "$id, $title, $price, $content, $status, $duration, $description, $durationUnit, $discount, $parentId, $type, $video, $isFeatured, $isAdvertised, $serviceRate, $requiredServicemen, $additionalServices, $media, $user, $relatedServices, $reviews, ";
  }
}

class AdditionalService {
  AdditionalService({
    required this.id,
    required this.title,
    required this.price,
    this.qty = 1,
    this.media,
    this.totalPrice,
  });

  final dynamic id;
  final String? title;
  final dynamic price;
  int? qty;
  dynamic totalPrice;
  final List<AdditionalServiceMedia>? media;

  factory AdditionalService.fromJson(Map<String, dynamic> json) {
    return AdditionalService(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      qty: (json["qty"] ?? 1),
      totalPrice: json['total_price'],
      media: json["media"] == null
          ? []
          : List<AdditionalServiceMedia>.from(
              json["media"].map((x) => AdditionalServiceMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "qty": qty,
        "total_price": totalPrice,
        "media": media?.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$title, $price, $media, $qty, $totalPrice";
  }
}

class AdditionalServiceMedia {
  AdditionalServiceMedia({
    required this.originalId,
  });

  final String? originalId;

  factory AdditionalServiceMedia.fromJson(Map<String, dynamic> json) {
    return AdditionalServiceMedia(
      originalId: json["original_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "original_id": originalId,
      };

  @override
  String toString() {
    return "$originalId, ";
  }
}

class ServiceDetailsModelMedia {
  ServiceDetailsModelMedia({
    required this.originalUrl,
  });

  final String? originalUrl;

  factory ServiceDetailsModelMedia.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModelMedia(
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "original_url": originalUrl,
      };

  @override
  String toString() {
    return "$originalUrl, ";
  }
}

class RelatedService {
  RelatedService({
    required this.id,
    required this.title,
    required this.isFavourite,
    required this.isFavouriteId,
    required this.categories,
    required this.serviceRate,
    required this.requiredServicemen,
    required this.selectedRequiredServiceMan,
    required this.price,
    required this.media,
  });

  final dynamic id;
  final String? title;
  final int? isFavourite;
  final int? isFavouriteId;
  final List<Category> categories;
  final dynamic serviceRate;
  final dynamic requiredServicemen;
  int? selectedRequiredServiceMan;
  final dynamic price;
  final List<ServiceDetailsModelMedia> media;

  factory RelatedService.fromJson(Map<String, dynamic> json) {
    return RelatedService(
      id: json["id"],
      title: json["title"],
      isFavourite: json["is_favourite"],
      isFavouriteId: json["is_favourite_id"],
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
      serviceRate: json["service_rate"] is int
          ? (json["service_rate"] as int).toDouble()
          : json["service_rate"] is double
              ? json["service_rate"]
              : null,
      requiredServicemen: json["required_servicemen"],
      selectedRequiredServiceMan: json["required_servicemen"],
      price: json["price"],
      media: json["media"] == null
          ? []
          : List<ServiceDetailsModelMedia>.from(
              json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "is_favourite": isFavourite,
        "is_favourite_id": isFavouriteId,
        "categories": categories.map((x) => x.toJson()).toList(),
        "service_rate": serviceRate,
        "required_servicemen": requiredServicemen,
        "selectedRequiredServiceMan": selectedRequiredServiceMan,
        "price": price,
        "media": media.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$id, $title, $isFavourite, $categories, $serviceRate, $requiredServicemen, $price, $media, ";
  }
}

class Tax {
  final int? id;
  final String? name;
  final double? rate;
  final dynamic amount;

  Tax({this.id, this.name, this.rate, this.amount});

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        rate: (json['rate'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rate': rate,
        'amount': amount,
      };
}

class Category {
  Category({
    required this.title,
  });

  final String? title;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
      };

  @override
  String toString() {
    return "$title, ";
  }
}

class User {
  User({
    required this.id,
    required this.name,
    required this.reviewRatings,
    required this.media,
    required this.experienceInterval,
    required this.experienceDuration,
    required this.served,
    required this.fcmToken,
  });

  final dynamic id;
  final String? name;
  final dynamic reviewRatings;
  final List<ServiceDetailsModelMedia> media;
  final String? experienceInterval;
  final dynamic experienceDuration;
  final dynamic served;
  final dynamic fcmToken;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      reviewRatings: json["review_ratings"],
      media: json["media"] == null
          ? []
          : List<ServiceDetailsModelMedia>.from(
              json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
      experienceInterval: json["experience_interval"],
      experienceDuration: json["experience_duration"],
      served: json["served"],
      fcmToken: json["fcm_token"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "review_ratings": reviewRatings,
        "media": media.map((x) => x.toJson()).toList(),
        "experience_interval": experienceInterval,
        "experience_duration": experienceDuration,
        "served": served,
        "fcm_token": fcmToken,
      };

  @override
  String toString() {
    return "$id, $name, $reviewRatings, $media, $experienceInterval, $experienceDuration, $served,$fcmToken ";
  }
}

/*
class ServiceDetailsModel {
  ServiceDetailsModel({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.duration,
    required this.description,
    required this.durationUnit,
    required this.discount,
    required this.parentId,
    required this.type,
    required this.video,
    required this.isFeatured,
    required this.isAdvertised,
    required this.isRandomRelatedServices,
    required this.serviceRate,
    required this.requiredServicemen,
    required this.serviceType,
    required this.media,
    required this.user,
    required this.relatedServices,
  });

  final dynamic id;
  final String? title;
  final dynamic price;
  final dynamic status;
  final String? duration;
  final String? description;
  final String? durationUnit;
  final String? video;
  final dynamic discount;
  final dynamic parentId;
  final String? type;
  final dynamic isFeatured;
  final dynamic isAdvertised;
  final dynamic isRandomRelatedServices;
  final dynamic serviceRate;
  final dynamic requiredServicemen;
  final dynamic serviceType;
  final List<ServiceDetailsModelMedia> media;
  final User? user;
  final List<RelatedService> relatedServices;

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json){
    return ServiceDetailsModel(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      status: json["status"],
      duration: json["duration"],
      description: json["description"],
      video: json["video"],
      durationUnit: json["duration_unit"],
      discount: json["discount"],
      parentId: json["parent_id"],
      type: json["type"],
      isFeatured: json["is_featured"],
      isAdvertised: json["is_advertised"],
      isRandomRelatedServices: json["is_random_related_services"],
      serviceRate: json["service_rate"],
      requiredServicemen: json["required_servicemen"],
      serviceType: json["service_type"],
      media: json["media"] == null ? [] : List<ServiceDetailsModelMedia>.from(json["media"]!.map((x) => ServiceDetailsModelMedia.fromJson(x))),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      relatedServices: json["related_services"] == null ? [] : List<RelatedService>.from(json["related_services"]!.map((x) => RelatedService.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "status": status,
    "duration": duration,
    "description": description,
    "duration_unit": durationUnit,
    "discount": discount,
    "parent_id": parentId,
    "type": type,
    "video": video,
    "is_featured": isFeatured,
    "is_advertised": isAdvertised,
    "is_random_related_services": isRandomRelatedServices,
    "service_rate": serviceRate,
    "required_servicemen": requiredServicemen,
    "service_type": serviceType,
    "media": media.map((x) => x.toJson()).toList(),
    "user": user?.toJson(),
    "related_services": relatedServices.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $title, $price, $status, $duration, $description, $durationUnit, $discount, $parentId, $type, $isFeatured, $isAdvertised, $isRandomRelatedServices, $serviceRate, $requiredServicemen, $serviceType, $media, $user, $relatedServices, ";
  }
}

class ServiceDetailsModelMedia {
  ServiceDetailsModelMedia({
    required this.id,
    required this.collectionName,
    required this.originalUrl,
  });

  final dynamic id;
  final String? collectionName;
  final String? originalUrl;

  factory ServiceDetailsModelMedia.fromJson(Map<String, dynamic> json){
    return ServiceDetailsModelMedia(
      id: json["id"],
      collectionName: json["collection_name"],
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "collection_name": collectionName,
    "original_url": originalUrl,
  };

  @override
  String toString(){
    return "$id, $collectionName, $originalUrl, ";
  }
}

class RelatedService {
  RelatedService({
    required this.id,
    required this.title,
    required this.categories,
    required this.serviceRate,
    required this.price,
    required this.media,
  });

  final dynamic id;
  final String? title;
  final List<Category> categories;
  final double? serviceRate;
  final dynamic price;
  final List<RelatedServiceMedia> media;

  factory RelatedService.fromJson(Map<String, dynamic> json){
    return RelatedService(
      id: json["id"],
      title: json["title"],
      categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
      serviceRate: json["service_rate"] is int
          ? (json["service_rate"] as int).toDouble()
          : json["service_rate"] is double
          ? json["service_rate"]
          : null,
      price: json["price"],
      media: json["media"] == null ? [] : List<RelatedServiceMedia>.from(json["media"]!.map((x) => RelatedServiceMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "categories": categories.map((x) => x.toJson()).toList(),
    "service_rate": serviceRate,
    "price": price,
    "media": media.map((x) => x.toJson()).toList(),
  };

  @override
  String toString(){
    return "$id, $title, $categories, $serviceRate, $price, $media, ";
  }
}

class Category {
  Category({
    required this.title,
  });

  final String? title;

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
  };

  @override
  String toString(){
    return "$title, ";
  }
}

class RelatedServiceMedia {
  RelatedServiceMedia({
    required this.originalUrl,
  });

  final String? originalUrl;

  factory RelatedServiceMedia.fromJson(Map<String, dynamic> json){
    return RelatedServiceMedia(
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "original_url": originalUrl,
  };

  @override
  String toString(){
    return "$originalUrl, ";
  }
}

class User {
  User({
    required this.id,
    required this.name,
    required this.reviewRatings,
    required this.media,
    required this.experienceInterval,
    required this.experienceDuration,
    required this.served,
  });

  final dynamic id;
  final String? name;
  final dynamic reviewRatings;
  final List<RelatedServiceMedia> media;
  final String? experienceInterval;
  final dynamic experienceDuration;
  final dynamic served;

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json["id"],
      name: json["name"],
      reviewRatings: json["review_ratings"],
      media: json["media"] == null ? [] : List<RelatedServiceMedia>.from(json["media"]!.map((x) => RelatedServiceMedia.fromJson(x))),
      experienceInterval: json["experience_interval"],
      experienceDuration: json["experience_duration"],
      served: json["served"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "review_ratings": reviewRatings,
    "media": media.map((x) => x.toJson()).toList(),
    "experience_interval": experienceInterval,
    "experience_duration": experienceDuration,
    "served": served,
  };

  @override
  String toString(){
    return "$id, $name, $reviewRatings, $media, $experienceInterval, $experienceDuration, $served, ";
  }
}
*/
