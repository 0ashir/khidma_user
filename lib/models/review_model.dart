
class Reviews {
  Reviews({
    required this.id,
    required this.rating,
    required this.description,
    required this.createdAt,
    required this.consumer,
    required this.serviceman,
    required this.provider,
    required this.service,
  });

  final int? id;
  final int? rating;
  final String? description;
  final DateTime? createdAt;
  final ReviewConsumer? consumer;
  final ReviewConsumer? serviceman;
  final ReviewConsumer? provider;
  final ReviewService? service;

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      id: json["id"],
      rating: json["rating"],
      description: json["description"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      consumer: json["consumer"] == null
          ? null
          : ReviewConsumer.fromJson(json["consumer"]),
      serviceman: json["serviceman"] == null
          ? null
          : ReviewConsumer.fromJson(json["serviceman"]),
      provider: json["provider"] == null
          ? null
          : ReviewConsumer.fromJson(json["provider"]),
      service: json["service"] == null
          ? null
          : ReviewService.fromJson(json["service"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "consumer": consumer?.toJson(),
        "serviceman": serviceman?.toJson(),
        "provider": provider?.toJson(),
        "service": service?.toJson(),
      };

  @override
  String toString() {
    return "$id, $rating, $description, $createdAt, $consumer, $serviceman, $provider, $service";
  }
}

class ReviewConsumer {
  ReviewConsumer({
    required this.id,
    required this.name,
    required this.media,
  });

  final int? id;
  final String? name;
  final List<ReviewMedia> media;

  factory ReviewConsumer.fromJson(Map<String, dynamic> json) {
    return ReviewConsumer(
      id: json["id"],
      name: json["name"],
      media: json["media"] == null
          ? []
          : List<ReviewMedia>.from(
              json["media"]!.map((x) => ReviewMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "media": media.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$id, $name, $media";
  }
}

class ReviewMedia {
  ReviewMedia({
    required this.originalUrl,
  });

  final String? originalUrl;

  factory ReviewMedia.fromJson(Map<String, dynamic> json) {
    return ReviewMedia(
      originalUrl: json["original_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "original_url": originalUrl,
      };

  @override
  String toString() {
    return "$originalUrl";
  }
}

class ReviewService {
  ReviewService({
    required this.id,
    required this.title,
    required this.media,
  });

  final int? id;
  final String? title;
  final List<ReviewMedia> media;

  factory ReviewService.fromJson(Map<String, dynamic> json) {
    return ReviewService(
      id: json["id"],
      title: json["title"],
      media: json["media"] == null
          ? []
          : List<ReviewMedia>.from(
              json["media"]!.map((x) => ReviewMedia.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "media": media.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$id, $title, $media";
  }
}

/*
import 'package:fixit_user/config.dart';

class Reviews {
  int? id;
  int? serviceId;
  int? consumerId;
  int? providerId;
  int? servicemanId;
  dynamic rating;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  List<Media>? media;
  // UserModel? consumer;
  Services? service;
  ServicemanModel? serviceman;
  ProviderModel? provider;

  Reviews(
      {this.id,
        this.serviceId,
        this.consumerId,
        this.providerId,
        this.servicemanId,
        this.rating,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.media,
        // this.consumer,
        this.service,
        this.serviceman,
      this.provider});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    consumerId = json['consumer_id'];
    providerId = json['provider_id'];
    servicemanId = json['serviceman_id'];
    rating = json['rating'] != null ? int.parse(json['rating'].toString()):null;
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add( Media.fromJson(v));
      });
    }
    // consumer = json['consumer'] != null
    //     ? UserModel.fromJson(json['consumer'])
    //     : null;
    service = json['service'] != null
        ? Services.fromJson(json['service'])
        : null;
    serviceman = json['serviceman'] != null
        ? ServicemanModel.fromJson(json['serviceman'])
        : null;
    provider = json['provider'] != null
        ? ProviderModel.fromJson(json['provider'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_id'] = serviceId;
    data['consumer_id'] = consumerId;
    data['provider_id'] = providerId;
    data['serviceman_id'] = servicemanId;
    data['rating'] = rating;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    // if (consumer != null) {
    //   data['consumer'] = consumer!.toJson();
    // }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (serviceman != null) {
      data['serviceman'] = serviceman!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    return data;
  }
}


*/
