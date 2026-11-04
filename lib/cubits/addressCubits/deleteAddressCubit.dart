import 'package:e_demand/app/generalImports.dart';

abstract class DeleteAddressState {}

class DeleteAddressInitial extends DeleteAddressState {}

class DeleteAddressInProgress extends DeleteAddressState {}

class DeleteAddressSuccess extends DeleteAddressState {
  List<GetAddressModel> data;
  final String id;

  DeleteAddressSuccess({required this.id, required this.data});
}

class DeleteAddressFail extends DeleteAddressState {
  DeleteAddressFail(this.error);

  final dynamic error;
}

class DeleteAddressCubit extends Cubit<DeleteAddressState> {
  DeleteAddressCubit() : super(DeleteAddressInitial());
  final AddressRepository _address = AddressRepository();

  Future deleteAddress(final String id) async {
    try {
      emit(DeleteAddressInProgress());
      final Map<String, dynamic> response = await _address.deleteAddress(id);
      ClarityService.logAction(ClarityActions.addressDeleted, {
        'address_id': id,
      });
      emit(
        DeleteAddressSuccess(
          id: id,
          // `data` lists the remaining addresses only when a new default was
          // assigned after the delete; otherwise it can be empty or absent.
          data: response['data'] is List
              ? (response['data'] as List)
                    .map((final entry) => GetAddressModel.fromJson(entry))
                    .toList()
              : <GetAddressModel>[],
        ),
      );
    } catch (e) {
      ClarityService.logAction(ClarityActions.addressDeleted, {
        'address_id': id,
        'status': 'error',
        'message': e.toString(),
      });
      emit(DeleteAddressFail(e.toString()));
    }
  }
}
