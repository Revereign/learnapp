import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/materi.dart';
import '../../blocs/materi/materi_bloc.dart';
import '../../blocs/materi/materi_event.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class MateriFormPage extends StatefulWidget {
  final Materi? existingMateri;
  final int level;

  const MateriFormPage({super.key, this.existingMateri, required this.level});

  @override
  State<MateriFormPage> createState() => _MateriFormPageState();
}

class _MateriFormPageState extends State<MateriFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kosakataController;
  late TextEditingController _artiController;
  String? _gambarBase64;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _kosakataController = TextEditingController(text: widget.existingMateri?.kosakata ?? '');
    _artiController = TextEditingController(text: widget.existingMateri?.arti ?? '');
    _gambarBase64 = widget.existingMateri?.gambarBase64;
  }

  @override
  void dispose() {
    _kosakataController.dispose();
    _artiController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final materi = Materi(
        id: widget.existingMateri?.id ?? '',
        kosakata: _kosakataController.text.trim(),
        arti: _artiController.text.trim(),
        level: widget.level,
        gambarBase64: _gambarBase64 ?? '',
      );

      if (widget.existingMateri == null) {
        context.read<MateriBloc>().add(AddMateriEvent(materi));
      } else {
        context.read<MateriBloc>().add(UpdateMateriEvent(materi));
      }

      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        final resized = img.copyResize(image, width: 200, height: 200);
        final resizedBytes = img.encodePng(resized);
        setState(() {
          _selectedImage = File(pickedFile.path);
          _gambarBase64 = base64Encode(resizedBytes);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMateri != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Materi' : 'Tambah Materi'),
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.yellow.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildAnimatedTextField(
                controller: _kosakataController,
                label: 'Kosakata Mandarin',
              ),
              const SizedBox(height: 16),
              _buildAnimatedTextField(
                controller: _artiController,
                label: 'Arti dalam Bahasa Indonesia',
              ),
              const SizedBox(height: 24),

              // Preview dan tombol pilih gambar
              Text('Gambar (200x200):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Center(
                child: _gambarBase64 != null
                    ? Image.memory(
                  base64Decode(_gambarBase64!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : const Text('Belum ada gambar'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEdit ? 'Simpan Perubahan' : 'Tambah Materi',
                  style: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Tidak boleh kosong';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
