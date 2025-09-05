abstract class EditChildProfileEvent {}

class LoadChildProfile extends EditChildProfileEvent {
  final String childUid;
  LoadChildProfile(this.childUid);
}

class NameChanged extends EditChildProfileEvent {
  final String name;
  NameChanged(this.name);
}

class PasswordChanged extends EditChildProfileEvent {
  final String password;
  PasswordChanged(this.password);
}

class SubmitChildProfileChanges extends EditChildProfileEvent {}
