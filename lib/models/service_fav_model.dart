class ServiceFavModel {
  ServiceFavModel({
    required this.data,
    required this.success,
  });

  final List<Datum> data;
  final bool? success;

  factory ServiceFavModel.fromJson(Map<String, dynamic> json){
    return ServiceFavModel(
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      success: json["success"],
    );
  }

  @override
  String toString(){
    return "$data, $success, ";
  }
}

class DatumSer {
  DatumSer({
    required this.id,
    required this.service,
  });

  final int? id;
  final Service? service;

  factory DatumSer.fromJson(Map<String, dynamic> json){
    return DatumSer(
      id: json["id"],
      service: json["service"] == null ? null : Service.fromJson(json["service"]),
    );
  }

  @override
  String toString(){
    return "$id, $service, ";
  }
}

class Service {
  Service({
    required this.title,
    required this.price,
    required this.isFavourite,
    required this.categories,
    required this.media,
  });

  final String? title;
  final num? price;
  final num? isFavourite;
  final List<Category> categories;
  final List<Media> media;

  factory Service.fromJson(Map<String, dynamic> json){
    return Service(
      title: json["title"],
      price: json["price"],
      isFavourite: json["is_favourite"],
      categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
      media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    );
  }

  @override
  String toString(){
    return "$title, $price, $isFavourite, $categories, $media, ";
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

  @override
  String toString(){
    return "$title, ";
  }
}

class Media {
  Media({
    required this.originalUrl,
  });

  final String? originalUrl;

  factory Media.fromJson(Map<String, dynamic> json){
    return Media(
      originalUrl: json["original_url"],
    );
  }

  @override
  String toString(){
    return "$originalUrl, ";
  }
}



class ProviderFavModel {
  ProviderFavModel({
    required this.data,
    required this.success,
  });

  final List<Datum> data;
  final bool? success;

  factory ProviderFavModel.fromJson(Map<String, dynamic> json){
    return ProviderFavModel(
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      success: json["success"],
    );
  }

  @override
  String toString(){
    return "$data, $success, ";
  }
}

class Datum {
  Datum({
    required this.id,
    required this.provider,
  });

  final int? id;
  final ProviderFav? provider;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      id: json["id"],
      provider: json["provider"] == null ? null : ProviderFav.fromJson(json["provider"]),
    );
  }

  @override
  String toString(){
    return "$id, $provider, ";
  }
}

class ProviderFav {
  ProviderFav({
    required this.name,
    required this.reviewRatings,
    required this.media,
  });

  final String? name;
  final num? reviewRatings;
  final List<Media> media;

  factory ProviderFav.fromJson(Map<String, dynamic> json){
    return ProviderFav(
      name: json["name"],
      reviewRatings: json["review_ratings"],
      media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    );
  }

  @override
  String toString(){
    return "$name, $reviewRatings, $media, ";
  }
}
