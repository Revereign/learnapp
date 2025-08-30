import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../blocs/manage_quiz/manage_quiz_bloc.dart';
import '../../blocs/manage_quiz/manage_quiz_event.dart';
import '../../blocs/manage_quiz/manage_quiz_state.dart';

class KelolaSoalTersimpanPage extends StatefulWidget {
  const KelolaSoalTersimpanPage({super.key});

  @override
  State<KelolaSoalTersimpanPage> createState() => _KelolaSoalTersimpanPageState();
}

class _KelolaSoalTersimpanPageState extends State<KelolaSoalTersimpanPage> {
  int? _selectedFilterLevel;
  
  @override
  void initState() {
    super.initState();
    context.read<ManageQuizBloc>().add(LoadAllQuestionsEvent());
  }

  void _ubahLevel(String id, int level) {
    context.read<ManageQuizBloc>().add(UpdateQuestionLevelEvent(id: id, level: level));
  }

  void _hapusSoal(String id) {
    context.read<ManageQuizBloc>().add(DeleteQuestionEvent(id));
  }

  void _filterByLevel(int? level) {
    setState(() {
      _selectedFilterLevel = level;
    });
  }

  List<QuizQuestionEntity> _getFilteredQuestions(List<QuizQuestionEntity> allQuestions) {
    if (_selectedFilterLevel == null) {
      return allQuestions;
    }
    return allQuestions.where((question) => question.level == _selectedFilterLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Soal Tersimpan")),
      body: Column(
        children: [
          // Level filter section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter berdasarkan Level:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedFilterLevel,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Pilih Level",
                          hintText: "Semua Level",
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("Semua Level"),
                          ),
                          ...List.generate(10, (index) {
                            final level = index + 1;
                            return DropdownMenuItem<int?>(
                              value: level,
                              child: Text("Level $level"),
                            );
                          }),
                        ],
                        onChanged: _filterByLevel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _selectedFilterLevel != null ? () => _filterByLevel(null) : null,
                      child: const Text("Reset Filter"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Questions list
          Expanded(
            child: BlocBuilder<ManageQuizBloc, ManageQuizState>(
              builder: (context, state) {
                if (state is ManageQuizLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ManageQuizError) {
                  return Center(child: Text(state.message));
                }

                if (state is ManageQuizLoaded) {
                  final filteredQuestions = _getFilteredQuestions(state.questions);
                  
                  if (filteredQuestions.isEmpty) {
                    if (_selectedFilterLevel != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.filter_list, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada soal untuk Level $_selectedFilterLevel',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _filterByLevel(null),
                              child: const Text("Lihat Semua Soal"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: Text("Belum ada soal yang tersimpan."));
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = filteredQuestions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Level ${question.level}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Soal ${index + 1}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(question.soal, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("A. ${question.a}"),
                              Text("B. ${question.b}"),
                              Text("C. ${question.c}"),
                              Text("D. ${question.d}"),
                              const SizedBox(height: 8),
                              Text("Jawaban Benar: ${question.jawaban.toUpperCase()}"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text("Level: "),
                                  DropdownButton<int>(
                                    value: question.level,
                                    items: List.generate(10, (i) => i + 1).map((level) {
                                      return DropdownMenuItem(
                                        value: level,
                                        child: Text("$level"),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null && value != question.level) {
                                        _ubahLevel(question.id, value);
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _hapusSoal(question.id),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
