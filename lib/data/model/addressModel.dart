import 'dart:convert';

class AddressModel {
  String? addressId = '';
  String? mobile = '';
  String? address = '';
  String? latitude = '';
  String? longitude = '';
  String? type = '';
  String? isDefault = '';

  /// Optional active country/region ids. When [countryId] is sent without
  /// [regionId] the backend clears the address's stored region.
  String? countryId = '';
  String? regionId = '';

  /// List of custom field values for API submission:
  /// [{"custom_field_id": int, "value": dynamic}]
  /// Values can be String (text/number/textarea) or
  /// a file path string (for file-type fields submitted via multipart).
  List<Map<String, dynamic>>? customFieldValues;

  AddressModel({
    this.addressId,
    this.mobile,
    this.address,
    this.latitude,
    this.longitude,
    this.type,
    this.isDefault,
    this.countryId,
    this.regionId,
    this.customFieldValues,
  });

  AddressModel copyWith({
    final String? addressId,
    final String? mobile,
    final String? address,
    final String? latitude,
    final String? longitude,
    final String? type,
    final String? isDefault,
    final String? countryId,
    final String? regionId,
    final List<Map<String, dynamic>>? customFieldValues,
  }) => AddressModel(
    addressId: addressId ?? this.addressId ?? '',
    mobile: mobile ?? this.mobile ?? '',
    address: address ?? this.address ?? '',
    latitude: latitude ?? this.latitude ?? '',
    longitude: longitude ?? this.longitude ?? '',
    type: type ?? this.type ?? '',
    isDefault: isDefault ?? this.isDefault ?? '',
    countryId: countryId ?? this.countryId ?? '',
    regionId: regionId ?? this.regionId ?? '',
    customFieldValues: customFieldValues ?? this.customFieldValues,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      "address_id": addressId,
      "mobile": mobile,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "type": type,
      "is_default": isDefault,
      if (countryId != null && countryId!.isNotEmpty) "country_id": countryId,
      if (regionId != null && regionId!.isNotEmpty) "region_id": regionId,
    };
    // Merge custom field values using array bracket notation
    if (customFieldValues != null) {
      for (int i = 0; i < customFieldValues!.length; i++) {
        final item = customFieldValues![i];
        map['custom_fields[$i][custom_field_id]'] = item['custom_field_id'];
        map['custom_fields[$i][value]'] = item['value'];
      }
    }
    return map;
  }

  factory AddressModel.fromMap(final Map<String, dynamic> map) => AddressModel(
    addressId: map["address_id"]?.toString() ?? '',
    mobile: map["mobile"]?.toString() ?? '',
    address: map["address"]?.toString() ?? '',
    latitude: map["latitude"]?.toString() ?? '',
    longitude: map["longitude"]?.toString() ?? '',
    type: map["type"]?.toString() ?? '',
    isDefault: map["is_default"]?.toString() ?? '',
    countryId: map["country_id"]?.toString() ?? '',
    regionId: map["region_id"]?.toString() ?? '',
  );

  String toJson() => json.encode(toMap());

  factory AddressModel.fromJson(final String source) =>
      AddressModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
