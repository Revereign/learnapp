import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart';

abstract class ChildAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChildAuthInitial extends ChildAuthState {}

class ChildAuthLoading extends ChildAuthState {}

class ChildAuthSuccess extends ChildAuthState {
  final UserEntity user ;

  bool get isOrangTua => user.role == 'orangtua';
  bool get isAdmin => user.role== 'admin';
  bool get isAnak => user.role == "anak";

  ChildAuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ChildAuthFailure extends ChildAuthState {
  final String message;

  ChildAuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
