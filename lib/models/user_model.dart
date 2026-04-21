

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.systemReserve,
    required this.served,
    required this.phone,
    required this.code,
    required this.providerId,
    required this.status,
    required this.isFeatured,
    required this.isVerified,
    required this.type,
    required this.experienceInterval,
    required this.experienceDuration,
    required this.companyId,
    this.referralCode,
    required this.fcmToken,
    required this.role,
    required this.locationCordinates,
    required this.media,
    required this.wallet,
  });

  final int id;
  final String name;
  final String email;
  final int systemReserve;
  final dynamic served;
  final dynamic phone;
  final dynamic code;
  final dynamic providerId;
  final int status;
  final int isFeatured;
  final int isVerified;
  final dynamic type;
  final dynamic experienceInterval;
  final dynamic experienceDuration;
  final dynamic companyId;
  final String? referralCode;
  final String fcmToken;
  final String role;
  final LocationCordinates? locationCordinates;
  final List<UserMedia> media;
  final Wallet? wallet;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      role: json["role"] ?? "",
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      systemReserve: json["system_reserve"] ?? 0,
      served: json["served"],
      phone: json["phone"],
      code: json["code"],
      providerId: json["provider_id"],
      referralCode: json['referral_code'] ?? "",
      status: json["status"] ?? 0,
      isFeatured: json["is_featured"] ?? 0,
      isVerified: json["is_verified"] ?? 0,
      type: json["type"],
      experienceInterval: json["experience_interval"],
      experienceDuration: json["experience_duration"],
      companyId: json["company_id"],
      fcmToken: json["fcm_token"] ?? "",
      locationCordinates: json["location_cordinates"] == null
          ? null
          : LocationCordinates.fromJson(json["location_cordinates"]),
      media: json["media"] == null
          ? []
          : List<UserMedia>.from(
              json["media"]!.map((x) => UserMedia.fromJson(x))),
      wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "system_reserve": systemReserve,
        "referral_code": referralCode,
        "served": served is num || served is String || served == null
            ? served
            : served.toString(), // Safeguard for dynamic
        "phone": phone is String || phone == null ? phone : phone.toString(),
        "code": code is String || code == null ? code : code.toString(),
        "provider_id": providerId is num || providerId == null
            ? providerId
            : providerId.toString(),
        "status": status,
        "role": role,
        "is_featured": isFeatured,
        "is_verified": isVerified,
        "type": type is String || type == null ? type : type.toString(),
        "experience_interval":
            experienceInterval is String || experienceInterval == null
                ? experienceInterval
                : experienceInterval.toString(),
        "experience_duration":
            experienceDuration is String || experienceDuration == null
                ? experienceDuration
                : experienceDuration.toString(),
        "company_id": companyId is num || companyId == null
            ? companyId
            : companyId.toString(),
        "fcm_token": fcmToken,
        "location_cordinates": locationCordinates?.toJson(),
        "media": media.map((x) => x.toJson()).toList(),
        "wallet": wallet?.toJson(),
      };

  @override
  String toString() {
    return "$id, $name, $email, $systemReserve, $served, $phone, $code, $providerId, $status, $isFeatured, $isVerified, $type, $experienceInterval, $experienceDuration, $companyId, $fcmToken, $locationCordinates, $media, $wallet";
  }
}

// Placeholder for LocationCordinates (replace with actual definition)
class LocationCordinates {
  final double latitude;
  final double longitude;

  LocationCordinates({
    required this.latitude,
    required this.longitude,
  });

