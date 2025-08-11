import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_question.dart';

abstract class ManageQuizEvent extends Equatable {
  const ManageQuizEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllQuestionsEvent extends ManageQuizEvent {}

class SaveGeneratedQuestionEvent extends ManageQuizEvent {
  final QuizQuestionEntity question;

  const SaveGeneratedQuestionEvent(this.question);

  @override
  List<Object?> get props => [question];
}

class UpdateQuestionLevelEvent extends ManageQuizEvent {
  final String id;
  final int level;

  const UpdateQuestionLevelEvent({required this.id, required this.level});

  @override
  List<Object?> get props => [id, level];
}

class DeleteQuestionEvent extends ManageQuizEvent {
  final String id;

  const DeleteQuestionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GenerateQuestionsFromPromptEvent extends ManageQuizEvent {
  final String prompt;

  const GenerateQuestionsFromPromptEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

