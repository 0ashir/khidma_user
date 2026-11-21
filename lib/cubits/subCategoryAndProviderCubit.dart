import 'package:e_demand/app/generalImports.dart';

abstract class SubCategoryAndProviderState {}

class SubCategoryAndProviderInitial extends SubCategoryAndProviderState {}

class SubCategoryAndProviderFetchInProgress
    extends SubCategoryAndProviderState {}

class FilteredProviderFetchInProgress extends SubCategoryAndProviderState {}

class SubCategoryAndProviderFetchSuccess extends SubCategoryAndProviderState {
  SubCategoryAndProviderFetchSuccess({
    required this.subCategoryList,
    required this.providerList,
    required this.totalProviders,
    this.serviceMinPrice,
    this.serviceMaxPrice,
  });

  final List<SubCategory> subCategoryList;
  final List<Providers> providerList;
  final String totalProviders;
  final String? serviceMinPrice;
  final String? serviceMaxPrice;
}

class SubCategoryAndProviderFetchFailure extends SubCategoryAndProviderState {
  SubCategoryAndProviderFetchFailure({required this.errorMessage});

  final String errorMessage;
}

/* CUBIT */
class SubCategoryAndProviderCubit extends Cubit<SubCategoryAndProviderState> {
  SubCategoryAndProviderCubit({
    required this.subCategoryRepository,
    required this.providerRepository,
  }) : super(SubCategoryAndProviderInitial());
  SubCategoryRepository subCategoryRepository;
  ProviderRepository providerRepository;

  /// Fingerprint of what is on screen; an unchanged refresh is not re-emitted.
  String? _shownFingerprint;
  int _latestRequest = 0;

  /// Network-level failures (offline, timeout, server down). Other errors are
  /// the backend's "nothing found" answer, i.e. a real empty result.
  static bool _isConnectionError(final Object error) {
    final String message = error.toString();
    return const [
      'noInternetFound',
      'somethingWentWrong',
      'internalServerError',
      'serviceUnavailable',
    ].any(message.contains);
  }

  Map<String, dynamic> _providerParameter({
    required final String categoryID,
    final String? subCategoryID,
    final String? providerSortBy,
    final int? availableToday,
    final int? maxDuration,
    final String? providerType,
    final String? sortBy,
    final double? ratingMin,
    final double? priceMax,
  }) => ProviderRepository.providerListParameter(
    categoryId: categoryID,
    subCategoryId: subCategoryID ?? '',
    filter: providerSortBy ?? '',
    availableToday: availableToday,
    maxDuration: maxDuration,
    providerType: providerType,
    sortBy: sortBy,
    ratingMin: ratingMin,
    priceMax: priceMax,
  );

  void _show(
    final List<SubCategory> subCategoryList,
    final Map<String, dynamic>? providersData,
    final String fingerprint,
  ) {
    if (isClosed) return;
    if (state is SubCategoryAndProviderFetchSuccess &&
        fingerprint == _shownFingerprint) {
      return;
    }
    _shownFingerprint = fingerprint;
    emit(
      SubCategoryAndProviderFetchSuccess(
        subCategoryList: subCategoryList,
        providerList: List<Providers>.from(
          providersData?['providerList'] ?? const <Providers>[],
        ),
        totalProviders: providersData?['totalProviders']?.toString() ?? '0',
        serviceMinPrice: providersData?['serviceMinPrice'],
        serviceMaxPrice: providersData?['serviceMaxPrice'],
      ),
    );
  }

