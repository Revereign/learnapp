import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnapp/presentation/pages/admin/admin_dashboard_page.dart';
import 'package:learnapp/presentation/pages/child/main_menu/main_menu.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animated_button.dart';
import 'register_page.dart';
import '../parent/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _hasShownSnackbar = false;

  void _login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      _hasShownSnackbar = false;
      context.read<AuthBloc>().add(AuthSignInEvent(email: email, password: password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!_hasShownSnackbar) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _hasShownSnackbar = true;
            } else if (state is AuthSuccess) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (state.isAdmin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login Berhasil!")),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
                } else if (state.isOrangTua) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login Berhasil!")),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ParentDashboardPage()));
                } else if (state.isAnak) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login Berhasil!")),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainMenuPage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Role tidak dikenali. Silakan hubungi admin.")),
                  );
                }
              });
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Hero(
                  tag: "logo",
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Selamat Datang!",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: emailController, label: "Email"),
                const SizedBox(height: 15),
                CustomTextField(controller: passwordController, label: "Password", isPassword: true),
                const SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AnimatedButton(
                      text: state is AuthLoading ? "Loading..." : "Masuk",
                      onTap: _login,
                      color: Colors.blue.shade400,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text("Belum punya akun? Daftar"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}