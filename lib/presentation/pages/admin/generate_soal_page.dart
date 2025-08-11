import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../blocs/manage_quiz/manage_quiz_bloc.dart';
import '../../blocs/manage_quiz/manage_quiz_event.dart';
import '../../blocs/manage_quiz/manage_quiz_state.dart';

class GenerateSoalPage extends StatefulWidget {
  const GenerateSoalPage({super.key});

  @override
  State<GenerateSoalPage> createState() => _GenerateSoalPageState();
}

class _GenerateSoalPageState extends State<GenerateSoalPage> {
  final TextEditingController _promptController = TextEditingController();
  List<QuizQuestionEntity> _generatedQuestions = [];
  final Set<int> _savedQuestionIndexes = {};

  bool _isGenerating = false;
  bool _hasSubmittedPrompt = false;

  void _generateQuestions() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    // Reset index soal yang sudah disimpan sebelumnya
    setState(() {
      _hasSubmittedPrompt = true;
      _savedQuestionIndexes.clear();
    });

    context.read<ManageQuizBloc>().add(GenerateQuestionsFromPromptEvent(prompt));
  }

  void _saveQuestion(QuizQuestionEntity question, int index) {
    context.read<ManageQuizBloc>().add(SaveGeneratedQuestionEvent(question));
    setState(() {
      _savedQuestionIndexes.add(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Soal berhasil disimpan")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Soal dari Prompt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: "Masukkan Prompt",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_fix_high),
              onPressed: _generateQuestions,
              label: const Text("Generate Soal"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ManageQuizBloc, ManageQuizState>(
                builder: (context, state) {
                  if (state is ManageQuizLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ManageQuizError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is ManageQuizGenerated) {
                    return ListView.builder(
                      itemCount: state.generatedQuestions.length,
                        itemBuilder: (context, index) {
                          final question = state.generatedQuestions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
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
                                  _savedQuestionIndexes.contains(index)
                                      ? const Text("✅ Soal sudah disimpan")
                                      : ElevatedButton.icon(
                                    icon: const Icon(Icons.save),
                                    label: const Text("Simpan Soal Ini"),
                                    onPressed: () => _saveQuestion(question, index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                    );
                  }

                  if (!_hasSubmittedPrompt) {
                    return const Center(child: Text("Belum ada soal yang digenerate"));
                  }

                  return const Center(child: Text("Menunggu hasil dari Gemini..."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
