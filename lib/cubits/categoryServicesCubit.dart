import 'package:e_demand/app/generalImports.dart';

abstract class CategoryServicesState {}

class CategoryServicesInitial extends CategoryServicesState {}

class CategoryServicesFetchInProgress extends CategoryServicesState {}

class CategoryServicesFetchSuccess extends CategoryServicesState {
  CategoryServicesFetchSuccess({
    required this.services,
    required this.totalServices,
    required this.isLoadingMore,
    this.serviceMinPrice,
    this.serviceMaxPrice,
  });

  final List<Services> services;
  final int totalServices;
  final bool isLoadingMore;
  final String? serviceMinPrice;
  final String? serviceMaxPrice;

  CategoryServicesFetchSuccess copyWith({
    final List<Services>? services,
    final int? totalServices,
    final bool? isLoadingMore,
    final String? serviceMinPrice,
    final String? serviceMaxPrice,
  }) => CategoryServicesFetchSuccess(
    services: services ?? this.services,
    totalServices: totalServices ?? this.totalServices,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    serviceMinPrice: serviceMinPrice ?? this.serviceMinPrice,
    serviceMaxPrice: serviceMaxPrice ?? this.serviceMaxPrice,
  );
}

class CategoryServicesFetchFailure extends CategoryServicesState {
  CategoryServicesFetchFailure({required this.errorMessage});
  final String errorMessage;
}

class CategoryServicesCubit extends Cubit<CategoryServicesState> {
  CategoryServicesCubit(this.serviceRepository)
    : super(CategoryServicesInitial());
  final ServiceRepository serviceRepository;

  ServiceFilterModel? _filter;
  bool _under1HourOnly = false;
  bool _availableTodayOnly = false;

  ServiceFilterModel? get currentFilter => _filter;
  bool get under1HourOnly => _under1HourOnly;
  bool get availableTodayOnly => _availableTodayOnly;

  int? get _effectiveDurationMax =>
      _under1HourOnly ? 60 : _filter?.apiDurationMax;

  Future<void> fetchServices({
    final String? categoryId,
    final String? search,
  }) async {
    emit(CategoryServicesFetchInProgress());
    try {
      final Map<String, dynamic> data = await serviceRepository
          .getServicesForCategory(
            categoryId: categoryId,
            search: search,
            offset: "0",
            limit: UiUtils.limitOfAPIData,
            sortBy: _filter?.apiSortBy,
            payLaterAllowed: _filter?.apiPayLaterAllowed,
            priceMax: _filter?.apiPriceMax,
            ratingMin: _filter?.apiRatingMin,
            durationMin: _filter?.apiDurationMin,
            durationMax: _effectiveDurationMax,
            serviceMode: _filter?.apiServiceMode,
            availableToday: _availableTodayOnly ? 1 : null,
          );
      emit(
        CategoryServicesFetchSuccess(
          services: List<Services>.from(data['services'] ?? []),
          totalServices:
              int.tryParse(data['totalServices']?.toString() ?? "0") ?? 0,
          isLoadingMore: false,
          serviceMinPrice: data['serviceMinPrice']?.toString(),
          serviceMaxPrice: data['serviceMaxPrice']?.toString(),
        ),
      );
    } catch (e) {
      emit(CategoryServicesFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMoreServices({
    final String? categoryId,
    final String? search,
  }) async {
    if (state is! CategoryServicesFetchSuccess) return;
    final CategoryServicesFetchSuccess currentState =
        state as CategoryServicesFetchSuccess;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final Map<String, dynamic> data = await serviceRepository
          .getServicesForCategory(
            categoryId: categoryId,
            search: search,
            offset: currentState.services.length.toString(),
            limit: UiUtils.limitOfAPIData,
            sortBy: _filter?.apiSortBy,
            payLaterAllowed: _filter?.apiPayLaterAllowed,
            priceMax: _filter?.apiPriceMax,
            ratingMin: _filter?.apiRatingMin,
            durationMin: _filter?.apiDurationMin,
            durationMax: _effectiveDurationMax,
            serviceMode: _filter?.apiServiceMode,
            availableToday: _availableTodayOnly ? 1 : null,
          );
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          services: [
            ...currentState.services,
            ...List<Services>.from(data['services'] ?? []),
          ],
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  bool hasMoreServices() {
    if (state is CategoryServicesFetchSuccess) {
      final CategoryServicesFetchSuccess currentState =
          state as CategoryServicesFetchSuccess;
      return currentState.services.length < currentState.totalServices;
    }
    return false;
  }

  Future<void> applyFilter({
    final String? categoryId,
    final String? search,
    required final ServiceFilterModel? filter,
  }) async {
    _filter = filter;
    await fetchServices(categoryId: categoryId, search: search);
  }

  Future<void> togglePayLater({required final String categoryId}) async {
    final bool isActive = _filter?.payLaterAllowed ?? false;
    _filter = (_filter ?? const ServiceFilterModel()).copyWith(
      payLaterAllowed: !isActive,
    );
    await fetchServices(categoryId: categoryId);
  }

  Future<void> toggleTopRated({required final String categoryId}) async {
    final bool isActive = _filter?.sortBy == ServiceSortBy.topRated;
    _filter = (_filter ?? const ServiceFilterModel()).copyWith(
      sortBy: isActive ? null : ServiceSortBy.topRated,
      clearSort: isActive,
    );
    await fetchServices(categoryId: categoryId);
  }

  Future<void> toggleUnder1Hour({required final String categoryId}) async {
    _under1HourOnly = !_under1HourOnly;
    await fetchServices(categoryId: categoryId);
  }

  Future<void> toggleAvailableToday({required final String categoryId}) async {
    _availableTodayOnly = !_availableTodayOnly;
    await fetchServices(categoryId: categoryId);
  }
}
