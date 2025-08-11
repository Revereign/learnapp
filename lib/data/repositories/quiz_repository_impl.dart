import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../models/quiz_question_model.dart';

class QuizRepositoryImpl implements QuizRepository {
  final FirebaseFirestore firestore;

  QuizRepositoryImpl({required this.firestore});

  @override
  Future<List<QuizQuestionEntity>> getAllQuestions() async {
    final snapshot = await firestore.collection("quiz_questions").get();
    return snapshot.docs
        .map((doc) => QuizQuestionModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> saveQuestion(QuizQuestionEntity question) async {
    final model = QuizQuestionModel.fromEntity(question);
    await firestore.collection("quiz_questions").add(model.toJson());
  }

  @override
  Future<void> updateQuestionLevel(String id, int level) async {
    await firestore.collection("quiz_questions").doc(id).update({"level": level});
  }

  @override
  Future<void> deleteQuestion(String id) async {
    await firestore.collection("quiz_questions").doc(id).delete();
  }
}
