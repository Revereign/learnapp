import 'package:flutter/material.dart';
import 'generate_soal_page.dart';
import 'kelola_soal_tersimpan.dart';

class KelolaSoalKuisPage extends StatelessWidget {
  const KelolaSoalKuisPage({super.key});

  Widget _buildMenuCard(String title, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        color: color,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Soal Kuis"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMenuCard(
              "Generate Soal dari Prompt",
              Icons.auto_mode,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GenerateSoalPage()),
              ),
              Colors.teal.shade400,
            ),
            _buildMenuCard(
              "Kelola Soal Tersimpan",
              Icons.library_books,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KelolaSoalTersimpanPage()),
              ),
              Colors.blue.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
