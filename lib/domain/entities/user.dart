class UserEntity {
  final String uid;
  final String email;
  final String? name;
  final String? role;
  final String? parentUid;
  final DateTime? deletedAt; //

  UserEntity({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.parentUid,
    this.deletedAt,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? parentUid,
    DateTime? deletedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      parentUid: parentUid ?? this.parentUid,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, name: $name, email: $email, role: $role)';
  }
}
