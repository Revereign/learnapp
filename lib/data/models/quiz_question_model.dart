import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz_question.dart';

class QuizQuestionModel {
  final String id;
  final String soal;
  final String a;
  final String b;
  final String c;
  final String d;
  final String jawaban;
  final int level;

  QuizQuestionModel({
    required this.id,
    required this.soal,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.jawaban,
    required this.level,
  });

  factory QuizQuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizQuestionModel(
      id: doc.id,
      soal: data["soal"],
      a: data["a"],
      b: data["b"],
      c: data["c"],
      d: data["d"],
      jawaban: data["jawaban"],
      level: data["level"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "soal": soal,
    "a": a,
    "b": b,
    "c": c,
    "d": d,
    "jawaban": jawaban,
    "level": level,
  };

  QuizQuestionEntity toEntity() => QuizQuestionEntity(
    id: id,
    soal: soal,
    a: a,
    b: b,
    c: c,
    d: d,
    jawaban: jawaban,
    level: level,
  );

  factory QuizQuestionModel.fromEntity(QuizQuestionEntity entity) => QuizQuestionModel(
    id: entity.id,
    soal: entity.soal,
    a: entity.a,
    b: entity.b,
    c: entity.c,
    d: entity.d,
    jawaban: entity.jawaban,
    level: entity.level,
  );
}
