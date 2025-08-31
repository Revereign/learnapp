import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/prompt.dart';
import '../../blocs/prompt/prompt_bloc.dart';
import '../../blocs/prompt/prompt_event.dart';
import '../../blocs/prompt/prompt_state.dart';

class KelolaPromptPage extends StatefulWidget {
  const KelolaPromptPage({super.key});

  @override
  State<KelolaPromptPage> createState() => _KelolaPromptPageState();
}

class _KelolaPromptPageState extends State<KelolaPromptPage> {
  final TextEditingController _promptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<PromptBloc>().add(GetPromptEvent());
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _savePrompt() {
    if (_formKey.currentState!.validate()) {
      final prompt = Prompt(
        id: 'H2oet3Fw2gM3rtyL7GZb',
        promptOrder: _promptController.text.trim(),
      );
      context.read<PromptBloc>().add(UpdatePromptEvent(prompt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Kelola Prompt LLM'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<PromptBloc, PromptState>(
        listener: (context, state) {
          if (state is PromptUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prompt berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PromptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<PromptBloc, PromptState>(
          builder: (context, state) {
            if (state is PromptLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PromptLoaded) {
              _promptController.text = state.prompt.promptOrder;
              return _buildForm();
            } else if (state is PromptError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PromptBloc>().add(GetPromptEvent());
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: Text('Tidak ada data'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prompt LLM',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan prompt untuk hasil kalimat yang akan dibuat oleh LLM dalam aplikasi ini.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _promptController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Prompt LLM',
                hintText: 'Masukkan prompt LLM di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Prompt tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _savePrompt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save),
                    const SizedBox(width: 8),
                    Text(
                      'Simpan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tambahkan padding bottom untuk menghindari keyboard
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