  ///This method is used to fetch subCategories and Providers based on CategoryId/SubCategory Id
  ///
  /// Stale-while-revalidate: the last saved page for this category, filters
  /// and location shows at once; subcategories and providers are then fetched
  /// in parallel and the page only updates if the data changed.
  Future<void> getSubCategoriesAndProviderList({
    final String? categoryID,
    final String? subCategoryID,
    final String? providerSortBy,
    final int? availableToday,
    final int? maxDuration,
    final String? providerType,
    final String? sortBy,
    final double? ratingMin,
    final double? priceMax,
  }) async {
    final int request = ++_latestRequest;
    final String subCategoryKey = subCategoryID ?? categoryID ?? '';
    final Map<String, dynamic> providerParameter = _providerParameter(
      categoryID: categoryID ?? '',
      subCategoryID: subCategoryID,
      providerSortBy: providerSortBy,
      availableToday: availableToday,
      maxDuration: maxDuration,
      providerType: providerType,
      sortBy: sortBy,
      ratingMin: ratingMin,
      priceMax: priceMax,
    );

    final Map<String, dynamic>? cachedSubCategories = subCategoryRepository
        .cachedSubCategory(categoryID: subCategoryKey);
    final Map<String, dynamic>? cachedProviders = providerRepository
        .cachedProviderList(providerParameter);
    final bool showedCache = cachedSubCategories != null;
    if (showedCache) {
      _show(
        List<SubCategory>.from(cachedSubCategories['subCategoryList']),
        cachedProviders,
        '${cachedSubCategories['fingerprint']}|${cachedProviders?['fingerprint']}',
      );
    } else {
      _shownFingerprint = null;
      emit(SubCategoryAndProviderFetchInProgress());
    }

    // Both requests run in parallel. Providers are fetched separately so that
    // a category with subcategories but no providers of its own (backend
    // throws on zero results) still shows its subcategories.
    final Future<Map<String, dynamic>> subCategoryFuture = subCategoryRepository
        .fetchSubCategory(
          categoryID: subCategoryKey,
          isAuthTokenRequired: false,
          saveToCache: true,
        );
    final Future<Object> providersFuture = providerRepository
        .fetchProviderList(
          isAuthTokenRequired: true,
          categoryId: categoryID ?? '',
          subCategoryId: subCategoryID ?? '',
          filter: providerSortBy ?? '',
          availableToday: availableToday,
          maxDuration: maxDuration,
          providerType: providerType,
          sortBy: sortBy,
          ratingMin: ratingMin,
          priceMax: priceMax,
          saveToCache: true,
        )
        .then<Object>((value) => value)
        .catchError((final Object error) => error);

    final List<SubCategory> subCategoryList;
    final String subCategoryFingerprint;
    try {
      final Map<String, dynamic> subCategoryData = await subCategoryFuture;
      subCategoryList = List<SubCategory>.from(
        subCategoryData['subCategoryList'],
      );
      subCategoryFingerprint = '${subCategoryData['fingerprint']}';
    } catch (error) {
      if (isClosed || request != _latestRequest) return;
      // Offline: keep the cached page instead of an error.
      if (showedCache) return;
      emit(SubCategoryAndProviderFetchFailure(errorMessage: error.toString()));
      return;
    }

    final Object providers = await providersFuture;
    if (isClosed || request != _latestRequest) return;
    if (providers is Map<String, dynamic>) {
      _show(
        subCategoryList,
        providers,
        '$subCategoryFingerprint|${providers['fingerprint']}',
      );
    } else if (showedCache &&
        cachedProviders != null &&
        _isConnectionError(providers)) {
      // Connection problem: keep the cached providers rather than "none".
      _show(
        subCategoryList,
        cachedProviders,
        '$subCategoryFingerprint|${cachedProviders['fingerprint']}',
      );
    } else {
      _show(subCategoryList, null, '$subCategoryFingerprint|empty');
    }
  }

  Future<void> fetchProvidersForSubCategory({
    required final String categoryID,
    final String? subCategoryID,
    final int? availableToday,
    final int? maxDuration,
    final String? providerType,
    final String? sortBy,
    final double? ratingMin,
    final double? priceMax,
  }) async {
    if (state is! SubCategoryAndProviderFetchSuccess) return;
    final SubCategoryAndProviderFetchSuccess currentState =
        state as SubCategoryAndProviderFetchSuccess;
    final int request = ++_latestRequest;
    final String subCategoryPart = _shownFingerprint?.split('|').first ?? '';

    final Map<String, dynamic>? cachedProviders = providerRepository
        .cachedProviderList(
          _providerParameter(
            categoryID: categoryID,
            subCategoryID: subCategoryID,
            availableToday: availableToday,
            maxDuration: maxDuration,
            providerType: providerType,
            sortBy: sortBy,
            ratingMin: ratingMin,
            priceMax: priceMax,
          ),
        );
    if (cachedProviders != null) {
      _show(
        currentState.subCategoryList,
        cachedProviders,
        '$subCategoryPart|${cachedProviders['fingerprint']}',
      );
    } else {
      _shownFingerprint = null;
      emit(SubCategoryAndProviderFetchInProgress());
    }

    try {
      final providersData = await providerRepository.fetchProviderList(
        isAuthTokenRequired: true,
        categoryId: categoryID,
        subCategoryId: subCategoryID ?? '',
        availableToday: availableToday,
        maxDuration: maxDuration,
        providerType: providerType,
        sortBy: sortBy,
        ratingMin: ratingMin,
        priceMax: priceMax,
        saveToCache: true,
      );
      if (isClosed || request != _latestRequest) return;
      _show(
        currentState.subCategoryList,
        providersData,
        '$subCategoryPart|${providersData['fingerprint']}',
      );
    } catch (error) {
      if (isClosed || request != _latestRequest) return;
      if (cachedProviders != null && _isConnectionError(error)) return;
      _show(currentState.subCategoryList, null, '$subCategoryPart|empty');
    }
  }

  List<SubCategory> getSubCategoryList() {
    List<SubCategory> subCategories = <SubCategory>[];
    if (state is SubCategoryAndProviderFetchSuccess) {
      subCategories =
          (state as SubCategoryAndProviderFetchSuccess).subCategoryList;
    }
    return subCategories;
  }

  void emitSuccessState({
    required final List<Providers> providerList,
    required final String totalProviders,
  }) {
    if (state is SubCategoryAndProviderFetchSuccess) {
      final SubCategoryAndProviderFetchSuccess successState =
          state as SubCategoryAndProviderFetchSuccess;

      emit(
        SubCategoryAndProviderFetchSuccess(
          subCategoryList: successState.subCategoryList,
          providerList: providerList,
          totalProviders: totalProviders,
          serviceMinPrice: successState.serviceMinPrice,
          serviceMaxPrice: successState.serviceMaxPrice,
        ),
      );
    }
  }
}
