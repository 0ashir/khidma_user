import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Address types of the pin-first (talabat-style) address form.
class AddressKind {
  static const String apartment = 'apartment';
  static const String villa = 'villa';
  static const String office = 'office';

  /// Value stored in `addresses.type`.
  static String toApiType(final String kind) => switch (kind) {
    villa => 'Villa',
    office => 'Office',
    _ => 'Apartment',
  };

  /// Kind for a saved `addresses.type` (legacy "Home"/"Other" open as
  /// Apartment, the most common UAE case).
  static String fromApiType(final String? type) =>
      switch ((type ?? '').toLowerCase()) {
        'villa' => villa,
        'office' => office,
        _ => apartment,
      };
}

/// Field roles set in `custom_fields.file_config.address_role`.
class AddressRole {
  static const String building = 'building';
  static const String apartment = 'apartment';
  static const String floor = 'floor';
  static const String company = 'company';
  static const String street = 'street';
  static const String area = 'area';
  static const String city = 'city';
  static const String directions = 'directions';
}

/// Translation with an English fallback for keys the language files may not
/// have yet.
String trOr(
  final BuildContext context,
  final String key,
  final String fallback,
) {
  final String value = key.translate(context: context);
  return value == key ? fallback : value;
}

/// Pin-first address form: Area and City come from the map pin (shown
/// read-only with a "Change" link back to the map), the remaining fields
/// depend on the address type, like talabat:
///
/// * Apartment: Building name*, Apartment no.*, Floor
/// * Villa:     Villa no.*
/// * Office:    Building name*, Company, Floor
/// * all:       Street (required if the admin says so), Additional directions
///
/// Only used when the country's fields carry address roles; other countries
/// keep the generic [CustomFieldsForm].
class TypedAddressForm extends StatefulWidget {
  const TypedAddressForm({
    required this.fields,
    required this.kind,
    required this.pinParts,
    required this.onChangeLocation,
    this.initialValues,
    super.key,
  });

  final List<CustomFieldModel> fields;

  /// [AddressKind] value.
  final String kind;

  /// Reverse-geocoded parts of the pin: street / area / city.
  final Map<String, String> pinParts;
  final VoidCallback onChangeLocation;
  final Map<String, dynamic>? initialValues;

  /// True when the country's fields are set up for this form.
  static bool supports(final List<CustomFieldModel> fields) => fields.any(
    (f) =>
        f.addressRole == AddressRole.building ||
        f.addressRole == AddressRole.apartment,
  );

  @override
  State<TypedAddressForm> createState() => TypedAddressFormState();
}

class TypedAddressFormState extends State<TypedAddressForm> {
  final Map<int, TextEditingController> _controllers = {};

  // Stored values carry a readable prefix so providers see "Apt 304, Floor 3"
  // instead of bare numbers; the prefix is stripped for editing.
  static const Map<String, String> _prefixes = {
    AddressRole.apartment: 'Apt',
    AddressRole.floor: 'Floor',
  };

  /// Value as stored on the address ("304" -> "Apt 304" for an apartment).
  @visibleForTesting
  static String toStored(final String? role, final String value) {
    final String editable = toEditable(role, value);
    final String? prefix = _prefixes[role];
    if (editable.isEmpty || prefix == null) return editable;
    return '$prefix $editable';
  }

  /// Stored value without its prefix, for the text field ("Apt 304" -> "304").
  @visibleForTesting
  static String toEditable(final String? role, final String stored) {
    final String value = stored.trim();
    final String? prefix = _prefixes[role];
    if (prefix == null) return value;
    return value.replaceFirst(
      RegExp('^${RegExp.escape(prefix)}\\.?\\s*', caseSensitive: false),
      '',
    );
  }

  CustomFieldModel? _byRole(final String role) =>
      widget.fields.where((f) => f.addressRole == role).firstOrNull;

  String _pin(final String key) => (widget.pinParts[key] ?? '').trim();

