import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/materi.dart';
import '../../../domain/usecases/materi/get_materi_by_level.dart';
import 'vocabulary_event.dart';
import 'vocabulary_state.dart';

class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final GetMateriByLevel getMateriByLevel;

  VocabularyBloc({required this.getMateriByLevel}) : super(VocabularyInitial()) {
    on<LoadVocabulary>(_onLoadVocabulary);
  }

  Future<void> _onLoadVocabulary(
    LoadVocabulary event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(VocabularyLoading());
    
    try {
      final materiList = await getMateriByLevel(event.level);
      emit(VocabularyLoaded(materiList));
    } catch (e) {
      emit(VocabularyError(e.toString()));
    }
  }
} 