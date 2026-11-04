import 'package:e_demand/app/generalImports.dart';

abstract class SearchProvidersResultState {}

class SearchProvidersResultInitial extends SearchProvidersResultState {}

class SearchProvidersResultFetchInProgress extends SearchProvidersResultState {}

class SearchProvidersResultFetchSuccess extends SearchProvidersResultState {
  SearchProvidersResultFetchSuccess({
    required this.providerList,
    required this.totalProviders,
    required this.isLoadingMore,
    this.serviceMinPrice,
    this.serviceMaxPrice,
  });

  final List<Providers> providerList;
  final int totalProviders;
  final bool isLoadingMore;
  final String? serviceMinPrice;
  final String? serviceMaxPrice;

  SearchProvidersResultFetchSuccess copyWith({
    final List<Providers>? providerList,
    final int? totalProviders,
    final bool? isLoadingMore,
    final String? serviceMinPrice,
    final String? serviceMaxPrice,
  }) => SearchProvidersResultFetchSuccess(
    providerList: providerList ?? this.providerList,
    totalProviders: totalProviders ?? this.totalProviders,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    serviceMinPrice: serviceMinPrice ?? this.serviceMinPrice,
    serviceMaxPrice: serviceMaxPrice ?? this.serviceMaxPrice,
  );
}

class SearchProvidersResultFetchFailure extends SearchProvidersResultState {
  SearchProvidersResultFetchFailure({required this.errorMessage});
  final String errorMessage;
}

class SearchProvidersResultCubit extends Cubit<SearchProvidersResultState> {
  SearchProvidersResultCubit(this.providerRepository)
    : super(SearchProvidersResultInitial());
  final ProviderRepository providerRepository;

  ProviderFilterModel? _filter;
  String _search = '';

  ProviderFilterModel? get currentFilter => _filter;

  Future<void> search(final String query) async {
    _search = query;
    emit(SearchProvidersResultFetchInProgress());
    try {
      final Map<String, dynamic> data = await providerRepository
          .fetchProviderList(
            isAuthTokenRequired: true,
            search: _search,
            offset: "0",
            limit: UiUtils.limitOfAPIData,
            sortBy: _filter?.apiSortBy,
            ratingMin: _filter?.apiRatingMin,
            providerType: _filter?.apiProviderType,
            priceMax: _filter?.apiPriceMax,
          );
      emit(
        SearchProvidersResultFetchSuccess(
          providerList: List<Providers>.from(data['providerList'] ?? []),
          totalProviders:
              int.tryParse(data['totalProviders']?.toString() ?? "0") ?? 0,
          isLoadingMore: false,
          serviceMinPrice: data['serviceMinPrice']?.toString(),
          serviceMaxPrice: data['serviceMaxPrice']?.toString(),
        ),
      );
    } catch (e) {
      emit(SearchProvidersResultFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMore() async {
    if (state is! SearchProvidersResultFetchSuccess) return;
    final SearchProvidersResultFetchSuccess currentState =
        state as SearchProvidersResultFetchSuccess;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final Map<String, dynamic> data = await providerRepository
          .fetchProviderList(
            isAuthTokenRequired: true,
            search: _search,
            offset: currentState.providerList.length.toString(),
            limit: UiUtils.limitOfAPIData,
            sortBy: _filter?.apiSortBy,
            ratingMin: _filter?.apiRatingMin,
            providerType: _filter?.apiProviderType,
            priceMax: _filter?.apiPriceMax,
          );
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          providerList: [
            ...currentState.providerList,
            ...List<Providers>.from(data['providerList'] ?? []),
          ],
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  bool hasMore() {
    if (state is SearchProvidersResultFetchSuccess) {
      final SearchProvidersResultFetchSuccess currentState =
          state as SearchProvidersResultFetchSuccess;
      return currentState.providerList.length < currentState.totalProviders;
    }
    return false;
  }

  Future<void> applyFilter(final ProviderFilterModel? filter) async {
    _filter = filter;
    await search(_search);
  }
}
