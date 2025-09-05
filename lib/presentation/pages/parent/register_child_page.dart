import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnapp/presentation/blocs/parent/register_child/child_auth_state.dart';
import 'package:learnapp/presentation/blocs/parent/register_child/child_auth_bloc.dart';
import 'package:learnapp/presentation/blocs/parent/register_child/child_auth_event.dart';
import 'package:learnapp/presentation/pages/parent/parent_dashboard_page.dart';
import 'package:learnapp/presentation/pages/auth/login_page.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animated_button.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  _RegisterChildPageState createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _hasShownSnackbar = false;

  void _register() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      _hasShownSnackbar = false;
      context.read<ChildAuthBloc>().add(ChildAuthSignUpEvent(email: email, password: password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      resizeToAvoidBottomInset: true,
      body: BlocListener<ChildAuthBloc, ChildAuthState>(
        listener: (context, state) {
          if (!_hasShownSnackbar) {
            if (state is ChildAuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _hasShownSnackbar = true;
            } else if (state is ChildAuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Registrasi Berhasil! Silakan login kembali.")),
              );
              _hasShownSnackbar = true;

              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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
                  "Buat Akun Anak Baru!",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: emailController, label: "Email"),
                const SizedBox(height: 15),
                CustomTextField(controller: passwordController, label: "Password", isPassword: true),
                const SizedBox(height: 20),
                BlocBuilder<ChildAuthBloc, ChildAuthState>(
                  builder: (context, state) {
                    return AnimatedButton(
                      text: state is ChildAuthLoading ? "Loading..." : "Daftar",
                      onTap: _register,
                      color: Colors.green.shade400,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ParentDashboardPage()),
                    );
                  },
                  child: const Text("Kembali ke Dashboard"),
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
