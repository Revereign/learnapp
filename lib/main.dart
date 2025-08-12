import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learnapp/data/datasources/child_auth_remote_data_source.dart';
import 'package:learnapp/data/datasources/materi_remote_data_source.dart';
import 'package:learnapp/data/repositories/child_auth_repository_impl.dart';
import 'package:learnapp/data/repositories/materi_repository_impl.dart';
import 'package:learnapp/data/repositories/quiz_repository_impl.dart';
import 'package:learnapp/data/repositories/user_repository_impl.dart';
import 'package:learnapp/data/services/gemini_service.dart';
import 'package:learnapp/domain/usecases/manage_quiz/delete_question.dart';
import 'package:learnapp/domain/usecases/manage_quiz/generate_questions_from_prompt.dart';
import 'package:learnapp/domain/usecases/manage_quiz/load_all_questions.dart';
import 'package:learnapp/domain/usecases/manage_quiz/save_question.dart';
import 'package:learnapp/domain/usecases/manage_quiz/update_question_level.dart';
import 'package:learnapp/domain/usecases/manage_users/delete_user.dart';
import 'package:learnapp/domain/usecases/manage_users/get_all_users.dart';
import 'package:learnapp/domain/usecases/manage_users/update_user_name.dart';
import 'package:learnapp/domain/usecases/materi/add_materi.dart';
import 'package:learnapp/domain/usecases/materi/delete_materi.dart';
import 'package:learnapp/domain/usecases/materi/get_all_materi.dart';
import 'package:learnapp/domain/usecases/materi/update_materi.dart';
import 'package:learnapp/domain/usecases/auth/save_user_to_firestore.dart';
import 'package:learnapp/domain/usecases/parent/child_sign_up.dart';
import 'package:learnapp/domain/usecases/parent/save_child_to_firestore.dart';
import 'package:learnapp/presentation/blocs/manage_quiz/manage_quiz_bloc.dart';
import 'package:learnapp/presentation/blocs/manage_users/manage_users_bloc.dart';
import 'package:learnapp/presentation/blocs/materi/materi_bloc.dart';
import 'package:learnapp/presentation/blocs/parent/register_child/child_auth_bloc.dart';
import 'package:learnapp/presentation/blocs/child/level/level_bloc.dart';
import 'package:learnapp/presentation/blocs/child/level/counting_game_bloc.dart';
import 'package:learnapp/presentation/blocs/vocabulary/vocabulary_bloc.dart';
import 'package:learnapp/presentation/blocs/game/game_bloc.dart';
import 'package:learnapp/core/routes/app_routes.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'domain/usecases/auth/sign_in.dart';
import 'domain/usecases/auth/sign_up.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/materi/get_materi_by_level.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final authRepository = AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(
                auth: FirebaseAuth.instance,
              ),
            );

            return AuthBloc(
              signIn: SignIn(authRepository),
              signUp: SignUp(authRepository),
              signOut: SignOut(authRepository),
              saveUserToFirestore: SaveUserToFirestore(authRepository),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            final childAuthRepository = ChildAuthRepositoryImpl(
              childRemoteDataSource: ChildAuthRemoteDataSourceImpl(
                childAuth: FirebaseAuth.instance,
              ),
            );

            return ChildAuthBloc(
              childSignUp: ChildSignUp(childAuthRepository),
              saveChildToFirestore: SaveChildToFirestore(childAuthRepository),
            );
          },
        ),
        BlocProvider(
          create: (context) => MateriBloc(
            getAllMateri: GetAllMateri(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
            addMateri: AddMateri(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
            updateMateri: UpdateMateri(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
            deleteMateri: DeleteMateri(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => ManageUsersBloc(
            getAllUsers: GetAllUsers(UserRepositoryImpl(firestore: FirebaseFirestore.instance)),
            updateUserName: UpdateUserName(UserRepositoryImpl(firestore: FirebaseFirestore.instance)),
            deleteUser: DeleteUser(UserRepositoryImpl(firestore: FirebaseFirestore.instance)),
          ),
        ),
        BlocProvider(
          create: (context) => ManageQuizBloc(
            loadAllQuestions: LoadAllQuestions(
              QuizRepositoryImpl(firestore: FirebaseFirestore.instance),
            ),
            saveQuestion: SaveQuestion(
              QuizRepositoryImpl(firestore: FirebaseFirestore.instance),
            ),
            updateQuestionLevel: UpdateQuestionLevel(
              QuizRepositoryImpl(firestore: FirebaseFirestore.instance),
            ),
            deleteQuestion: DeleteQuestion(
              QuizRepositoryImpl(firestore: FirebaseFirestore.instance),
            ),
            generateQuestionsFromPrompt: GenerateQuestionsFromPrompt(
              GeminiService(), // Pastikan apiKey-nya dari dotenv
            ),
          ),
        ),
        BlocProvider(
          create: (context) => LevelBloc(
            getAllMateri: GetAllMateri(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => CountingGameBloc(
            getMateriByLevel: GetMateriByLevel(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => VocabularyBloc(
            getMateriByLevel: GetMateriByLevel(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => GameBloc(
            getMateriByLevel: GetMateriByLevel(
              MateriRepositoryImpl(
                remoteDataSource: MateriRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
