class UserEntity {
  final String uid;
  final String email;
  final String? name;
  final String? role;
  final String? parentUid;
  final DateTime? deletedAt; //
  final List<int>? gameScore;
  final List<int>? quizScore;
  final List<int>? quizTime;
  final List<bool>? achieve;
  final int? todayTime;
  final int? allTime;

  UserEntity({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.parentUid,
    this.deletedAt,
    this.gameScore,
    this.quizScore,
    this.quizTime,
    this.achieve,
    this.todayTime,
    this.allTime,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? parentUid,
    DateTime? deletedAt,
    List<int>? gameScore,
    List<int>? quizScore,
    List<int>? quizTime,
    List<bool>? achieve,
    int? todayTime,
    int? allTime,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      parentUid: parentUid ?? this.parentUid,
      deletedAt: deletedAt ?? this.deletedAt,
      gameScore: gameScore ?? this.gameScore,
      quizScore: quizScore ?? this.quizScore,
      quizTime: quizTime ?? this.quizTime,
      achieve: achieve ?? this.achieve,
      todayTime: todayTime ?? this.todayTime,
      allTime: allTime ?? this.allTime,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, name: $name, email: $email, role: $role)';
  }
}
