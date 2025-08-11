import '../../entities/quiz_question.dart';
import '../../repositories/quiz_repository.dart';

class LoadAllQuestions {
  final QuizRepository repository;

  LoadAllQuestions(this.repository);

  Future<List<QuizQuestionEntity>> call() async {
    return await repository.getAllQuestions();
  }
}
