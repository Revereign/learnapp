import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/presentation/pages/admin/kelola_akun_page.dart';
import 'package:learnapp/presentation/pages/admin/kelola_soal_kuis_page.dart';
import 'package:learnapp/presentation/pages/admin/kelola_prompt_page.dart';
import 'package:learnapp/presentation/pages/admin/feedback_list_page.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../auth/login_page.dart';
import 'kelola_materi_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(AuthSignOutEvent());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Widget _buildMenuCard(String title, IconData icon, VoidCallback onTap, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white24, // Warna efek ripple
        highlightColor: Colors.white10, // Warna saat ditekan
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildMenuCard(
              "Kelola Materi Pembelajaran",
              Icons.menu_book,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaMateriPage()),
                );
              },
              Colors.blue.shade400,
            ),
            _buildMenuCard(
              "Kelola Soal Kuis",
              Icons.quiz,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaSoalKuisPage()),
                );
              },
              Colors.green.shade400,
            ),
            _buildMenuCard(
              "Kelola Akun Pengguna",
              Icons.group,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaAkunPage()),
                );
              },
              Colors.orange.shade400,
            ),
            _buildMenuCard(
              "Kelola Prompt LLM",
              Icons.code,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaPromptPage()),
                );
              },
              Colors.purple.shade400,
            ),
            _buildMenuCard(
              "Lihat Feedback",
              Icons.feedback,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackListPage()),
                );
              },
              Colors.cyan.shade400,
            ),
            _buildMenuCard("Keluar", Icons.logout, () => _logout(context), Colors.red.shade400),
          ],
        ),
      ),
    );
  }
}