  @override
  void initState() {
    super.initState();
    for (final CustomFieldModel field in widget.fields) {
      String initial = toEditable(
        field.addressRole,
        widget.initialValues?[field.id.toString()]?.toString() ?? '',
      );
      // The pin decides Area / City (and pre-fills an empty Street).
      final String pinValue = switch (field.addressRole) {
        AddressRole.area => _pin('area'),
        AddressRole.city => _pin('city'),
        AddressRole.street when initial.isEmpty => _pin('street'),
        _ => '',
      };
      if (pinValue.isNotEmpty) initial = pinValue;
      _controllers[field.id] = TextEditingController(text: initial);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _visible(final CustomFieldModel field) => field.appliesTo(widget.kind);

  bool _required(final CustomFieldModel field) => switch (field.addressRole) {
    AddressRole.building => true,
    AddressRole.apartment => widget.kind == AddressKind.apartment,
    AddressRole.area || AddressRole.city => field.isRequired,
    AddressRole.floor || AddressRole.company || AddressRole.directions => false,
    _ => field.isRequired,
  };

  String _label(final CustomFieldModel field) => switch (field.addressRole) {
    AddressRole.building when widget.kind == AddressKind.villa => trOr(
      context,
      'villaNumber',
      'Villa no.',
    ),
    AddressRole.building => trOr(context, 'buildingName', 'Building name'),
    AddressRole.apartment => trOr(context, 'apartmentNumber', 'Apartment no.'),
    AddressRole.floor => trOr(context, 'floor', 'Floor'),
    AddressRole.company => trOr(context, 'companyName', 'Company name'),
    AddressRole.street => trOr(context, 'street', 'Street'),
    AddressRole.directions => trOr(
      context,
      'additionalDirections',
      'Additional directions (optional)',
    ),
    _ => field.name,
  };

  /// Values for every field of the country. Fields hidden for the chosen type
  /// are sent empty so a type change clears them on the saved address.
  List<Map<String, dynamic>> getValues() => [
    for (final CustomFieldModel field in widget.fields)
      {
        'custom_field_id': field.id,
        'value': _visible(field) ? _storedValue(field) : '',
        'type': field.type.name,
      },
  ];

  String _storedValue(final CustomFieldModel field) =>
      toStored(field.addressRole, _controllers[field.id]?.text ?? '');

  Widget _pinCard() {
    // From the fields when the country has them, else straight from the pin.
    final String area =
        _controllers[_byRole(AddressRole.area)?.id]?.text ?? _pin('area');
    final String city =
        _controllers[_byRole(AddressRole.city)?.id]?.text ?? _pin('city');
    final String place = [
      area,
      city,
    ].where((s) => s.trim().isNotEmpty).join(', ');
    return CustomContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      color: context.colors.backgroundSecondary,
      borderRadius: UiUtils.borderRadiusOf12,
      child: Row(
        children: [
          CustomSvgPicture(
            svgImage: AppAssets.icLocation,
            height: 20,
            width: 20,
            color: context.colors.iconBrand,
            avoideResponsive: true,
          ),
          const CustomSizedBox(width: 10),
          Expanded(
            child: CustomText(
              place.isEmpty
                  ? trOr(context, 'locationFromMap', 'Location from the map')
                  : place,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              maxLines: 2,
            ),
          ),
          CustomInkWellContainer(
            onTap: widget.onChangeLocation,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CustomText(
                'change'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(final CustomFieldModel field) {
    final bool required = _required(field);
    final String label = _label(field);
    final bool isDirections = field.addressRole == AddressRole.directions;
    return CustomTextFormField(
      key: ValueKey('addr_${field.id}'),
      bottomPadding: 10,
      controller: _controllers[field.id],
      fillColor: context.colors.backgroundSecondary,
      labelText: label,
      hintText: label,
      isRequired: required,
      // Multi-line keyboard lifts CustomTextFormField's maxLines from 1 to 5;
      // minLines: 2 with the default single-line keyboard asserts.
      textInputType: isDirections
          ? TextInputType.multiline
          : TextInputType.text,
      minLines: isDirections ? 2 : null,
      validator: required
          ? (value) => (value ?? '').trim().isEmpty
                ? trOr(context, 'fieldRequired', 'This field is required')
                : null
          : null,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final CustomFieldModel? areaField = _byRole(AddressRole.area);
    final CustomFieldModel? cityField = _byRole(AddressRole.city);
    // Area / City are typed only when the map could not name them.
    final bool pinNamesPlace =
        (areaField == null || _controllers[areaField.id]!.text.isNotEmpty) &&
        (cityField == null || _controllers[cityField.id]!.text.isNotEmpty);

    final List<CustomFieldModel> shown = widget.fields.where((f) {
      if (!_visible(f)) return false;
      final bool fromPin =
          f.addressRole == AddressRole.area ||
          f.addressRole == AddressRole.city;
      return !(fromPin && pinNamesPlace);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pinCard(),
        for (final CustomFieldModel field in shown) _field(field),
      ],
    );
  }
}
