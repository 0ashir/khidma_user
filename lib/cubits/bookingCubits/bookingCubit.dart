import 'package:e_demand/app/generalImports.dart';

//State
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingFetchInProgress extends BookingState {}

class BookingFetchSuccess extends BookingState {
  BookingFetchSuccess({required this.buckets});

  final BookingBuckets buckets;
}

class BookingFetchFailure extends BookingState {
  BookingFetchFailure({required this.errorMessage});

  final String errorMessage;
}

//cubit
class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this.bookingRepository) : super(BookingInitial());
  final BookingRepository bookingRepository;

  ///This method is used to fetch the bucketed booking list
  Future<void> fetchAllBookings({
    final String? status,
    final String? customRequestOrder,
  }) async {
    try {
      emit(BookingFetchInProgress());

      final buckets = await bookingRepository.fetchAllBookings(
        status: status,
        customRequestOrder: customRequestOrder,
      );

      emit(BookingFetchSuccess(buckets: buckets));
    } catch (e) {
      emit(BookingFetchFailure(errorMessage: e.toString()));
    }
  }
}
