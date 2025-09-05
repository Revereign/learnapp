class EditChildProfileState {
  final String name;
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  EditChildProfileState({
    required this.name,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  EditChildProfileState copyWith({
    String? name,
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return EditChildProfileState(
      name: name ?? this.name,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
    );
  }

  factory EditChildProfileState.initial() => EditChildProfileState(name: '');
}
