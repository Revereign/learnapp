import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  EditProfileBloc({
    required this.auth,
    required this.firestore,
    required this.storage,
  }) : super(EditProfileState.initial()) {
    on<LoadUserProfile>(_onLoadProfile);
    on<NameChanged>((event, emit) => emit(state.copyWith(name: event.name)));
    on<PasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<ProfileImagePicked>((event, emit) => emit(state.copyWith(image: event.image)));
    on<SubmitProfileChanges>(_onSubmitChanges);
  }

  Future<void> _onLoadProfile(
      LoadUserProfile event, Emitter<EditProfileState> emit) async {
    final user = auth.currentUser;
    if (user == null) return;

    final userDoc = await firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    emit(state.copyWith(
      name: data?['name'] ?? '',
      photoUrl: data?['photoUrl'], // Tambahkan ini di state
    ));
  }

  Future<void> _onSubmitChanges(SubmitProfileChanges event, Emitter<EditProfileState> emit) async {
    final user = auth.currentUser;
    if (user == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      String? photoUrl;

      if (state.image != null) {
        final ref = storage.ref().child('profile_pictures/${user.uid}.jpg');
        await ref.putFile(state.image!);

        photoUrl = await ref.getDownloadURL();
      }

      await firestore.collection('users').doc(user.uid).update({
        'name': state.name,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      if (state.password.isNotEmpty) {
        await user.updatePassword(state.password);
      }

      emit(state.copyWith(
        isLoading: false,
        success: true,
        password: '',   // reset password field
        image: null,    // reset image picker
      ));
      add(LoadUserProfile());
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
