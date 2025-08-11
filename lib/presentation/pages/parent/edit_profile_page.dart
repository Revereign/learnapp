import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/parent/edit_profile/edit_profile_bloc.dart';
import '../../blocs/parent/edit_profile/edit_profile_event.dart';
import '../../blocs/parent/edit_profile/edit_profile_state.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
      )..add(LoadUserProfile()),
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      context.read<EditProfileBloc>().add(ProfileImagePicked(File(picked.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        _nameController.text = state.name;
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text("Edit Profil"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(context),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: state.image != null
                          ? FileImage(state.image!)
                          : (state.photoUrl != null
                          ? NetworkImage(state.photoUrl!)
                          : const AssetImage('assets/images/default_avatar.jpg') as ImageProvider),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) =>
                        context.read<EditProfileBloc>().add(NameChanged(val)),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    onChanged: (val) => context
                        .read<EditProfileBloc>()
                        .add(PasswordChanged(val)),
                    validator: (val) {
                      if (val != null && val.isNotEmpty && val.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context
                            .read<EditProfileBloc>()
                            .add(SubmitProfileChanges());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Simpan Perubahan'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
