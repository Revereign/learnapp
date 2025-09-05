abstract class EditChildProfileEvent {}

class LoadChildProfile extends EditChildProfileEvent {
  final String childUid;
  LoadChildProfile(this.childUid);
}

class NameChanged extends EditChildProfileEvent {
  final String name;
  NameChanged(this.name);
}


class SubmitChildProfileChanges extends EditChildProfileEvent {}
