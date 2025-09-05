import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;

  AuthRemoteDataSourceImpl({required this.auth});

  @override
  Future<UserModel> signIn(String email, String password) async {
    final UserCredential userCredential =
    await auth.signInWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user!;
    return UserModel.fromFirebaseUser(user.uid, user.email!);
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    final UserCredential userCredential =
    await auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user!;
    return UserModel.fromFirebaseUser(user.uid, user.email!);
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user.uid, user.email!);
    }
    return null;
  }
}
