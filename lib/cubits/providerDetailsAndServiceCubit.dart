import 'package:e_demand/app/generalImports.dart';

//state
abstract class ProviderDetailsAndServiceState {}

class ProviderDetailsAndServiceInitial extends ProviderDetailsAndServiceState {}

class ProviderDetailsAndServiceFetchInProgress
    extends ProviderDetailsAndServiceState {}

class MoreServiceFetchInProgress extends ProviderDetailsAndServiceState {}

class ProviderDetailsAndServiceFetchSuccess
    extends ProviderDetailsAndServiceState {
  ProviderDetailsAndServiceFetchSuccess({
    required this.providerDetails,
    required this.serviceCategories,
    required this.totalServices,
    required this.isLoadingMoreServices,
    this.serviceMaxPrice,
    this.serviceMinPrice,
    this.otherServices = const [],
  });

  final List<ServiceCategoryGroup> serviceCategories;
  final int totalServices;
  final Providers providerDetails;
  final bool isLoadingMoreServices;
  final double? serviceMaxPrice;
  final double? serviceMinPrice;
  final List<ServiceCategoryGroup> otherServices;

  int get loadedServicesCount =>
      serviceCategories.fold(0, (sum, group) => sum + group.services.length);

  ProviderDetailsAndServiceFetchSuccess copyWith({
    final List<ServiceCategoryGroup>? serviceCategories,
    final int? totalServices,
    final Providers? providerDetails,
    final bool? isLoadingMoreServices,
    final double? serviceMaxPrice,
    final double? serviceMinPrice,
    final List<ServiceCategoryGroup>? otherServices,
  }) => ProviderDetailsAndServiceFetchSuccess(
    providerDetails: providerDetails ?? this.providerDetails,
    isLoadingMoreServices: isLoadingMoreServices ?? this.isLoadingMoreServices,
    serviceCategories: serviceCategories ?? this.serviceCategories,
    totalServices: totalServices ?? this.totalServices,
    serviceMaxPrice: serviceMaxPrice ?? this.serviceMaxPrice,
    serviceMinPrice: serviceMinPrice ?? this.serviceMinPrice,
    otherServices: otherServices ?? this.otherServices,
  );
}

