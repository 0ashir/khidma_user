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

  ///This method is used to fetch subCategories and Providers based on CategoryId/SubCategory Id
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
    emit(SubCategoryAndProviderFetchInProgress());

    final List<SubCategory> subCategoryList;
    try {
      final subCategoryData = await subCategoryRepository.fetchSubCategory(
        categoryID: subCategoryID ?? categoryID ?? '',
        isAuthTokenRequired: false,
      );
      subCategoryList = subCategoryData['subCategoryList'];
    } catch (error) {
      if (isClosed) return;
      emit(SubCategoryAndProviderFetchFailure(errorMessage: error.toString()));
      return;
    }

    // Providers are fetched separately so that a category with subcategories
    // but no providers of its own (backend throws on zero results) still
    // shows its subcategories instead of losing them to this failure.
    try {
      final providersData = await providerRepository.fetchProviderList(
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
      );
      if (isClosed) return;
      emit(
        SubCategoryAndProviderFetchSuccess(
          subCategoryList: subCategoryList,
          providerList: providersData['providerList'],
          totalProviders: providersData['totalProviders'],
          serviceMinPrice: providersData['serviceMinPrice'],
          serviceMaxPrice: providersData['serviceMaxPrice'],
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        SubCategoryAndProviderFetchSuccess(
          subCategoryList: subCategoryList,
          providerList: const [],
          totalProviders: '0',
        ),
      );
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

    emit(SubCategoryAndProviderFetchInProgress());
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
      );
      if (isClosed) return;
      emit(
        SubCategoryAndProviderFetchSuccess(
          subCategoryList: currentState.subCategoryList,
          providerList: providersData['providerList'],
          totalProviders: providersData['totalProviders'],
          serviceMinPrice: providersData['serviceMinPrice'],
          serviceMaxPrice: providersData['serviceMaxPrice'],
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        SubCategoryAndProviderFetchSuccess(
          subCategoryList: currentState.subCategoryList,
          providerList: const [],
          totalProviders: '0',
        ),
      );
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
