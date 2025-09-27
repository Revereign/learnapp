import 'dart:io';

abstract class EditProfileEvent {}

class LoadUserProfile extends EditProfileEvent {}

class NameChanged extends EditProfileEvent {
  final String name;
  NameChanged(this.name);
}

class PasswordChanged extends EditProfileEvent {
  final String password;
  PasswordChanged(this.password);
}

class SubmitProfileChanges extends EditProfileEvent {}
