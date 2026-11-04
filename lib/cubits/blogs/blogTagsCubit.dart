import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/baseState.dart';
import 'package:e_demand/data/repository/blogsRepository.dart';
import 'package:e_demand/data/model/blogs/blogModel.dart';

class BlogTagsCubit extends Cubit<BaseState> {
  BlogTagsCubit(this._blogsRepository) : super(InitialState());
  final BlogsRepository _blogsRepository;

  Future<void> getBlogTags() async {
    try {
      emit(LoadingState(loading: true));

      final response = await _blogsRepository.getBlogTags();

      if (response['error']) {
        emit(FailureState(response['message']));
      } else {
        emit(
          SuccessState<List<BlogTag>>(
            data: response['tags'] as List<BlogTag>,
            error: response['error'],
            message: response['message'],
            total: response['totalTags'] ?? 0,
          ),
        );
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }
}