class ProviderDetailsAndServiceFetchFailure
    extends ProviderDetailsAndServiceState {
  ProviderDetailsAndServiceFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class MoreServiceFetchFailure extends ProviderDetailsAndServiceState {
  MoreServiceFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class ProviderDetailsAndServiceCubit
    extends Cubit<ProviderDetailsAndServiceState> {
  ProviderDetailsAndServiceCubit(
    this.serviceRepository,
    this.providerRepository,
  ) : super(ProviderDetailsAndServiceInitial());
  final ProviderRepository providerRepository;
  final ServiceRepository serviceRepository;

  ServiceFilterModel? _currentFilter;
  String? _currentCategoryId;
  String? _currentSearch;

  ServiceFilterModel? get currentFilter => _currentFilter;
  String? get currentCategoryId => _currentCategoryId;
  String? get currentSearch => _currentSearch;

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
          services: [...merged[existingIndex].services, ...incoming.services],
        );
      }
    }
    return merged;
  }

  Future<void> fetchProviderDetailsAndServices({
    final String? providerId,
    ProviderDetailsParamType type = ProviderDetailsParamType.id,
    ServiceFilterModel? filter,
    String? categoryId,
    String? search,
  }) async {
    _currentFilter = filter;
    _currentCategoryId = categoryId;
    _currentSearch = search;
    emit(ProviderDetailsAndServiceFetchInProgress());
    try {
      ProviderDetailsModel? providerData;
      Map<String, dynamic>? serviceData;

      final List<Future> futureAPIs = <Future>[
        //fetch provider data
        providerRepository
            .getProviderDetails(
              slug: type == ProviderDetailsParamType.slug ? providerId : null,
              partnerId: type == ProviderDetailsParamType.id
                  ? providerId
                  : null,
            )
            .then((final value) => providerData = value)
            .onError((final error, StackTrace stackTrace) {
              throw ApiException("somethingWentWrong");
            }),
        //service data
        serviceRepository
            .getServices(
              offset: "0",
              limit: UiUtils.limitOfAPIData,
              isAuthTokenRequired: HiveRepository.getUserToken == ''
                  ? false
                  : true,
              providerIdOrSlug: providerId ?? "0",
              type: type,
              search: _currentSearch,
              categoryIds: _currentCategoryId,
              sortBy: _currentFilter?.apiSortBy,
              ratingMin: _currentFilter?.apiRatingMin,
              priceMax: _currentFilter?.apiPriceMax,
              durationMin: _currentFilter?.apiDurationMin,
              durationMax: _currentFilter?.apiDurationMax,
              serviceMode: _currentFilter?.apiServiceMode,
              payLaterAllowed: _currentFilter?.apiPayLaterAllowed,
            )
            .then((final value) => serviceData = value)
            .onError((final error, final stackTrace) {
              serviceData = null;
              return <String, dynamic>{};
            }),
      ];

      await Future.wait(futureAPIs);

      if (providerData == null) {
        emit(
          ProviderDetailsAndServiceFetchFailure(
            errorMessage: "providerNotAvailableAtLocation",
          ),
        );
        return;
      }

      return emit(
        ProviderDetailsAndServiceFetchSuccess(
          isLoadingMoreServices: false,
          providerDetails: Providers.fromProviderDetails(providerData!),
          serviceCategories: serviceData?['serviceCategories'] ?? [],
          totalServices:
              int.tryParse(serviceData?['totalServices']?.toString() ?? "0") ??
              0,
          serviceMaxPrice: double.tryParse(
            serviceData?['serviceMaxPrice']?.toString() ?? "2000",
          ),
          serviceMinPrice: double.tryParse(
            serviceData?['serviceMinPrice']?.toString() ?? "0",
          ),
          otherServices: List<ServiceCategoryGroup>.from(
            serviceData?['otherServices'] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(ProviderDetailsAndServiceFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchFilteredServices({
    required final String providerId,
    ProviderDetailsParamType type = ProviderDetailsParamType.id,
    ServiceFilterModel? filter,
    String? categoryId,
    String? search,
  }) async {
    try {
      if (state is! ProviderDetailsAndServiceFetchSuccess) return;
      final ProviderDetailsAndServiceFetchSuccess currentState =
          state as ProviderDetailsAndServiceFetchSuccess;

      _currentFilter = filter;
      if (categoryId != null) _currentCategoryId = categoryId;
      if (search != null) _currentSearch = search;

      emit(currentState.copyWith(isLoadingMoreServices: true));

      final Map<String, dynamic> serviceData = await serviceRepository
          .getServices(
            offset: "0",
            limit: UiUtils.limitOfAPIData,
            isAuthTokenRequired: HiveRepository.getUserToken == ''
                ? false
                : true,
            providerIdOrSlug: providerId,
            type: type,
            search: _currentSearch,
            categoryIds: _currentCategoryId,
            sortBy: _currentFilter?.apiSortBy,
            ratingMin: _currentFilter?.apiRatingMin,
            priceMax: _currentFilter?.apiPriceMax,
            durationMin: _currentFilter?.apiDurationMin,
            durationMax: _currentFilter?.apiDurationMax,
            serviceMode: _currentFilter?.apiServiceMode,
            payLaterAllowed: _currentFilter?.apiPayLaterAllowed,
          );

      emit(
        currentState.copyWith(
          isLoadingMoreServices: false,
          serviceCategories: List<ServiceCategoryGroup>.from(
            serviceData['serviceCategories'] ?? [],
          ),
          totalServices:
              int.tryParse(serviceData['totalServices']?.toString() ?? "0") ??
              0,
          serviceMaxPrice: double.tryParse(
            serviceData['serviceMaxPrice']?.toString() ??
                currentState.serviceMaxPrice?.toString() ??
                "2000",
          ),
          serviceMinPrice: double.tryParse(
            serviceData['serviceMinPrice']?.toString() ??
                currentState.serviceMinPrice?.toString() ??
                "0",
          ),
          otherServices: List<ServiceCategoryGroup>.from(
            serviceData['otherServices'] ?? [],
          ),
        ),
      );
    } catch (e) {
      if (state is ProviderDetailsAndServiceFetchSuccess) {
        emit(
          (state as ProviderDetailsAndServiceFetchSuccess).copyWith(
            isLoadingMoreServices: false,
            serviceCategories: const [],
            totalServices: 0,
          ),
        );
      }
    }
  }

  Future<void> fetchMoreServices({
    final String? providerId,
    ProviderDetailsParamType type = ProviderDetailsParamType.id,
  }) async {
    try {
      if (state is ProviderDetailsAndServiceFetchSuccess) {
        if ((state as ProviderDetailsAndServiceFetchSuccess)
            .isLoadingMoreServices) {
          return;
        }
      }

      final ProviderDetailsAndServiceFetchSuccess currentState =
          state as ProviderDetailsAndServiceFetchSuccess;

      emit(currentState.copyWith(isLoadingMoreServices: true));

      final Map<String, dynamic> moreServicesData = await serviceRepository
          .getServices(
            offset: currentState.loadedServicesCount.toString(),
            limit: UiUtils.limitOfAPIData,
            isAuthTokenRequired: HiveRepository.getUserToken == ''
                ? false
                : true,
            providerIdOrSlug: providerId!,
            type: type,
            search: _currentSearch,
            categoryIds: _currentCategoryId,
            sortBy: _currentFilter?.apiSortBy,
            ratingMin: _currentFilter?.apiRatingMin,
            priceMax: _currentFilter?.apiPriceMax,
            durationMin: _currentFilter?.apiDurationMin,
            durationMax: _currentFilter?.apiDurationMax,
            serviceMode: _currentFilter?.apiServiceMode,
            payLaterAllowed: _currentFilter?.apiPayLaterAllowed,
          );

      return emit(
        currentState.copyWith(
          isLoadingMoreServices: false,
          serviceCategories: _mergeServiceCategories(
            currentState.serviceCategories,
            List<ServiceCategoryGroup>.from(
              moreServicesData['serviceCategories'] ?? [],
            ),
          ),
        ),
      );
    } catch (e) {
      emit(MoreServiceFetchFailure(errorMessage: e.toString()));
    }
  }

  bool hasMoreServices() {
    if (state is ProviderDetailsAndServiceFetchSuccess) {
      final ProviderDetailsAndServiceFetchSuccess currentState =
          state as ProviderDetailsAndServiceFetchSuccess;
      return currentState.loadedServicesCount < currentState.totalServices;
    }
    return false;
  }

  String getProviderId() {
    if (state is ProviderDetailsAndServiceFetchSuccess) {
      return (state as ProviderDetailsAndServiceFetchSuccess).providerDetails.id
          .toString();
    }
    return "0";
  }
}
