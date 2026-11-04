class GetAddressModel {
  String? id;
  String? type;
  String? address;
  String? mobile;
  String? lattitude;
  String? longitude;
  String? isDefault;

  /// Localized country/region names (backend follows `Content-Language`).
  /// Ids are absent on legacy addresses, whose `country` keeps the old text.
  String? countryId;
  String? country;
  String? regionId;
  String? region;

  /// "Region, Country" for display; skips whatever is empty (legacy addresses
  /// may only carry country text).
  String get regionAndCountry => [
    region,
    country,
  ].where((final part) => (part ?? '').trim().isNotEmpty).join(', ');

  /// Map of custom field id -> raw value (String) as saved on the server.
  Map<String, dynamic>? customFieldValues;

  GetAddressModel({
    this.id,
    this.type,
    this.address,
    this.mobile,
    this.lattitude,
    this.longitude,
    this.isDefault,
    this.countryId,
    this.country,
    this.regionId,
    this.region,
    this.customFieldValues,
  });

  GetAddressModel.fromJson(final Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '0';
    type = json['type']?.toString() ?? '';
    address = json['address']?.toString() ?? '';
    mobile = json['mobile']?.toString() ?? '';
    lattitude = json['lattitude']?.toString() ?? '';
    longitude = json['longitude']?.toString() ?? '';
    isDefault = json['is_default']?.toString() ?? '';
    countryId = json['country_id']?.toString() ?? '';
    country = json['country']?.toString() ?? '';
    regionId = json['region_id']?.toString() ?? '';
    region = json['region']?.toString() ?? '';
    final rawCustomFields = json['custom_fields'];
    if (rawCustomFields is Map) {
      customFieldValues = Map<String, dynamic>.from(rawCustomFields);
    }
  }

  GetAddressModel copyWith({
    String? id,
    String? type,
    String? address,
    String? mobile,
    String? lattitude,
    String? longitude,
    String? isDefault,
    String? countryId,
    String? country,
    String? regionId,
    String? region,
    Map<String, dynamic>? customFieldValues,
  }) {
    return GetAddressModel(
      id: id ?? this.id,
      type: type ?? this.type,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      lattitude: lattitude ?? this.lattitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      countryId: countryId ?? this.countryId,
      country: country ?? this.country,
      regionId: regionId ?? this.regionId,
      region: region ?? this.region,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }
}
