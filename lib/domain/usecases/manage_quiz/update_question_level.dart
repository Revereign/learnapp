import '../../repositories/quiz_repository.dart';

class UpdateQuestionLevel {
  final QuizRepository repository;

  UpdateQuestionLevel(this.repository);

  Future<void> call(String id, int level) async {
    await repository.updateQuestionLevel(id, level);
  }
}
