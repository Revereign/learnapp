import 'dart:io';

class EditProfileState {
  final String name;
  final String password;
  final File? image;
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  EditProfileState({
    required this.name,
    required this.password,
    this.image,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  EditProfileState copyWith({
    String? name,
    String? password,
    File? image,
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      password: password ?? this.password,
      image: image ?? this.image,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
    );
  }

  factory EditProfileState.initial() => EditProfileState(name: '', password: '');
}
