import 'dashboard_user_model_2.dart';

class DashboardModel {
  List<Banners>? banners;
  List<Coupons>? coupons;
  List<Categories>? categories;
  List<ServicePackages>? servicePackages;
  List<FeaturedServices>? featuredServices;

  DashboardModel(
      {this.banners,
      this.coupons,
      this.categories,
      this.servicePackages,
      this.featuredServices});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    if (json['banners'] != null) {
      banners = <Banners>[];
      json['banners'].forEach((v) {
        banners!.add(Banners.fromJson(v));
      });
    }
    if (json['coupons'] != null) {
      coupons = <Coupons>[];
      json['coupons'].forEach((v) {
        coupons!.add(Coupons.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['servicePackages'] != null) {
      servicePackages = <ServicePackages>[];
      json['servicePackages'].forEach((v) {
        servicePackages!.add(ServicePackages.fromJson(v));
      });
    }
    if (json['featuredServices'] != null) {
      featuredServices = <FeaturedServices>[];
      json['featuredServices'].forEach((v) {
        featuredServices!.add(FeaturedServices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (banners != null) {
      data['banners'] = banners!.map((v) => v.toJson()).toList();
    }
    if (coupons != null) {
      data['coupons'] = coupons!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (servicePackages != null) {
      data['servicePackages'] =
          servicePackages!.map((v) => v.toJson()).toList();
    }
    if (featuredServices != null) {
      data['featuredServices'] =
          featuredServices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banners {
  int? id;
  String? type;
  int? relatedId;
  String? title;
  List<Media>? media;

  Banners({this.id, this.type, this.relatedId, this.title, this.media});

  Banners.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    relatedId = json['related_id'];
    title = json['title'];
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
    data['type'] = type;
    data['related_id'] = relatedId;
    data['title'] = title;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original_url'] = originalUrl;
    return data;
  }
}

class Coupons {
  int? id;
  String? code;
  String? title;
  String? minSpend;
  String? type;
  int? amount;

  Coupons(
      {this.id, this.code, this.title, this.minSpend, this.type, this.amount});

  Coupons.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    title = json['title'];
    minSpend = json['min_spend'];
    type = json['type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['title'] = title;
    data['min_spend'] = minSpend;
    data['type'] = type;
    data['amount'] = amount;
    return data;
  }
}

class Categories {
  int? id;
  String? title;
  dynamic parentId;
  List<Media>? media;
  List<HasSubCategories>? hasSubCategories;

  Categories(
      {this.id, this.title, this.parentId, this.media, this.hasSubCategories});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    parentId = json['parent_id'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    if (json['hasSubCategories'] != null) {
      hasSubCategories = <HasSubCategories>[];
      json['hasSubCategories'].forEach((v) {
        hasSubCategories!.add(HasSubCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['parent_id'] = parentId;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    if (hasSubCategories != null) {
      data['hasSubCategories'] =
          hasSubCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HasSubCategories {
  int? id;
  String? title;
  int? parentId;
  List<Media>? media;

  HasSubCategories({this.id, this.title, this.parentId, this.media});

  HasSubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    parentId = json['parent_id'];
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
    data['title'] = title;
    data['parent_id'] = parentId;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServicePackages {
  int? id;
  String? hexaCode;
  String? title;
  int? price;
  String? description;
  List<Media>? media;

  ServicePackages(
      {this.id,
      this.hexaCode,
      this.title,
      this.price,
      this.description,
      this.media});

  ServicePackages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hexaCode = json['hexa_code'];
    title = json['title'];
    price = json['price'];
    description = json['description'];
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
    data['hexa_code'] = hexaCode;
    data['title'] = title;
    data['price'] = price;
    data['description'] = description;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
