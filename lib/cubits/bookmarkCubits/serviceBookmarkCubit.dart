import 'package:e_demand/app/generalImports.dart';

abstract class ServiceBookmarkState {}

class ServiceBookmarkInitial extends ServiceBookmarkState {}

class ServiceBookmarkFetchInProgress extends ServiceBookmarkState {}

class ServiceBookmarkFetchSuccess extends ServiceBookmarkState {
  ServiceBookmarkFetchSuccess({
    required this.isLoadingMoreData,
    required this.isLoadingMoreError,
    required this.loadMoreError,
    required this.bookmarkList,
    required this.totalBookmark,
  });

  final List<Services> bookmarkList;
  final int totalBookmark;
  final bool isLoadingMoreData;
  final bool isLoadingMoreError;
  final String loadMoreError;

  ServiceBookmarkFetchSuccess copyWith({
    required final int totalBookmark,
    required final List<Services> bookmarkList,
    required final bool isLoadingMoreData,
    required final bool isLoadingMoreError,
    required final String loadMoreError,
  }) => ServiceBookmarkFetchSuccess(
    isLoadingMoreData: isLoadingMoreData,
    isLoadingMoreError: isLoadingMoreError,
    loadMoreError: loadMoreError,
    bookmarkList: bookmarkList,
    totalBookmark: totalBookmark,
  );
}

class ServiceBookmarkFetchFailure extends ServiceBookmarkState {
  ServiceBookmarkFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class ServiceBookmarkCubit extends Cubit<ServiceBookmarkState> {
  ServiceBookmarkCubit(this.bookmarkRepository)
    : super(ServiceBookmarkInitial());
  final BookmarkRepository bookmarkRepository;

  Future<void> fetchServiceBookmark() async {
    emit(ServiceBookmarkFetchInProgress());

    final Map<String, dynamic> parameter = <String, dynamic>{
      ApiParam.type: 'list',
      ApiParam.bookmarkType: 'service',
      ApiParam.limit: UiUtils.limitOfAPIData,
      ApiParam.offset: "0",
      ApiParam.longitude: HiveRepository.getLongitude,
      ApiParam.latitude: HiveRepository.getLatitude,
    };

    await bookmarkRepository
        .getBookmark(
          isAuthTokenRequired: true,
          parameter: parameter,
          bookmarkType: 'service',
        )
        .then((final value) {
          emit(
            ServiceBookmarkFetchSuccess(
              isLoadingMoreError: false,
              isLoadingMoreData: false,
              loadMoreError: '',
              bookmarkList: value['bookmark'],
              totalBookmark: int.parse(value['totalBookmark']),
            ),
          );
        })
        .catchError((final e, st) {
          emit(ServiceBookmarkFetchFailure(errorMessage: e.toString()));
        });
  }

  bool hasMoreBookMark() {
    if (state is ServiceBookmarkFetchSuccess) {
      final bool hasMoreData =
          (state as ServiceBookmarkFetchSuccess).bookmarkList.length <
          (state as ServiceBookmarkFetchSuccess).totalBookmark;

      return hasMoreData;
    }
    return false;
  }

  Future<void> fetchMoreServiceBookmark() async {
    if (state is ServiceBookmarkFetchSuccess) {
      if ((state as ServiceBookmarkFetchSuccess).isLoadingMoreData) {
        return;
      }
    }

    final ServiceBookmarkFetchSuccess currentState =
        state as ServiceBookmarkFetchSuccess;

    final Map<String, dynamic> parameter = <String, dynamic>{
      ApiParam.type: 'list',
      ApiParam.bookmarkType: 'service',
      ApiParam.limit: UiUtils.limitOfAPIData,
      ApiParam.offset: currentState.bookmarkList.length,
      ApiParam.longitude: HiveRepository.getLongitude,
      ApiParam.latitude: HiveRepository.getLatitude,
    };

    emit(
      currentState.copyWith(
        totalBookmark: currentState.totalBookmark,
        bookmarkList: currentState.bookmarkList,
        isLoadingMoreData: true,
        isLoadingMoreError: false,
        loadMoreError: '',
      ),
    );

    await bookmarkRepository
        .getBookmark(
          isAuthTokenRequired: true,
          parameter: parameter,
          bookmarkType: 'service',
        )
        .then((final value) {
          final oldList = currentState.bookmarkList;

          oldList.addAll(value['bookmark']);

          emit(
            ServiceBookmarkFetchSuccess(
              isLoadingMoreData: false,
              isLoadingMoreError: false,
              loadMoreError: '',
              bookmarkList: oldList,
              totalBookmark: int.parse(value['totalBookmark'].toString()),
            ),
          );
        })
        .catchError((final e) {
          emit(
            ServiceBookmarkFetchSuccess(
              isLoadingMoreData: false,
              isLoadingMoreError: true,
              loadMoreError: e.toString(),
              bookmarkList: currentState.bookmarkList,
              totalBookmark: currentState.totalBookmark,
            ),
          );
        });
  }

  void removeBookmark(final String id) {
    if (state is ServiceBookmarkFetchSuccess) {
      final bookmarkedServices =
          (state as ServiceBookmarkFetchSuccess).bookmarkList;
      bookmarkedServices.removeWhere((final element) => element.id == id);
      emit(
        ServiceBookmarkFetchSuccess(
          isLoadingMoreData: false,
          isLoadingMoreError: false,
          loadMoreError: '',
          bookmarkList: bookmarkedServices,
          totalBookmark: (state as ServiceBookmarkFetchSuccess).totalBookmark,
        ),
      );
    }
  }

  void clearServiceBookmarkCubit() {
    emit(
      ServiceBookmarkFetchSuccess(
        bookmarkList: [],
        isLoadingMoreData: false,
        isLoadingMoreError: false,
        loadMoreError: '',
        totalBookmark: 0,
      ),
    );
  }
}
