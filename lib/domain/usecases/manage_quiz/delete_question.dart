import '../../repositories/quiz_repository.dart';

class DeleteQuestion {
  final QuizRepository repository;

  DeleteQuestion(this.repository);

  Future<void> call(String id) async {
    await repository.deleteQuestion(id);
  }
}
