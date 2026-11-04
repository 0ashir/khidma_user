import 'package:e_demand/app/generalImports.dart';

abstract class GetAllPromocodesState {}

class GetAllPromocodesInitial extends GetAllPromocodesState {}

class GetAllPromocodesFetchInProgress extends GetAllPromocodesState {}

class GetAllPromocodesFetchSuccess extends GetAllPromocodesState {
  GetAllPromocodesFetchSuccess({
    required this.promocodeList,
    required this.totalPromocodes,
    required this.isLoadingMore,
  });

  final List<Promocode> promocodeList;
  final int totalPromocodes;
  final bool isLoadingMore;

  GetAllPromocodesFetchSuccess copyWith({
    final List<Promocode>? promocodeList,
    final int? totalPromocodes,
    final bool? isLoadingMore,
  }) => GetAllPromocodesFetchSuccess(
    promocodeList: promocodeList ?? this.promocodeList,
    totalPromocodes: totalPromocodes ?? this.totalPromocodes,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class GetAllPromocodesFetchFailure extends GetAllPromocodesState {
  GetAllPromocodesFetchFailure({required this.errorMessage});
  final String errorMessage;
}

class GetAllPromocodesCubit extends Cubit<GetAllPromocodesState> {
  GetAllPromocodesCubit({required this.cartRepository})
    : super(GetAllPromocodesInitial());
  final CartRepository cartRepository;

  String? _providerIdOrSlug;
  ProviderDetailsParamType? _type;

  Future<void> getAllPromocodes({
    final String? providerIdOrSlug,
    final ProviderDetailsParamType? type,
  }) async {
    _providerIdOrSlug = providerIdOrSlug;
    _type = type;
    emit(GetAllPromocodesFetchInProgress());
    try {
      final Map<String, dynamic> data = await cartRepository
          .fetchAllPromocodes(
            offset: "0",
            limit: UiUtils.limitOfAPIData,
            providerIdOrSlug: _providerIdOrSlug,
            type: _type,
          );
      emit(
        GetAllPromocodesFetchSuccess(
          promocodeList: List<Promocode>.from(data['promocodeList'] ?? []),
          totalPromocodes:
              int.tryParse(data['totalPromocodes']?.toString() ?? "0") ?? 0,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(GetAllPromocodesFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMore() async {
    if (state is! GetAllPromocodesFetchSuccess) return;
    final GetAllPromocodesFetchSuccess currentState =
        state as GetAllPromocodesFetchSuccess;
    if (currentState.isLoadingMore || !hasMore()) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final Map<String, dynamic> data = await cartRepository
          .fetchAllPromocodes(
            offset: currentState.promocodeList.length.toString(),
            limit: UiUtils.limitOfAPIData,
            providerIdOrSlug: _providerIdOrSlug,
            type: _type,
          );
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          promocodeList: [
            ...currentState.promocodeList,
            ...List<Promocode>.from(data['promocodeList'] ?? []),
          ],
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  bool hasMore() {
    if (state is GetAllPromocodesFetchSuccess) {
      final GetAllPromocodesFetchSuccess currentState =
          state as GetAllPromocodesFetchSuccess;
      return currentState.promocodeList.length < currentState.totalPromocodes;
    }
    return false;
  }
}
