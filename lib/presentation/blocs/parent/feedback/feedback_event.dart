import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackTextChanged extends FeedbackEvent {
  final String feedback;

  FeedbackTextChanged(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class SubmitFeedback extends FeedbackEvent {
  final String parentUid;

  SubmitFeedback(this.parentUid);

  @override
  List<Object?> get props => [parentUid];
}
