import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnapp/domain/entities/user.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? role;
  final String? parentUid;
  final DateTime? deletedAt; // Tambahan untuk soft delete
  final List<int>? gameScore;
  final List<int>? quizScore;
  final List<int>? quizTime;
  final List<bool>? achieve;
  final int? todayTime;
  final int? allTime;

  UserModel({
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

  factory UserModel.fromFirebaseUser(String uid, String email) {
    return UserModel(uid: uid, email: email);
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data["email"] ?? '',
      name: data["name"],
      role: data["role"],
      parentUid: data["parentUid"] != null
          ? data["parentUid"]
          : null,
      deletedAt: data["deletedAt"] != null
          ? (data["deletedAt"] as Timestamp).toDate()
          : null,
      gameScore: data["gameScore"] != null
          ? List<int>.from(data["gameScore"])
          : null,
      quizScore: data["quizScore"] != null
          ? List<int>.from(data["quizScore"])
          : null,
      quizTime: data["quizTime"] != null
          ? List<int>.from(data["quizTime"])
          : null,
      achieve: data["achieve"] != null
          ? List<bool>.from(data["achieve"])
          : null,
      todayTime: data["todayTime"],
      allTime: data["allTime"],
    );
  }

  Map<String, dynamic> toJson() => {
    "email": email,
    "name": name,
    "role": role,
    "deletedAt": deletedAt,
    "gameScore": gameScore,
    "quizScore": quizScore,
    "quizTime": quizTime,
    "achieve": achieve,
    "todayTime": todayTime,
    "allTime": allTime,
  };

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      role: role,
      parentUid: parentUid,
      deletedAt: deletedAt,
      gameScore: gameScore,
      quizScore: quizScore,
      quizTime: quizTime,
      achieve: achieve,
      todayTime: todayTime,
      allTime: allTime,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      parentUid: entity.parentUid,
      deletedAt: entity.deletedAt,
      gameScore: entity.gameScore,
      quizScore: entity.quizScore,
      quizTime: entity.quizTime,
      achieve: entity.achieve,
      todayTime: entity.todayTime,
      allTime: entity.allTime,
    );
  }
}
