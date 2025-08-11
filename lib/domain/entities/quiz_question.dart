class QuizQuestionEntity {
  final String id;
  final String soal;
  final String a;
  final String b;
  final String c;
  final String d;
  final String jawaban;
  final int level;

  QuizQuestionEntity({
    required this.id,
    required this.soal,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.jawaban,
    required this.level,
  });

  QuizQuestionEntity copyWith({
    String? id,
    String? soal,
    String? a,
    String? b,
    String? c,
    String? d,
    String? jawaban,
    int? level,
  }) {
    return QuizQuestionEntity(
      id: id ?? this.id,
      soal: soal ?? this.soal,
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      d: d ?? this.d,
      jawaban: jawaban ?? this.jawaban,
      level: level ?? this.level,
    );
  }
}
