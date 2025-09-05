import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/presentation/blocs/auth/auth_event.dart';
import 'package:learnapp/presentation/blocs/auth/auth_state.dart';
import '../../../domain/usecases/auth/sign_in.dart';
import '../../../domain/usecases/auth/sign_up.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import '../../../domain/usecases/auth/save_user_to_firestore.dart';
import '../../../domain/usecases/auth/check_auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final SaveUserToFirestore saveUserToFirestore;
  final CheckAuthState checkAuthState;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.saveUserToFirestore,
    required this.checkAuthState,
  }) : super(AuthInitial()) {
    on<AuthSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signIn(event.email, event.password);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUp(event.email, event.password);

        // Role default saat registrasi
        const defaultRole = 'orangtua';

        // Simpan data user ke Firestore
        await saveUserToFirestore(user, defaultRole);

        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignOutEvent>((event, emit) async {
      await signOut();
      emit(AuthLoggedOut());
    });

    on<CheckAuthStateEvent>((event, emit) async {
      emit(AuthChecking());
      try {
        final user = await checkAuthState();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthLoggedOut());
        }
      } catch (e) {
        emit(AuthLoggedOut());
      }
    });
  }
}
