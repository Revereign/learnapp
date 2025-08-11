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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Soal Tersimpan")),
      body: BlocBuilder<ManageQuizBloc, ManageQuizState>(
        builder: (context, state) {
          if (state is ManageQuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ManageQuizError) {
            return Center(child: Text(state.message));
          }

          if (state is ManageQuizLoaded) {
            if (state.questions.isEmpty) {
              return const Center(child: Text("Belum ada soal yang tersimpan."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              items: List.generate(11, (i) => i).map((level) {
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
    );
  }
}
