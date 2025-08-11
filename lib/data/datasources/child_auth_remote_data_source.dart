import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class ChildAuthRemoteDataSource {
  Future<UserModel> childSignUp(String email, String password);
}

class ChildAuthRemoteDataSourceImpl implements ChildAuthRemoteDataSource {
  final FirebaseAuth childAuth;

  ChildAuthRemoteDataSourceImpl({required this.childAuth});

  @override
  Future<UserModel> childSignUp(String email, String password) async {
    final UserCredential userCredential =
    await childAuth.createUserWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user!;
    return UserModel.fromFirebaseUser(user.uid, user.email!);
  }
}
