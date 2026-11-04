// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:e_demand/app/generalImports.dart';

class AddressRepository {
  // Country names follow the app language, so cache per language code. Lets the
  // address sheet show the list instantly after a prefetch.
  static final Map<String, List<Country>> _countriesCache = {};

  Future<Map<String, dynamic>> addAddress(
    final AddressModel addressDataModel,
  ) async {
    try {
      final Map<String, dynamic> parameters = addressDataModel.toMap();

      parameters[ApiParam.lattitude] = addressDataModel.latitude;

      // Convert file-type custom field values to MultipartFile for
      // multipart/form-data submission.
      if (addressDataModel.customFieldValues != null) {
        final customFields = addressDataModel.customFieldValues!;
        for (int i = 0; i < customFields.length; i++) {
          final field = customFields[i];
          final bool isFile = field['type']?.toString() == 'file';
          final String? filePath = field['value']?.toString();

          if (isFile && filePath != null && filePath.isNotEmpty) {
            parameters['custom_fields[$i][value]'] =
                await MultipartFile.fromFile(filePath);
          }
          // The non-file bracket-notation keys were already set by toMap().
        }
      }

      final response = await ApiClient.post(
        url: ApiUrl.addAddress,
        parameter: parameters,
        useAuthToken: true,
      );

      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateDefaultAddress(final String Id) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.addAddress,
        parameter: {ApiParam.addressId: Id, ApiParam.isDefault: "1"},
        useAuthToken: true,
      );
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// [addressId] fetches a single address; [search] filters the list.
  Future<List<GetAddressModel>> fetchAddress({
    final String? addressId,
    final String? search,
  }) async {
    try {
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.getAddress,
        parameter: {
          ApiParam.limit: 100,
          ApiParam.offset: 0,
          if (addressId != null && addressId.isNotEmpty)
            ApiParam.addressId: addressId,
          if (search != null && search.isNotEmpty) ApiParam.search: search,
        },
        useAuthToken: true,
      );

      final List<GetAddressModel> mappedResponse =
          (response['data'] as List<dynamic>).map((final entry) {
            final getAddressModel = GetAddressModel.fromJson(entry);

            return getAddressModel;
          }).toList();

      return mappedResponse;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteAddress(final String id) async {
    final Map<String, dynamic> parameter = <String, dynamic>{
      ApiParam.addressId: id,
    };
    try {
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.deleteAddress,
        parameter: parameter,
        useAuthToken: true,
      );

      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Active countries for the address country input (public endpoint).
  Future<List<Country>> fetchCountries() async {
    try {
      final String languageKey =
          HiveRepository.getCurrentLanguage()?.languageCode ?? '';
      final List<Country>? cached = _countriesCache[languageKey];
      if (cached != null) return cached;

      final Map<String, dynamic> response = await ApiClient.get(
        url: ApiUrl.getCountries,
        useAuthToken: false,
      );
      final List<Country> countries = (response['data'] as List? ?? [])
          .map((final e) => Country.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (countries.isNotEmpty) _countriesCache[languageKey] = countries;
      return countries;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Regions of [countryId]; empty when the country has none.
  Future<List<Region>> fetchRegions(final String countryId) async {
    try {
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.getRegions,
        parameter: {ApiParam.countryId: countryId},
        useAuthToken: false,
      );
      return (response['data'] as List? ?? [])
          .map((final e) => Region.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<CustomFieldsResponse> fetchCustomFields({String? addressId}) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };
      if (addressId != null && addressId.isNotEmpty) {
        parameter[ApiParam.addressId] = addressId;
      }

      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.getCustomFields,
        useAuthToken: true,
        parameter: parameter,
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};

      // Parse saved values for the given address
      final Map<String, dynamic> savedValues = {};

      // Parse field definitions
      final List<CustomFieldModel>
      fields = (data['custom_fields'] as List<dynamic>? ?? []).map((entry) {
        final map = entry as Map<String, dynamic>;

        // Sometimes the backend API might inject the "value" directly into the field definition
        if (map.containsKey('value') && map['value'] != null) {
          final key = map['id']?.toString();
          if (key != null) savedValues[key] = map['value'];
        }
        return CustomFieldModel.fromJson(map);
      }).toList();

      // Sort by sort_order
      fields.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Or they might be inside customer_address_custom_fields
      final savedList =
          data['customer_address_custom_fields'] as List<dynamic>? ?? [];
      for (final item in savedList) {
        if (item is Map<String, dynamic>) {
          final String? key =
              item['custom_field_id']?.toString() ?? item['id']?.toString();
          final value = item['value'];

          if (key != null && value != null) {
            savedValues[key] = value;
          }
        }
      }

      return CustomFieldsResponse(fields: fields, savedValues: savedValues);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
