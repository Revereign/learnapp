import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_question.dart';

abstract class ManageQuizState extends Equatable {
  const ManageQuizState();

  @override
  List<Object?> get props => [];
}

class ManageQuizInitial extends ManageQuizState {}

class ManageQuizLoading extends ManageQuizState {}

class ManageQuizLoaded extends ManageQuizState {
  final List<QuizQuestionEntity> questions;

  const ManageQuizLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class ManageQuizError extends ManageQuizState {
  final String message;

  const ManageQuizError(this.message);

  @override
  List<Object?> get props => [message];
}

class ManageQuizGenerated extends ManageQuizState {
  final List<QuizQuestionEntity> generatedQuestions;

  const ManageQuizGenerated(this.generatedQuestions);

  @override
  List<Object?> get props => [generatedQuestions];
}
