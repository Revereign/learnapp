import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FirebaseFirestore firestore;

  FeedbackBloc({
    required this.firestore,
  }) : super(FeedbackState.initial()) {
    on<FeedbackTextChanged>((event, emit) => emit(state.copyWith(feedback: event.feedback)));
    on<SubmitFeedback>(_onSubmitFeedback);
  }

  Future<void> _onSubmitFeedback(SubmitFeedback event, Emitter<FeedbackState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simpan feedback ke Firestore
      await firestore.collection('feedbacks').add({
        'feedback': state.feedback,
        'parentUid': event.parentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(
        isLoading: false,
        success: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengirim feedback: ${e.toString()}',
      ));
    }
  }
}
