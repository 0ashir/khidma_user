import 'dart:convert';

class UserDetailsModel {
  String? id;
  String? username;
  String? phone;
  String? countryCode;
  String? countryCodeName;
  String? userLoginType;
  String? email;
  String? fcmId;
  String? image;
  String? latitude;
  String? longitude;
  String? cityId;

  UserDetailsModel({
    this.id,
    this.username,
    this.phone,
    this.countryCode,
    this.email,
    this.fcmId,
    this.image,
    this.latitude,
    this.longitude,
    this.cityId,
    this.userLoginType,
    this.countryCodeName,
  });

  UserDetailsModel copyWith({
    final String? id,
    final String? username,
    final String? phone,
    final String? countryCode,
    final String? email,
    final String? fcmId,
    final String? image,
    final String? latitude,
    final String? longitude,
    final String? cityId,
    final String? userLoginType,
    final String? countryCodeName,
  }) =>
      UserDetailsModel(
        id: id ?? this.id,
        username: username ?? this.username,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        fcmId: fcmId ?? this.fcmId,
        image: image ?? this.image,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        cityId: cityId ?? this.cityId,
        userLoginType: userLoginType ?? this.userLoginType,
        countryCode: countryCode ?? this.countryCode,
        countryCodeName: countryCodeName ?? this.countryCodeName,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        "id": id,
        "username": username,
        "phone": phone,
        "email": email,
        "fcm_id": fcmId,
        "image": image,
        "latitude": latitude,
        "longitude": longitude,
        "city_id": cityId,
        "country_code": countryCode,
        "loginType": userLoginType,
        "countryCodeName": countryCodeName,
      };

  factory UserDetailsModel.fromMap(final Map<String, dynamic> map) =>
      UserDetailsModel(
        id: map["id"] != null ? map["id"].toString() : null,
        username: map["username"] != null ? map["username"].toString() : null,
        phone: map["phone"] != null ? map["phone"].toString() : null,
        countryCode:
            map["country_code"] != null ? map["country_code"].toString() : null,
        email: map["email"] != null ? map["email"].toString() : null,
        fcmId: map["fcm_id"] != null ? map["fcm_id"].toString() : null,
        image: map["image"] != null ? map["image"].toString() : null,
        latitude: map["latitude"] != null ? map['latitude'].toString() : null,
        longitude:
            map["longitude"] != null ? map['longitude'].toString() : null,
        cityId: map["city_id"] != null ? map["city_id"].toString() : null,
        userLoginType:
            map["loginType"] != null ? map["loginType"].toString() : null,
        countryCodeName: map["countryCodeName"] != null
            ? map["countryCodeName"].toString()
            : null,
      );

  UserDetailsModel fromMapCopyWith(final Map<String, dynamic> map) =>
      UserDetailsModel(
        id: map["id"] != null ? map["id"].toString() : id,
        username:
            map["username"] != null ? map["username"].toString() : username,
        phone: map["phone"] != null ? map["phone"].toString() : phone,
        countryCode: map["country_code"] != null
            ? map["country_code"].toString()
            : countryCode,
        email: map["email"] != null ? map["email"].toString() : email,
        fcmId: map["fcm_id"] != null ? map["fcm_id"].toString() : fcmId,
        image: map["image"] != null ? map["image"].toString() : image,
        latitude:
            map["latitude"] != null ? map["latitude"].toString() : latitude,
        longitude:
            map["longitude"] != null ? map["longitude"].toString() : longitude,
        cityId: map["city_id"] != null ? map["city_id"].toString() : cityId,
        countryCodeName: map["countryCodeName"] != null
            ? map["countryCodeName"].toString()
            : countryCodeName,
        userLoginType: map["loginType"] != null
            ? map["loginType"].toString()
            : userLoginType,
      );

  String toJson() => json.encode(toMap());

  factory UserDetailsModel.fromJson(final String source) =>
      UserDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      "UserDetailsModel(id: $id, username: $username, phone: $phone, email: $email, fcm_id: $fcmId, image: $image, latitude: $latitude, longitude: $longitude, city_id: $cityId)";

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is UserDetailsModel &&
        other.id == id &&
        other.username == username &&
        other.phone == phone &&
        other.email == email &&
        other.fcmId == fcmId &&
        other.image == image &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.cityId == cityId;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      fcmId.hashCode ^
      image.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      cityId.hashCode;
}
