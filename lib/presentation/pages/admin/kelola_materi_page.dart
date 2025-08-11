import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/presentation/pages/admin/materi_form_page.dart';
import 'package:lottie/lottie.dart';
import '../../../domain/entities/materi.dart';
import '../../../domain/usecases/materi/get_all_materi.dart';
import '../../../domain/usecases/materi/add_materi.dart';
import '../../../domain/usecases/materi/delete_materi.dart';
import '../../../domain/usecases/materi/update_materi.dart';
import '../../../data/repositories/materi_repository_impl.dart';
import '../../../data/datasources/materi_remote_data_source.dart';
import '../../blocs/materi/materi_bloc.dart';
import '../../blocs/materi/materi_event.dart';
import '../../blocs/materi/materi_state.dart';

class KelolaMateriPage extends StatefulWidget {
  const KelolaMateriPage({super.key});

  @override
  State<KelolaMateriPage> createState() => _KelolaMateriPageState();
}

class _KelolaMateriPageState extends State<KelolaMateriPage> {
  final firestore = FirebaseFirestore.instance;
  int? selectedLevel;

  late MateriBloc materiBloc;

  @override
  void initState() {
    super.initState();
    final repository = MateriRepositoryImpl(
      remoteDataSource: MateriRemoteDataSourceImpl(firestore: firestore),
    );
    materiBloc = MateriBloc(
      getAllMateri: GetAllMateri(repository),
      addMateri: AddMateri(repository),
      updateMateri: UpdateMateri(repository),
      deleteMateri: DeleteMateri(repository),
    );
  }

  void _selectLevel(int level) {
    setState(() {
      selectedLevel = level;
    });
    materiBloc.add(GetAllMateriEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: materiBloc,
      child: Scaffold(
        backgroundColor: Colors.yellow.shade50,
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: const Text("Kelola Materi Pembelajaran"),
          leading: selectedLevel != null
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() => selectedLevel = null);
            },
          )
              : null,
        ),
        floatingActionButton: selectedLevel != null
            ? FloatingActionButton(
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MateriFormPage(level: selectedLevel!),
              ),
            ).then((_) {
              materiBloc.add(GetAllMateriEvent());
            });
          },
        )
            : null,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: selectedLevel == null
              ? _buildLevelSelector()
              : KelolaMateriView(level: selectedLevel!),
        ),
      ),
    );
  }

  Widget _buildLevelSelector() {
    return GridView.count(
      key: const ValueKey('level_selector'), // penting untuk animasi switcher
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: List.generate(10, (index) {
        final level = index + 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => _selectLevel(level),
            child: Card(
              elevation: 8,
              color: Colors.primaries[index % Colors.primaries.length].shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}


class KelolaMateriView extends StatelessWidget {
  final int level;

  const KelolaMateriView({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MateriBloc, MateriState>(
      builder: (context, state) {
        if (state is MateriLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MateriLoaded) {
          final filtered = state.materiList.where((m) => m.level == level).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'Belum ada materi di level $level!',
                style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
              ),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final materi = filtered[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.primaries[index % Colors.primaries.length].shade200,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      if (materi.gambarBase64 != null && materi.gambarBase64!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(materi.gambarBase64!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              materi.kosakata,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Artinya: ${materi.arti}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MateriFormPage(
                                          existingMateri: materi,
                                          level: level,
                                        ),
                                      ),
                                    ).then((_) {
                                      context.read<MateriBloc>().add(GetAllMateriEvent());
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    context.read<MateriBloc>().add(DeleteMateriEvent(materi.id));
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is MateriError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text("Tak ada data"));
        }
      },
    );
  }
}
