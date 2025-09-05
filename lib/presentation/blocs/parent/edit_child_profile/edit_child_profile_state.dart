class EditChildProfileState {
  final String name;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  EditChildProfileState({
    required this.name,
    required this.password,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  EditChildProfileState copyWith({
    String? name,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return EditChildProfileState(
      name: name ?? this.name,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
    );
  }

  factory EditChildProfileState.initial() => EditChildProfileState(name: '', password: '');
}
