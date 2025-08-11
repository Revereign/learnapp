import 'package:flutter_bloc/flutter_bloc.dart';
import 'manage_users_event.dart';
import 'manage_users_state.dart';
import '../../../domain/usecases/manage_users/get_all_users.dart';
import '../../../domain/usecases/manage_users/update_user_name.dart';
import '../../../domain/usecases/manage_users/delete_user.dart';

class ManageUsersBloc extends Bloc<ManageUsersEvent, ManageUsersState> {
  final GetAllUsers getAllUsers;
  final UpdateUserName updateUserName;
  final DeleteUser deleteUser;

  ManageUsersBloc({
    required this.getAllUsers,
    required this.updateUserName,
    required this.deleteUser,
  }) : super(ManageUsersInitial()) {
    on<GetAllUsersEvent>((event, emit) async {
      emit(ManageUsersLoading());
      try {
        final users = await getAllUsers();
        emit(ManageUsersLoaded(users));
      } catch (e) {
        emit(ManageUsersError(e.toString()));
      }
    });

    on<UpdateUserNameEvent>((event, emit) async {
      try {
        await updateUserName(event.uid, event.newName);
        add(GetAllUsersEvent());
      } catch (e) {
        emit(ManageUsersError(e.toString()));
      }
    });

    on<DeleteUserEvent>((event, emit) async {
      try {
        await deleteUser(event.uid);
        add(GetAllUsersEvent());
      } catch (e) {
        emit(ManageUsersError(e.toString()));
      }
    });
  }
}
