import 'package:e_demand/data/model/customFieldModel.dart';
import 'package:e_demand/ui/widgets/customFields/typedAddressForm.dart';
import 'package:flutter_test/flutter_test.dart';

/// Field definitions as the live get_address_custom_fields API returns them
/// for a UAE pin (2026-11-19).
final List<Map<String, dynamic>> _uaeFields = [
  {
    'id': 17,
    'label': 'Building/Villa Number',
    'field_type': 'text',
    'required': 1,
    'visible': 1,
    'sort_order': 10,
    'file_config': {'address_role': 'building'},
  },
  {
    'id': 33,
    'label': 'Apartment No.',
    'field_type': 'text',
    'required': 0,
    'visible': 1,
    'sort_order': 11,
    'file_config': {
      'address_role': 'apartment',
      'address_types': ['apartment'],
    },
  },
  {
    'id': 34,
    'label': 'Floor',
    'field_type': 'text',
    'required': 0,
    'visible': 1,
    'sort_order': 12,
    'file_config': {
      'address_role': 'floor',
      'address_types': ['apartment', 'office'],
    },
  },
  {
    'id': 35,
    'label': 'Company Name',
    'field_type': 'text',
    'required': 0,
    'visible': 1,
    'sort_order': 13,
    'file_config': {
      'address_role': 'company',
      'address_types': ['office'],
    },
  },
  {
    'id': 18,
    'label': 'Street Address',
    'field_type': 'text',
    'required': 0,
    'visible': 1,
    'sort_order': 20,
    'file_config': {'address_role': 'street'},
  },
  {
    'id': 36,
    'label': 'Additional Directions',
    'field_type': 'text',
    'required': 0,
    'visible': 1,
    'sort_order': 50,
    'file_config': {'address_role': 'directions'},
  },
];

void main() {
  final List<CustomFieldModel> fields = _uaeFields
      .map(CustomFieldModel.fromJson)
      .toList();
  CustomFieldModel role(final String r) =>
      fields.firstWhere((f) => f.addressRole == r);
  List<String> shownFor(final String kind) => fields
      .where((f) => f.appliesTo(kind))
      .map((f) => f.addressRole!)
      .toList();

  test('roles and types are read from file_config', () {
    expect(role('apartment').addressTypes, ['apartment']);
    expect(role('building').addressTypes, isEmpty);
    expect(TypedAddressForm.supports(fields), isTrue);
    // A country without roles keeps the generic form.
    expect(
      TypedAddressForm.supports([
        CustomFieldModel.fromJson({
          'id': 1,
          'label': 'City',
          'file_config': null,
        }),
      ]),
      isFalse,
    );
  });

  test('each address type shows talabat-style fields', () {
    expect(shownFor(AddressKind.apartment), [
      'building',
      'apartment',
      'floor',
      'street',
      'directions',
    ]);
    expect(shownFor(AddressKind.villa), ['building', 'street', 'directions']);
    expect(shownFor(AddressKind.office), [
      'building',
      'floor',
      'company',
      'street',
      'directions',
    ]);
  });

  test('apartment and floor are stored with readable prefixes', () {
    expect(TypedAddressFormState.toStored('apartment', ' 304 '), 'Apt 304');
    expect(TypedAddressFormState.toStored('floor', '3'), 'Floor 3');
    expect(TypedAddressFormState.toStored('floor', ''), '');
    // Typing the prefix yourself does not double it.
    expect(TypedAddressFormState.toStored('apartment', 'apt. 12'), 'Apt 12');
    expect(
      TypedAddressFormState.toStored('building', 'Marina Tower'),
      'Marina Tower',
    );
    expect(TypedAddressFormState.toEditable('apartment', 'Apt 304'), '304');
    expect(TypedAddressFormState.toEditable('floor', 'Floor 3'), '3');
    expect(TypedAddressFormState.toEditable('street', 'Floor St'), 'Floor St');
  });

  test('address type maps to and from the API value', () {
    expect(AddressKind.toApiType(AddressKind.villa), 'Villa');
    expect(AddressKind.fromApiType('Office'), AddressKind.office);
    // Legacy types open as Apartment.
    expect(AddressKind.fromApiType('home'), AddressKind.apartment);
    expect(AddressKind.fromApiType(null), AddressKind.apartment);
  });
}
