import 'package:e_demand/app/generalImports.dart';

abstract class GetChatQuestionsState {}

class GetChatQuestionsInitial extends GetChatQuestionsState {}

class GetChatQuestionsInProgress extends GetChatQuestionsState {}

class GetChatQuestionsSuccess extends GetChatQuestionsState {
  final List<ChatQuestion> questions;

  GetChatQuestionsSuccess({required this.questions});
}

class GetChatQuestionsFailure extends GetChatQuestionsState {
  final String errorMessage;

  GetChatQuestionsFailure({required this.errorMessage});
}

class GetChatQuestionsCubit extends Cubit<GetChatQuestionsState> {
  final ChatRepository chatRepository;

  GetChatQuestionsCubit(this.chatRepository) : super(GetChatQuestionsInitial());

  Future<void> fetchChatQuestions({required String type}) async {
    emit(GetChatQuestionsInProgress());
    try {
      final List<ChatQuestion> questions =
          await chatRepository.fetchChatQuestions(type: type);
      emit(GetChatQuestionsSuccess(questions: questions));
    } catch (e) {
      emit(GetChatQuestionsFailure(errorMessage: e.toString()));
    }
  }
}
