// ignore_for_file: file_names

import 'dart:convert';

/// Supported custom field types from the backend.
enum CustomFieldType { text, number, textarea, file }

CustomFieldType _parseType(String? raw) {
  switch (raw) {
    case 'number':
      return CustomFieldType.number;
    case 'textarea':
      return CustomFieldType.textarea;
    case 'file':
      return CustomFieldType.file;
    default:
      return CustomFieldType.text;
  }
}

class CustomFieldModel {
  final int id;

  /// Label already translated by the backend.
  final String name;
  final CustomFieldType type;
  final bool isRequired;
  final bool visible;
  final int sortOrder;

  /// Only relevant when [type] == [CustomFieldType.file].
  /// Parsed from the [file_config] object, e.g. ["jpg", "jpeg", "png", "pdf"]
  final List<String> allowedExtensions;

  /// Address-form role from `file_config.address_role` (customer_address
  /// fields only), e.g. building, apartment, floor, company, street, area,
  /// city, directions. Null for fields without a role.
  final String? addressRole;

  /// Address types the field is shown for (`file_config.address_types`),
  /// e.g. ["apartment", "office"]. Empty = every type.
  final List<String> addressTypes;

  /// Whether the field is shown for [type] ("apartment" / "villa" / "office").
  bool appliesTo(final String type) =>
      addressTypes.isEmpty || addressTypes.contains(type);

  const CustomFieldModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    this.visible = true,
    this.sortOrder = 0,
    this.allowedExtensions = const [],
    this.addressRole,
    this.addressTypes = const [],
  });

  factory CustomFieldModel.fromJson(final Map<String, dynamic> json) {
    // Parse allowed extensions from file_config if present
    List<String> extensions = [];
    String? addressRole;
    List<String> addressTypes = const [];
    final fileConfig = json['file_config'];
    if (fileConfig is Map) {
      final role = fileConfig['address_role']?.toString().trim() ?? '';
      if (role.isNotEmpty) addressRole = role;
      final types = fileConfig['address_types'];
      if (types is List) {
        addressTypes = types.map((e) => e.toString()).toList();
      }
      final raw = fileConfig['allowed_extensions'];
      if (raw is List) {
        extensions = raw.map((e) => e.toString()).toList();
      } else if (raw is String && raw.isNotEmpty) {
        extensions = raw.split(',').map((e) => e.trim()).toList();
      }
    }

    return CustomFieldModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['label']?.toString() ?? '',
      type: _parseType(
        json['field_type']?.toString() ?? json['type']?.toString(),
      ),
      // backend sends 0/1 or true/false
      isRequired:
          json['required'] == true || json['required']?.toString() == '1',
      visible: json['visible'] == true || json['visible']?.toString() == '1',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      allowedExtensions: extensions,
      addressRole: addressRole,
      addressTypes: addressTypes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'is_required': isRequired,
    'visible': visible,
    'sort_order': sortOrder,
    'allowed_extensions': allowedExtensions,
    'address_role': addressRole,
    'address_types': addressTypes,
  };

  @override
  String toString() => jsonEncode(toJson());
}

/// Response wrapper returned by [AddressRepository.fetchCustomFields].
class CustomFieldsResponse {
  const CustomFieldsResponse({required this.fields, required this.savedValues});

  /// Field definitions from [custom_fields].
  final List<CustomFieldModel> fields;

  /// Pre-filled values from [customer_address_custom_fields].
  /// Map of id string → value string.
  final Map<String, dynamic> savedValues;
}
