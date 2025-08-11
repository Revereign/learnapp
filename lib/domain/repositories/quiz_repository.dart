import '../entities/quiz_question.dart';

abstract class QuizRepository {
  Future<List<QuizQuestionEntity>> getAllQuestions();
  Future<void> saveQuestion(QuizQuestionEntity question);
  Future<void> updateQuestionLevel(String id, int level);
  Future<void> deleteQuestion(String id);
}
