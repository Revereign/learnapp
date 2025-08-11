import '../../../data/services/gemini_service.dart';
import '../../entities/quiz_question.dart';

class GenerateQuestionsFromPrompt {
  final GeminiService service;

  GenerateQuestionsFromPrompt(this.service);

  Future<List<QuizQuestionEntity>> call(String prompt) async {
    return await service.generateQuestions(prompt);
  }
}