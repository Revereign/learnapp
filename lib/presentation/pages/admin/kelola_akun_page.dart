import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/domain/entities/user.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../blocs/manage_users/manage_users_event.dart';
import '../../blocs/manage_users/manage_users_state.dart';

class KelolaAkunPage extends StatefulWidget {
  const KelolaAkunPage({super.key});

  @override
  State<KelolaAkunPage> createState() => _KelolaAkunPageState();
}

class _KelolaAkunPageState extends State<KelolaAkunPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManageUsersBloc>().add(GetAllUsersEvent());
  }

  void _editNamaPengguna(BuildContext context, UserEntity user) {
    final nameController = TextEditingController(text: user.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Nama Pengguna"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nama Baru"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<ManageUsersBloc>().add(
                  UpdateUserNameEvent(user.uid, newName),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _hapusAkun(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Akun"),
        content: Text("Apakah Anda yakin ingin menghapus akun ${user.email}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ManageUsersBloc>().add(DeleteUserEvent(user.uid));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Akun Pengguna"),
        backgroundColor: Colors.orange.shade400,
      ),
      body: BlocBuilder<ManageUsersBloc, ManageUsersState>(
        builder: (context, state) {
          if (state is ManageUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ManageUsersLoaded) {
            final filteredUsers = state.users.where((u) => u.role != 'admin').toList();

            if (filteredUsers.isEmpty) {
              return const Center(child: Text("Tidak ada pengguna non-admin."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (_, index) {
                final user = filteredUsers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user.email),
                    subtitle: Text(user.name?.isNotEmpty == true ? user.name! : "-"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          _editNamaPengguna(context, user);
                        } else if (value == "delete") {
                          _hapusAkun(context, user);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "edit",
                          child: Text("Edit Nama"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Hapus Akun"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ManageUsersError) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
