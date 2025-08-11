import 'package:equatable/equatable.dart';

abstract class ChildAuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChildAuthSignUpEvent extends ChildAuthEvent {
  final String email;
  final String password;

  ChildAuthSignUpEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
