import 'dart:io';

class EditProfileState {
  final String name;
  final String password;
  final File? image;
  final bool isLoading;
  final String? errorMessage;
  final bool success;
  final String? photoUrl;

  EditProfileState({
    required this.name,
    required this.password,
    this.image,
    this.photoUrl, // <- tambahkan ini
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  EditProfileState copyWith({
    String? name,
    String? password,
    File? image,
    String? photoUrl, // <- tambahkan ini
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      password: password ?? this.password,
      image: image ?? this.image,
      photoUrl: photoUrl ?? this.photoUrl, // <- tambahkan ini
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
    );
  }

  factory EditProfileState.initial() => EditProfileState(name: '', password: '');
}
