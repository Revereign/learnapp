import '../../entities/quiz_question.dart';
import '../../repositories/quiz_repository.dart';

class SaveQuestion {
  final QuizRepository repository;

  SaveQuestion(this.repository);

  Future<void> call(QuizQuestionEntity question) async {
    await repository.saveQuestion(question);
  }
}
