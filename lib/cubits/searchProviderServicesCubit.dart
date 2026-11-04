import 'package:e_demand/app/generalImports.dart';

abstract class SearchProviderServicesState {}

class SearchProviderServicesInitial extends SearchProviderServicesState {}

class SearchProviderServicesInProgress extends SearchProviderServicesState {}

class SearchProviderServicesSuccess extends SearchProviderServicesState {
  final List<ServiceCategoryGroup> serviceCategories;
  final int total;
  final bool isLoadingMore;

  SearchProviderServicesSuccess({
    required this.serviceCategories,
    required this.total,
    this.isLoadingMore = false,
  });

  int get loadedServicesCount =>
      serviceCategories.fold(0, (sum, group) => sum + group.services.length);

  SearchProviderServicesSuccess copyWith({
    List<ServiceCategoryGroup>? serviceCategories,
    int? total,
    bool? isLoadingMore,
  }) => SearchProviderServicesSuccess(
    serviceCategories: serviceCategories ?? this.serviceCategories,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class SearchProviderServicesFailure extends SearchProviderServicesState {
  final String errorMessage;
  SearchProviderServicesFailure({required this.errorMessage});
}

class SearchProviderServicesCubit
    extends Cubit<SearchProviderServicesState> {
  SearchProviderServicesCubit({required this.serviceRepository})
      : super(SearchProviderServicesInitial());

  final ServiceRepository serviceRepository;
  String _currentSearch = '';
  String _providerId = '';
  ProviderDetailsParamType _type = ProviderDetailsParamType.id;

  /// Merges a newly-fetched page of category groups into the ones already
  /// loaded: a category seen before gets its new services appended, a
  /// category seen for the first time is appended at the end.
  List<ServiceCategoryGroup> _mergeServiceCategories(
    final List<ServiceCategoryGroup> existing,
    final List<ServiceCategoryGroup> newPage,
  ) {
    final List<ServiceCategoryGroup> merged = [...existing];
    for (final ServiceCategoryGroup incoming in newPage) {
      final int existingIndex = merged.indexWhere(
        (final group) => group.categoryId == incoming.categoryId,
      );
      if (existingIndex == -1) {
        merged.add(incoming);
      } else {
        merged[existingIndex] = merged[existingIndex].copyWith(
          services: [
            ...merged[existingIndex].services,
            ...incoming.services,
          ],
        );
      }
    }
    return merged;
  }

  Future<void> searchServices({
    required String providerId,
    required String search,
    ProviderDetailsParamType type = ProviderDetailsParamType.id,
  }) async {
    _currentSearch = search;
    _providerId = providerId;
    _type = type;
    emit(SearchProviderServicesInProgress());
    try {
      final Map<String, dynamic> data = await serviceRepository.getServices(
        offset: '0',
        limit: UiUtils.limitOfAPIData,
        isAuthTokenRequired: HiveRepository.getUserToken != '',
        providerIdOrSlug: providerId,
        type: type,
        search: search,
      );
      emit(
        SearchProviderServicesSuccess(
          serviceCategories: List<ServiceCategoryGroup>.from(
            data['serviceCategories'] ?? [],
          ),
          total: int.tryParse(data['totalServices']?.toString() ?? '0') ?? 0,
        ),
      );
    } catch (e) {
      emit(SearchProviderServicesFailure(errorMessage: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state is! SearchProviderServicesSuccess) return;
    final currentState = state as SearchProviderServicesSuccess;
    if (currentState.isLoadingMore) return;
    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final Map<String, dynamic> data = await serviceRepository.getServices(
        offset: currentState.loadedServicesCount.toString(),
        limit: UiUtils.limitOfAPIData,
        isAuthTokenRequired: HiveRepository.getUserToken != '',
        providerIdOrSlug: _providerId,
        type: _type,
        search: _currentSearch,
      );
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          serviceCategories: _mergeServiceCategories(
            currentState.serviceCategories,
            List<ServiceCategoryGroup>.from(data['serviceCategories'] ?? []),
          ),
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  void resetSearch() => emit(SearchProviderServicesInitial());

  bool hasMore() {
    if (state is SearchProviderServicesSuccess) {
      final s = state as SearchProviderServicesSuccess;
      return s.loadedServicesCount < s.total;
    }
    return false;
  }
}
