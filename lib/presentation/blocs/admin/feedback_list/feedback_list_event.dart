import 'package:equatable/equatable.dart';

abstract class FeedbackListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFeedbacks extends FeedbackListEvent {}

class MarkAsRead extends FeedbackListEvent {
  final String feedbackId;

  MarkAsRead(this.feedbackId);

  @override
  List<Object?> get props => [feedbackId];
}
