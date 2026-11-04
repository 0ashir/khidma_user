//Cubit
import 'package:e_demand/app/generalImports.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this.categoryRepository) : super(CategoryInitial());
  CategoryRepository categoryRepository;

  static final int _limit = int.parse("20");
  bool _hasMore = true;
  String? _search;

  Future<void> getCategory({final String? search}) async {
    _search = search;
    emit(CategoryFetchInProgress());

    try {
      final List<CategoryModel> categoryList = await categoryRepository
          .fetchCategory(limitOfAPIData: _limit, offset: 0, search: _search);
      _hasMore = categoryList.length >= _limit;
      emit(CategoryFetchSuccess(categoryList: categoryList));
    } catch (e) {
      emit(CategoryFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMoreCategory() async {
    if (state is! CategoryFetchSuccess) return;
    final CategoryFetchSuccess currentState = state as CategoryFetchSuccess;
    if (currentState.isLoadingMore || !_hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final List<CategoryModel> moreCategories = await categoryRepository
          .fetchCategory(
            limitOfAPIData: _limit,
            offset: currentState.categoryList.length,
            search: _search,
          );
      _hasMore = moreCategories.length >= _limit;
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          categoryList: [...currentState.categoryList, ...moreCategories],
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  bool hasMoreCategory() => _hasMore;
}

//State
@immutable
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryFetchInProgress extends CategoryState {}

class CategoryFetchSuccess extends CategoryState {
  CategoryFetchSuccess({
    required this.categoryList,
    this.isLoadingMore = false,
  });

  final List<CategoryModel> categoryList;
  final bool isLoadingMore;

  CategoryFetchSuccess copyWith({
    final List<CategoryModel>? categoryList,
    final bool? isLoadingMore,
  }) => CategoryFetchSuccess(
    categoryList: categoryList ?? this.categoryList,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class CategoryFetchFailure extends CategoryState {
  CategoryFetchFailure({required this.errorMessage});

  final String errorMessage;
}
