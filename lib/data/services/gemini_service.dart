import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/quiz_question.dart';

class GeminiService {
  final String apiKey;

  GeminiService() : apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<List<QuizQuestionEntity>> generateQuestions(String prompt) async {
    if (apiKey.isEmpty) throw Exception("API Key Gemini belum diset di .env");

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
              "Buatkan 10 soal kuis bahasa Mandarin untuk anak-anak berusia dibawah 6 tahun pilihan ganda berdasarkan topik berikut:\n$prompt\n dalam format JSON array:\n"
                  "[\n"
                  "  {\n"
                  "    \"soal\": \"Pertanyaan\",\n"
                  "    \"a\": \"Pilihan A\",\n"
                  "    \"b\": \"Pilihan B\",\n"
                  "    \"c\": \"Pilihan C\",\n"
                  "    \"d\": \"Pilihan D\",\n"
                  "    \"jawaban\": \"a\"\n"
                  "  },\n"
                  "  ... (10 soal)\n"
                  "]\n"
                  "Hanya tampilkan JSON array saja tanpa penjelasan tambahan."
            }
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      try {
        final textContent =
        jsonData["candidates"][0]["content"]["parts"][0]["text"];
        print("📥 Gemini Response:\n$textContent");

        // Bersihkan dan pastikan JSON-nya valid
        final cleaned = _extractValidJsonArray(textContent);
        final parsed = jsonDecode(cleaned) as List<dynamic>;

        return parsed.map((q) {
          return QuizQuestionEntity(
            id: "",
            soal: q["soal"],
            a: q["a"],
            b: q["b"],
            c: q["c"],
            d: q["d"],
            jawaban: q["jawaban"],
            level: 0,
          );
        }).toList();
      } catch (e) {
        throw Exception("Format JSON dari Gemini tidak valid: $e");
      }
    } else {
      throw Exception("Gagal generate soal: ${response.body}");
    }
  }

  // Utility: ekstrak hanya array JSON dari string
  String _extractValidJsonArray(String text) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    throw FormatException("Tidak ditemukan format JSON array dalam respons Gemini.");
  }
}
