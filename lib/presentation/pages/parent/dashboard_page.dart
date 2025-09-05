import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:learnapp/presentation/blocs/auth/auth_event.dart';
import 'package:learnapp/presentation/pages/auth/login_page.dart';
import 'package:learnapp/presentation/pages/parent/edit_profile_page.dart';
import 'package:learnapp/presentation/pages/parent/register_child_page.dart';
import 'package:learnapp/presentation/pages/parent/select_child_page.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key});

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
          backgroundColor: Colors.blue.shade700,
          title: const Text('Dashboard Orang Tua'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildMenuCard(
                "Buat Akun Anak",
                Icons.menu_book,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterChildPage()),
                  );
                },
                Colors.blue.shade400,
              ),
              _buildMenuCard(
                "Progress Anak",
                Icons.quiz,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SelectChildPage()),
                  );
                },
                Colors.green.shade400,
              ),
              _buildMenuCard("Materi Pembelajaran", Icons.group, () {}, Colors.orange.shade400),
              _buildMenuCard(
                "Edit Profile",
                Icons.code,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
                Colors.purple.shade400,
              ),
              _buildMenuCard("Logout", Icons.logout, () => _logout(context), Colors.red.shade400),
            ],
          ),
        ),
      );
  }
}

// class _DashboardButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _DashboardButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       splashColor: Colors.white24,
//       child: Container(
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 50, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
