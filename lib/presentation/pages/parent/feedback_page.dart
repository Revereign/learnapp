import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/parent/feedback/feedback_bloc.dart';
import '../../blocs/parent/feedback/feedback_event.dart';
import '../../blocs/parent/feedback/feedback_state.dart';

class FeedbackPage extends StatelessWidget {
  final String parentUid;

  const FeedbackPage({
    super.key,
    required this.parentUid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedbackBloc(
        firestore: FirebaseFirestore.instance,
      ),
      child: FeedbackView(parentUid: parentUid),
    );
  }
}

class FeedbackView extends StatefulWidget {
  final String parentUid;

  const FeedbackView({
    super.key,
    required this.parentUid,
  });

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback berhasil dikirim')),
          );
          Navigator.pop(context);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text('Beri Feedback'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Feedback Materi Pembelajaran',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Berikan masukan Anda tentang materi pembelajaran yang ada',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Field feedback
                        TextFormField(
                          controller: _feedbackController,
                          decoration: const InputDecoration(
                            labelText: 'Feedback Anda',
                            hintText: 'Tuliskan feedback Anda di sini...',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 8,
                          onChanged: (val) => context
                              .read<FeedbackBloc>()
                              .add(FeedbackTextChanged(val)),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Feedback wajib diisi' : null,
                        ),
                        const SizedBox(height: 30),
                        
                        // Tombol kirim
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<FeedbackBloc>()
                                    .add(SubmitFeedback(widget.parentUid));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Kirim Feedback',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
