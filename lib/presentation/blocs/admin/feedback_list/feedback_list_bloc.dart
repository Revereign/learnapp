import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'feedback_list_event.dart';
import 'feedback_list_state.dart';

class FeedbackListBloc extends Bloc<FeedbackListEvent, FeedbackListState> {
  final FirebaseFirestore firestore;

  FeedbackListBloc({
    required this.firestore,
  }) : super(FeedbackListState.initial()) {
    on<LoadFeedbacks>(_onLoadFeedbacks);
    on<MarkAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadFeedbacks(LoadFeedbacks event, Emitter<FeedbackListState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final snapshot = await firestore
          .collection('feedbacks')
          .orderBy('createdAt', descending: true)
          .get();

      final feedbacks = snapshot.docs
          .map((doc) => FeedbackItem.fromMap(doc.id, doc.data()))
          .toList();

      emit(state.copyWith(
        feedbacks: feedbacks,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat feedback: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<FeedbackListState> emit) async {
    emit(state.copyWith(isDeleting: true));

    try {
      await firestore.collection('feedbacks').doc(event.feedbackId).delete();

      // Remove from local state
      final updatedFeedbacks = state.feedbacks
          .where((feedback) => feedback.id != event.feedbackId)
          .toList();

      emit(state.copyWith(
        feedbacks: updatedFeedbacks,
        isDeleting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: 'Gagal menghapus feedback: ${e.toString()}',
      ));
    }
  }
}
