import 'package:equatable/equatable.dart';
import '../../../domain/entities/prompt.dart';

abstract class PromptState extends Equatable {
  const PromptState();

  @override
  List<Object> get props => [];
}

class PromptInitial extends PromptState {}

class PromptLoading extends PromptState {}

class PromptLoaded extends PromptState {
  final Prompt prompt;

  const PromptLoaded(this.prompt);

  @override
  List<Object> get props => [prompt];
}

class PromptError extends PromptState {
  final String message;

  const PromptError(this.message);

  @override
  List<Object> get props => [message];
}

class PromptUpdated extends PromptState {}
