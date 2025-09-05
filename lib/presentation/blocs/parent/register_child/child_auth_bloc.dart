import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learnapp/domain/usecases/parent/child_sign_up.dart';
import 'package:learnapp/domain/usecases/parent/save_child_to_firestore.dart';
import 'package:learnapp/presentation/blocs/parent/register_child/child_auth_event.dart';
import 'package:learnapp/presentation/blocs/parent/register_child/child_auth_state.dart';

class ChildAuthBloc extends Bloc<ChildAuthEvent, ChildAuthState> {
  final parent = FirebaseAuth.instance.currentUser;
  final ChildSignUp childSignUp;
  final SaveChildToFirestore saveChildToFirestore;

  ChildAuthBloc({
    required this.childSignUp,
    required this.saveChildToFirestore,
  }) : super(ChildAuthInitial()) {
    on<ChildAuthSignUpEvent>((event, emit) async {
      emit(ChildAuthLoading());
      try {
        final user = await childSignUp(event.email, event.password);
        final parentUid = parent!.uid.toString();

        print('Parent UID: $parentUid');

        // Role default saat registrasi
        const defaultRole = 'anak';

        // Simpan data user ke Firestore
        await saveChildToFirestore(user, defaultRole, parentUid);

        // Logout dari akun anak yang baru dibuat untuk mengembalikan session ke parent
        await FirebaseAuth.instance.signOut();

        emit(ChildAuthSuccess(user));
      } catch (e) {
        emit(ChildAuthFailure(e.toString()));
      }
    });
  }
}
