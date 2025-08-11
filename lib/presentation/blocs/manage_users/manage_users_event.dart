import '../../../domain/entities/user.dart';

abstract class ManageUsersEvent {}

class GetAllUsersEvent extends ManageUsersEvent {}

class UpdateUserNameEvent extends ManageUsersEvent {
  final String uid;
  final String newName;

  UpdateUserNameEvent(this.uid, this.newName);
}

class DeleteUserEvent extends ManageUsersEvent {
  final String uid;

  DeleteUserEvent(this.uid);
}
