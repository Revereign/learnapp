import '../../../domain/entities/user.dart';

abstract class ManageUsersState {}

class ManageUsersInitial extends ManageUsersState {}

class ManageUsersLoading extends ManageUsersState {}

class ManageUsersLoaded extends ManageUsersState {
  final List<UserEntity> users;

  ManageUsersLoaded(this.users);
}

class ManageUsersError extends ManageUsersState {
  final String message;

  ManageUsersError(this.message);
}
