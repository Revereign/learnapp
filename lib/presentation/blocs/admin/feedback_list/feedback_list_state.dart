import 'package:equatable/equatable.dart';

class FeedbackItem {
  final String id;
  final String parentUid;
  final String feedback;
  final DateTime createdAt;

  FeedbackItem({
    required this.id,
    required this.parentUid,
    required this.feedback,
    required this.createdAt,
  });

  factory FeedbackItem.fromMap(String id, Map<String, dynamic> data) {
    return FeedbackItem(
      id: id,
      parentUid: data['parentUid'] ?? '',
      feedback: data['feedback'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class FeedbackListState extends Equatable {
  final List<FeedbackItem> feedbacks;
  final bool isLoading;
  final String? errorMessage;
  final bool isDeleting;

  FeedbackListState({
    required this.feedbacks,
    this.isLoading = false,
    this.errorMessage,
    this.isDeleting = false,
  });

  FeedbackListState copyWith({
    List<FeedbackItem>? feedbacks,
    bool? isLoading,
    String? errorMessage,
    bool? isDeleting,
  }) {
    return FeedbackListState(
      feedbacks: feedbacks ?? this.feedbacks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  factory FeedbackListState.initial() => FeedbackListState(feedbacks: []);

  @override
  List<Object?> get props => [feedbacks, isLoading, errorMessage, isDeleting];
}