  factory LocationCordinates.fromJson(Map<String, dynamic> json) {
    return LocationCordinates(
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

// Placeholder for Wallet (replace with actual definition)
class Wallet {
  final double balance;
  final String currency;

  Wallet({
    required this.balance,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: (json["balance"] as num?)?.toDouble() ?? 0.0,
      currency: json["currency"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "currency": currency,
      };
}

// Placeholder for Media (replace with actual definition)
class UserMedia {
  final int id;
  final String originalUrl;

  UserMedia({
    required this.id,
    required this.originalUrl,
  });

  factory UserMedia.fromJson(Map<String, dynamic> json) {
    return UserMedia(
      id: json["id"] ?? 0,
      originalUrl: json["original_url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "original_url": originalUrl,
      };
}

/*


import '../config.dart';

class UserModel {
  int? id;
  String? name;
  String? email;
  String? served;
  String? phone;
  String? code;
  int? providerId;
  int? status;
  int? isFeatured;
  int? isVerified;
  String? type;
  String? emailVerifiedAt;
  String? fcmToken;
  String? experienceInterval;
  String? experienceDuration;
  String? description;
  int? createdBy;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? companyId;
  Role? role;
  PrimaryAddress? primaryAddress;
  List<Media>? media;
  WalletModel? wallet;
  List<KnownLanguageModel>? knownLanguages;
  List<ExpertiseModel>? expertise;

  String? companyName;
  String? companyEmail;
  String? companyPhone;
  String? companyCode;

  UserModel(
      {this.id,
        this.name,
        this.email,
        this.served,
        this.phone,
        this.code,
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
        this.role,
        this.primaryAddress,
        this.media,
        this.wallet,
        this.knownLanguages,
        this.expertise,this.companyCode,this.companyEmail,this.companyName,this.companyPhone});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];

    served = json['served']?.toString();
    phone = json['phone']?.toString();
    code = json['code']?.toString();
    providerId = json['provider_id'];
    status = json['status'];
    isFeatured = json['is_featured'];
    isVerified = json['is_verified'];
    type = json['type'];
    emailVerifiedAt = json['email_verified_at'];
    fcmToken = json['fcm_token'];
    experienceInterval = json['experience_interval'];
    experienceDuration = json['experience_duration'];
    companyName = json['company_name'];
    companyEmail = json['company_email'];
    companyPhone = json['company_phone'];
    companyCode = json['company_code'];
    description = json['description'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    companyId = json['company_id'];
    role = json['role'] != null ? Role.fromJson(json['role']) : null;

    primaryAddress = json['primary_address'] != null
        ? PrimaryAddress.fromJson(json['primary_address'])
        : null;

    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }

    wallet =  json['wallet'] != null ? WalletModel.fromJson(json['wallet']):null;

    if (json['known_languages'] != null) {
      knownLanguages = <KnownLanguageModel>[];
      json['known_languages'].forEach((v) {
        knownLanguages!.add(KnownLanguageModel.fromJson(v));
      });
    }
    if (json['expertise'] != null) {
      expertise = <ExpertiseModel>[];
      json['expertise'].forEach((v) {
        expertise!.add(ExpertiseModel.fromJson(v));
      });
    }



  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['served'] = served;
    data['phone'] = phone;
    data['code'] = code;
    data['provider_id'] = providerId;
    data['status'] = status;
    data['is_featured'] = isFeatured;
    data['is_verified'] = isVerified;
    data['type'] = type;
    data['email_verified_at'] = emailVerifiedAt;
    data['fcm_token'] = fcmToken;
    data['experience_interval'] = experienceInterval;
    data['experience_duration'] = experienceDuration;
    data['company_name'] = companyName;
    data['company_email'] = companyEmail;
    data['company_phone'] = companyPhone;
    data['company_code'] = companyCode;
    data['description'] = description;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['company_id'] = companyId;
    if (role != null) {
      data['role'] = role!.toJson();
    }

    if (primaryAddress != null) {
      data['primary_address'] = primaryAddress!.toJson();
    }

    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    data['wallet'] = wallet;

    if (knownLanguages != null) {
      data['known_languages'] =
          knownLanguages!.map((v) => v.toJson()).toList();
    }
    if (expertise != null) {
      data['expertise'] = expertise!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}


class Role {
  int? id;
  String? name;
  String? guardName;

  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Role(
      {this.id,
        this.name,
        this.guardName,

        this.createdAt,
        this.updatedAt,
        this.pivot});

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    guardName = json['guard_name'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['guard_name'] = guardName;

    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}*/
