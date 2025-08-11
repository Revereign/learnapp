import 'package:flutter_bloc/flutter_bloc.dart';
import 'manage_quiz_event.dart';
import 'manage_quiz_state.dart';

import '../../../domain/usecases/manage_quiz/load_all_questions.dart';
import '../../../domain/usecases/manage_quiz/save_question.dart';
import '../../../domain/usecases/manage_quiz/update_question_level.dart';
import '../../../domain/usecases/manage_quiz/delete_question.dart';
import '../../../domain/usecases/manage_quiz/generate_questions_from_prompt.dart';
import '../../../domain/entities/quiz_question.dart';

class ManageQuizBloc extends Bloc<ManageQuizEvent, ManageQuizState> {
  final LoadAllQuestions loadAllQuestions;
  final SaveQuestion saveQuestion;
  final UpdateQuestionLevel updateQuestionLevel;
  final DeleteQuestion deleteQuestion;
  final GenerateQuestionsFromPrompt generateQuestionsFromPrompt;

  ManageQuizBloc({
    required this.loadAllQuestions,
    required this.saveQuestion,
    required this.updateQuestionLevel,
    required this.deleteQuestion,
    required this.generateQuestionsFromPrompt,
  }) : super(ManageQuizInitial()) {
    on<LoadAllQuestionsEvent>(_onLoadAllQuestions);
    on<SaveGeneratedQuestionEvent>(_onSaveQuestion);
    on<UpdateQuestionLevelEvent>(_onUpdateLevel);
    on<DeleteQuestionEvent>(_onDeleteQuestion);
    on<GenerateQuestionsFromPromptEvent>(_onGenerateFromPrompt);
  }

  Future<void> _onLoadAllQuestions(
      LoadAllQuestionsEvent event, Emitter<ManageQuizState> emit) async {
    emit(ManageQuizLoading());
    try {
      final questions = await loadAllQuestions();
      emit(ManageQuizLoaded(questions));
    } catch (e) {
      emit(ManageQuizError("Gagal memuat soal"));
    }
  }

  Future<void> _onSaveQuestion(
      SaveGeneratedQuestionEvent event, Emitter<ManageQuizState> emit) async {
    try {
      await saveQuestion(event.question);
    } catch (e) {
      emit(ManageQuizError("Gagal menyimpan soal"));
    }
  }

  Future<void> _onUpdateLevel(
      UpdateQuestionLevelEvent event, Emitter<ManageQuizState> emit) async {
    try {
      await updateQuestionLevel(event.id, event.level);
      add(LoadAllQuestionsEvent());
    } catch (e) {
      emit(ManageQuizError("Gagal memperbarui level soal"));
    }
  }

  Future<void> _onDeleteQuestion(
      DeleteQuestionEvent event, Emitter<ManageQuizState> emit) async {
    try {
      await deleteQuestion(event.id);
      add(LoadAllQuestionsEvent());
    } catch (e) {
      emit(ManageQuizError("Gagal menghapus soal"));
    }
  }

  Future<void> _onGenerateFromPrompt(
      GenerateQuestionsFromPromptEvent event, Emitter<ManageQuizState> emit) async {
    emit(ManageQuizLoading());
    try {
      final generated = await generateQuestionsFromPrompt(event.prompt);
      emit(ManageQuizGenerated(generated));
    } catch (e) {
      emit(ManageQuizError("Gagal generate soal: ${e.toString()}"));
    }
  }
}
