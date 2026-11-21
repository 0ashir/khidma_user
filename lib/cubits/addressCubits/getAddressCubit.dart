import 'package:e_demand/app/generalImports.dart';

abstract class GetAddressState {}

class GetAddressInitial extends GetAddressState {}

class GetAddressInProgress extends GetAddressState {}

class GetAddressSuccess extends GetAddressState {
  GetAddressSuccess(this.data);
  List<GetAddressModel> data;
}

class GetAddressFail extends GetAddressState {
  GetAddressFail(this.error);
  final String error;
}

class GetAddressCubit extends Cubit<GetAddressState> {
  GetAddressCubit() : super(GetAddressInitial());

  final AddressRepository _address = AddressRepository();

  int _latestRequest = 0;

  /// Account (token) the list on screen belongs to; another account never
  /// sees it, even for a moment.
  String? _listOwner;

  /// Saved addresses show instantly: the list already on screen (or the last
  /// saved copy) stays while the fresh list loads in the background.
  Future fetchAddress() async {
    final int request = ++_latestRequest;
    final String owner = HiveRepository.getUserToken;
    if (state is! GetAddressSuccess || _listOwner != owner) {
      final List<GetAddressModel>? cached = _address.cachedAddresses();
      _listOwner = owner;
      emit(cached != null ? GetAddressSuccess(cached) : GetAddressInProgress());
    }
    try {
      final List<GetAddressModel> response = await _address.fetchAddress();
      if (isClosed || request != _latestRequest) return;
      _listOwner = owner;
      emit(GetAddressSuccess(response));
    } catch (e) {
      if (isClosed || request != _latestRequest) return;
      // A failed refresh keeps the list already shown (same account only).
      if (state is GetAddressSuccess && _listOwner == owner) return;
      emit(GetAddressFail(e.toString()));
    }
  }

  void updateDefaultAddress(String defaultAddressId) {
    if (state is GetAddressSuccess) {
      List<GetAddressModel> addressList = (state as GetAddressSuccess).data;

      addressList = addressList.map((address) {
        if (address.isDefault == '1') {
          return address.copyWith(isDefault: '0');
        }
        return address;
      }).toList();

      addressList = addressList.map((address) {
        if (address.id == defaultAddressId) {
          return address.copyWith(isDefault: '1');
        }
        return address;
      }).toList();

      emit(GetAddressSuccess(addressList));
    }
  }
}
