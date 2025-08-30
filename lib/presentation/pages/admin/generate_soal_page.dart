import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../domain/entities/materi.dart';
import '../../blocs/manage_quiz/manage_quiz_bloc.dart';
import '../../blocs/manage_quiz/manage_quiz_event.dart';
import '../../blocs/manage_quiz/manage_quiz_state.dart';
import '../../blocs/vocabulary/vocabulary_bloc.dart';
import '../../blocs/vocabulary/vocabulary_event.dart';
import '../../blocs/vocabulary/vocabulary_state.dart';
import '../../../data/services/gemini_service.dart';

class GenerateSoalPage extends StatefulWidget {
  const GenerateSoalPage({super.key});

  @override
  State<GenerateSoalPage> createState() => _GenerateSoalPageState();
}

class _GenerateSoalPageState extends State<GenerateSoalPage> {
  List<QuizQuestionEntity> _generatedQuestions = [];
  final Set<int> _savedQuestionIndexes = {};
  
  // New fields for level-based generation
  int? _selectedLevel;
  List<Materi> _levelMateri = [];
  bool _isLoadingMateri = false;

  bool _isGenerating = false;
  bool _hasSubmittedPrompt = false;

  @override
  void initState() {
    super.initState();
    // Tidak load materi di awal karena belum ada level yang dipilih
  }

  void _loadMateriForLevel(int level) {
    setState(() {
      _isLoadingMateri = true;
    });
    
    context.read<VocabularyBloc>().add(LoadVocabulary(level));
  }

  void _onLevelChanged(int newLevel) {
    setState(() {
      _selectedLevel = newLevel;
      _hasSubmittedPrompt = false;
      _savedQuestionIndexes.clear();
      _generatedQuestions.clear();
    });
    _loadMateriForLevel(newLevel);
  }

  String _getLevelTopic(int level) {
    switch (level) {
      case 1:
        return "Warna Dasar";
      case 2:
        return "Buah-buahan";
      case 3:
        return "Sayuran";
      case 4:
        return "Anggota Tubuh";
      case 5:
        return "Makanan";
      case 6:
        return "Makanan dan Minuman";
      case 7:
        return "Alat Transportasi";
      case 8:
        return "Hewan";
      case 9:
        return "Barang Sehari-hari";
      case 10:
        return "Barang Sehari-hari";
      default:
        return "Umum";
    }
  }

  void _generateQuestions() async {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih level terlebih dahulu")),
      );
      return;
    }
    
    if (_levelMateri.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada materi untuk level ini")),
      );
      return;
    }

    // Reset index soal yang sudah disimpan sebelumnya
    setState(() {
      _hasSubmittedPrompt = true;
      _savedQuestionIndexes.clear();
      _isGenerating = true;
    });

    try {
      // Create level-specific prompt
      final levelSpecificPrompt = _createLevelSpecificPrompt();
      
      // Generate questions using Gemini service
      final geminiService = GeminiService();
      final questions = await geminiService.generateQuestions(levelSpecificPrompt);
      
      setState(() {
        _generatedQuestions = questions;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  String _createLevelSpecificPrompt() {
    // Create a list of available vocabulary for the selected level
    final vocabularyList = _levelMateri.map((m) => "${m.kosakata} (${m.arti})").join(", ");
    final topic = _getLevelTopic(_selectedLevel!);
    
    return """
Buatkan 10 soal kuis bahasa Mandarin untuk anak-anak berusia dibawah 6 tahun pilihan ganda berdasarkan topik: $topic
PENTING: 
- Gunakan HANYA kosa kata yang tersedia di level $_selectedLevel berikut: $vocabularyList, Jangan gunakan kosa kata lain yang tidak ada dalam daftar di atas.
- Berikan pinyin, serta artinya jika soal menggunakan full bahasa mandarin.
- Berikan berbagai macam soal seperti cara membaca suatu kosa kata (Pastikan di soal tidak ada pinyin, hanya di pilihan jawaban saja), soal mengenai arti dari suatu kosa kata, dan soal-soal umum (contohnya jika materi tentang warna, maka menanyakan apa warna dari gajah), dll sesuai kreativitasmu
- Format JSON array:
[
  {
    "soal": "Pertanyaan",
    "a": "Pilihan A",
    "b": "Pilihan B", 
    "c": "Pilihan C",
    "d": "Pilihan D",
    "jawaban": "a"
  },
  ... (10 soal)
]

Hanya tampilkan JSON array saja tanpa penjelasan tambahan.
""";
  }

  void _saveQuestion(QuizQuestionEntity question, int index) {
    // Set the level for the question before saving
    if (_selectedLevel == null) return; // Safety check
    
    final questionWithLevel = QuizQuestionEntity(
      id: question.id,
      soal: question.soal,
      a: question.a,
      b: question.b,
      c: question.c,
      d: question.d,
      jawaban: question.jawaban,
      level: _selectedLevel!, // Set the selected level
    );
    
    context.read<ManageQuizBloc>().add(SaveGeneratedQuestionEvent(questionWithLevel));
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
      appBar: AppBar(title: const Text("Generate Soal dari Level")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Level selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pilih Level:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedLevel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Level",
                        hintText: "Pilih Level yang diinginkan",
                      ),
                      items: List.generate(10, (index) {
                        final level = index + 1;
                        return DropdownMenuItem(
                          value: level,
                          child: Text("Level $level - ${_getLevelTopic(level)}"),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          _onLevelChanged(value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Show materi count for selected level
                    BlocBuilder<VocabularyBloc, VocabularyState>(
                      builder: (context, state) {
                        if (state is VocabularyLoading) {
                          return const Text("Memuat materi...", style: TextStyle(color: Colors.grey));
                        } else if (state is VocabularyLoaded) {
                          _levelMateri = state.materiList;
                          return Text(
                            "Materi tersedia: ${state.materiList.length} kosa kata",
                            style: const TextStyle(color: Colors.green),
                          );
                        } else if (state is VocabularyError) {
                          return Text(
                            "Error: ${state.message}",
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Generate button
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_fix_high),
              onPressed: _isGenerating || _selectedLevel == null || _levelMateri.isEmpty ? null : _generateQuestions,
              label: Text(_isGenerating ? "Generating..." : "Generate Soal ${_selectedLevel != null ? _getLevelTopic(_selectedLevel!) : ""}"),
            ),
            
            const SizedBox(height: 16),
            
            // Questions display
            Expanded(
              child: _buildQuestionsDisplay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsDisplay() {
    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Sedang generate soal..."),
          ],
        ),
      );
    }

    if (!_hasSubmittedPrompt) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada soal yang digenerate',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Pilih level dan tekan Generate Soal',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_generatedQuestions.isEmpty) {
      return const Center(
        child: Text("Tidak ada soal yang dihasilkan"),
      );
    }

    return ListView.builder(
      itemCount: _generatedQuestions.length,
      itemBuilder: (context, index) {
        final question = _generatedQuestions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
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
                          "Level ${_selectedLevel!} - ${_getLevelTopic(_selectedLevel!)}",
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
                Text(
                  question.soal,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
}
