import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnapp/domain/entities/user.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? role;
  final String? parentUid;
  final DateTime? deletedAt; // Tambahan untuk soft delete

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.parentUid,
    this.deletedAt,
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
    );
  }

  Map<String, dynamic> toJson() => {
    "email": email,
    "name": name,
    "role": role,
    "deletedAt": deletedAt,
  };

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      role: role,
      parentUid: parentUid,
      deletedAt: deletedAt,
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
    );
  }
}
