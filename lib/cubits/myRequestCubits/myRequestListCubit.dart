import 'package:e_demand/app/generalImports.dart';

abstract class MyRequestListState {}

class MyRequestListInitial extends MyRequestListState {}

class MyRequestListInProgress extends MyRequestListState {}

class MyRequestListSuccess extends MyRequestListState {
  MyRequestListSuccess({
    required this.totalReqCount,
    required this.isLoadingMoreReq,
    required this.isLoadingMoreError,
    required this.requestList,
    this.status,
  });

  final List<MyRequestListModel> requestList;
  final int totalReqCount;
  final bool isLoadingMoreReq;
  final bool isLoadingMoreError;
  // The active status filter this list was fetched with — fetchMoreReq
  // needs it so pagination stays within the same filter instead of
  // silently falling back to the unfiltered list.
  final String? status;

  MyRequestListSuccess copyWith({
    final List<MyRequestListModel>? requestList,
    final int? totalReqCount,
    final bool? isLoadingMoreReq,
    final bool? isLoadingMoreError,
    final String? status,
  }) => MyRequestListSuccess(
    isLoadingMoreReq: isLoadingMoreReq ?? this.isLoadingMoreReq,
    isLoadingMoreError: isLoadingMoreError ?? this.isLoadingMoreError,
    totalReqCount: totalReqCount ?? this.totalReqCount,
    requestList: requestList ?? this.requestList,
    status: status ?? this.status,
  );
}

class MyRequestListFailure extends MyRequestListState {
  MyRequestListFailure({required this.errorMessage});

  final String errorMessage;
}

class MyRequestListCubit extends Cubit<MyRequestListState> {
  MyRequestListCubit() : super(MyRequestListInitial());

  Future<void> fetchRequests({String? status}) async {
    final MyRequestRepository myRequestRepository = MyRequestRepository();
    try {
      emit(MyRequestListInProgress());
      final data = await myRequestRepository.fetchMyCustomJobRequests(
        status: status,
      );
      emit(
        MyRequestListSuccess(
          isLoadingMoreReq: false,
          isLoadingMoreError: false,
          requestList: data['data'],
          totalReqCount: data['total'],
          status: status,
        ),
      );
    } catch (e) {
      emit(MyRequestListFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMoreReq() async {
    if (state is MyRequestListSuccess) {
      if ((state as MyRequestListSuccess).isLoadingMoreReq) {
        return;
      }
    }

    final MyRequestListSuccess currentState = state as MyRequestListSuccess;
    emit(
      currentState.copyWith(
        totalReqCount: currentState.totalReqCount,
        requestList: currentState.requestList,
        isLoadingMoreReq: true,
        isLoadingMoreError: false,
      ),
    );

    final myRequestRepository = MyRequestRepository();

    await myRequestRepository
        .fetchMyCustomJobRequests(
          status: currentState.status,
          limit: UiUtils.limitOfAPIData,
          offset: (state as MyRequestListSuccess).requestList.length,
        )
        .then((final value) {
          final List<MyRequestListModel> oldList = currentState.requestList;

          oldList.addAll(value['data']);

          emit(
            MyRequestListSuccess(
              isLoadingMoreError: false,
              isLoadingMoreReq: false,
              requestList: oldList,
              totalReqCount: value['total'],
              status: currentState.status,
            ),
          );
        })
        .catchError((final e) {
          emit(
            MyRequestListSuccess(
              isLoadingMoreError: true,
              isLoadingMoreReq: false,
              requestList: currentState.requestList,
              totalReqCount: currentState.totalReqCount,
              status: currentState.status,
            ),
          );
        });
  }

  bool hasMoreReq() {
    if (state is MyRequestListSuccess) {
      return (state as MyRequestListSuccess).requestList.length <
          (state as MyRequestListSuccess).totalReqCount;
    }
    return false;
  }

  void updateRequestStatusLocally({
    required String requestId,
    required String status,
  }) {
    if (state is! MyRequestListSuccess) return;
    final currentState = state as MyRequestListSuccess;
    final updatedList = currentState.requestList.map((req) {
      if (req.id == requestId) {
        req.status = status;
      }
      return req;
    }).toList();
    emit(currentState.copyWith(requestList: updatedList));
  }
}
