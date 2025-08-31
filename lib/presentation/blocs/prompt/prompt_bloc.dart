import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/prompt.dart';
import '../../../domain/usecases/prompt/get_prompt.dart';
import '../../../domain/usecases/prompt/update_prompt.dart';
import '../../../domain/usecases/usecase.dart';
import 'prompt_event.dart';
import 'prompt_state.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  final GetPrompt getPrompt;
  final UpdatePrompt updatePrompt;

  PromptBloc({
    required this.getPrompt,
    required this.updatePrompt,
  }) : super(PromptInitial()) {
    on<GetPromptEvent>(_onGetPrompt);
    on<UpdatePromptEvent>(_onUpdatePrompt);
  }

  Future<void> _onGetPrompt(
      GetPromptEvent event, Emitter<PromptState> emit) async {
    emit(PromptLoading());
    try {
      final result = await getPrompt(NoParams());
      emit(PromptLoaded(result));
    } catch (e) {
      emit(PromptError(e.toString()));
    }
  }

  Future<void> _onUpdatePrompt(
      UpdatePromptEvent event, Emitter<PromptState> emit) async {
    emit(PromptLoading());
    try {
      await updatePrompt(event.prompt);
      emit(PromptUpdated());
      add(GetPromptEvent()); // Refresh data
    } catch (e) {
      emit(PromptError(e.toString()));
    }
  }
}
