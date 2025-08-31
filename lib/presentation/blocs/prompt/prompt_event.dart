import 'package:equatable/equatable.dart';
import '../../../domain/entities/prompt.dart';

abstract class PromptEvent extends Equatable {
  const PromptEvent();

  @override
  List<Object> get props => [];
}

class GetPromptEvent extends PromptEvent {}

class UpdatePromptEvent extends PromptEvent {
  final Prompt prompt;

  const UpdatePromptEvent(this.prompt);

  @override
  List<Object> get props => [prompt];
}
