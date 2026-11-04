import 'package:e_demand/app/generalImports.dart';

abstract class GetCustomFieldsState {}

class GetCustomFieldsInitial extends GetCustomFieldsState {}

class GetCustomFieldsInProgress extends GetCustomFieldsState {}

class GetCustomFieldsSuccess extends GetCustomFieldsState {
  GetCustomFieldsSuccess({required this.fields, required this.savedValues});
  final List<CustomFieldModel> fields;

  /// Pre-filled values keyed by id string (e.g. "123").
  final Map<String, dynamic> savedValues;
}

class GetCustomFieldsFail extends GetCustomFieldsState {
  GetCustomFieldsFail(this.error);
  final String error;
}

class GetCustomFieldsCubit extends Cubit<GetCustomFieldsState> {
  GetCustomFieldsCubit() : super(GetCustomFieldsInitial());

  final AddressRepository _addressRepository = AddressRepository();

  Future<void> fetchCustomFields({String? addressId}) async {
    try {
      emit(GetCustomFieldsInProgress());
      final CustomFieldsResponse result = await _addressRepository
          .fetchCustomFields(addressId: addressId);
      emit(
        GetCustomFieldsSuccess(
          fields: result.fields,
          savedValues: result.savedValues,
        ),
      );
    } catch (e) {
      emit(GetCustomFieldsFail(e.toString()));
    }
  }
}
