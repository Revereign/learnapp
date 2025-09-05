import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/parent/edit_child_profile/edit_child_profile_bloc.dart';
import '../../blocs/parent/edit_child_profile/edit_child_profile_event.dart';
import '../../blocs/parent/edit_child_profile/edit_child_profile_state.dart';

class EditChildProfilePage extends StatelessWidget {
  final String childUid;
  final String childName;

  const EditChildProfilePage({
    super.key,
    required this.childUid,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditChildProfileBloc(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      )..add(LoadChildProfile(childUid)),
      child: EditChildProfileView(
        childUid: childUid,
        childName: childName,
      ),
    );
  }
}

class EditChildProfileView extends StatefulWidget {
  final String childUid;
  final String childName;

  const EditChildProfileView({
    super.key,
    required this.childUid,
    required this.childName,
  });

  @override
  State<EditChildProfileView> createState() => _EditChildProfileViewState();
}

class _EditChildProfileViewState extends State<EditChildProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditChildProfileBloc, EditChildProfileState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil anak berhasil diperbarui')),
          );
          // Kembalikan true untuk menandakan ada perubahan
          Navigator.pop(context, true);
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
            title: Text("Edit Nama Anak"),
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
                  // Field nama
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) =>
                        context.read<EditChildProfileBloc>().add(NameChanged(val)),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 30),
                  
                  // Tombol simpan
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context
                            .read<EditChildProfileBloc>()
                            .add(SubmitChildProfileChanges());
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
