import 'package:equatable/equatable.dart';

class FeedbackState extends Equatable {
  final String feedback;
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  FeedbackState({
    required this.feedback,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  FeedbackState copyWith({
    String? feedback,
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return FeedbackState(
      feedback: feedback ?? this.feedback,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
    );
  }

  factory FeedbackState.initial() => FeedbackState(feedback: '');

  @override
  List<Object?> get props => [feedback, isLoading, errorMessage, success];
}
