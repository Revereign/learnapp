import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_child_profile_event.dart';
import 'edit_child_profile_state.dart';

class EditChildProfileBloc extends Bloc<EditChildProfileEvent, EditChildProfileState> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  String? _childUid;

  EditChildProfileBloc({
    required this.auth,
    required this.firestore,
  }) : super(EditChildProfileState.initial()) {
    on<LoadChildProfile>(_onLoadProfile);
    on<NameChanged>((event, emit) => emit(state.copyWith(name: event.name)));
    on<SubmitChildProfileChanges>(_onSubmitChanges);
  }

  Future<void> _onLoadProfile(
      LoadChildProfile event, Emitter<EditChildProfileState> emit) async {
    try {
      _childUid = event.childUid;
      final userDoc = await firestore.collection('users').doc(event.childUid).get();
      final data = userDoc.data();
      
      if (data == null) {
        emit(state.copyWith(errorMessage: 'Data anak tidak ditemukan'));
        return;
      }

      emit(state.copyWith(
        name: data['name'] ?? '',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memuat data anak: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitChanges(SubmitChildProfileChanges event, Emitter<EditChildProfileState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      if (_childUid == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Child UID tidak ditemukan'));
        return;
      }

      // Update data di Firestore
      await firestore.collection('users').doc(_childUid!).update({
        'name': state.name,
      });

      emit(state.copyWith(
        isLoading: false,
        success: true,
      ));
      
      // Reload profile setelah update
      add(LoadChildProfile(_childUid!));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
