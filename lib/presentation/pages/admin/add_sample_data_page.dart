import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/sample_data.dart';


class AddSampleDataPage extends StatefulWidget {
  const AddSampleDataPage({super.key});

  @override
  State<AddSampleDataPage> createState() => _AddSampleDataPageState();
}

class _AddSampleDataPageState extends State<AddSampleDataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _status = '';

  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _status = 'Menambahkan data sample...';
    });

    try {
      final sampleMateri = SampleData.getSampleMateri();
      int addedCount = 0;

      for (final materi in sampleMateri) {
        await _firestore.collection('materi').doc(materi.id).set({
          'id': materi.id,
          'kosakata': materi.kosakata,
          'arti': materi.arti,
          'level': materi.level,
          'gambarBase64': materi.gambarBase64,
          'createdAt': FieldValue.serverTimestamp(),
        });
        addedCount++;
        
        setState(() {
          _status = 'Menambahkan materi ${materi.kosakata} (${addedCount}/${sampleMateri.length})';
        });
      }

      setState(() {
        _isLoading = false;
        _status = 'Berhasil menambahkan $addedCount materi sample!';
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Berhasil'),
            content: Text('Berhasil menambahkan $addedCount materi sample ke Firebase!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Text('Gagal menambahkan data: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua data materi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _status = 'Menghapus semua data...';
    });

    try {
      final snapshot = await _firestore.collection('materi').get();
      int deletedCount = 0;

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
        
        setState(() {
          _status = 'Menghapus data... ($deletedCount/${snapshot.docs.length})';
        });
      }

      setState(() {
        _isLoading = false;
        _status = 'Berhasil menghapus $deletedCount data!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Tambah Data Sample'),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Sample Materi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Halaman ini akan menambahkan data sample materi pembelajaran bahasa Mandarin untuk testing aplikasi.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Data yang akan ditambahkan:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildLevelInfo('Level 1', 'Kosakata Dasar - Angka dan Warna', 6),
                    _buildLevelInfo('Level 2', 'Keluarga dan Binatang', 5),
                    _buildLevelInfo('Level 3', 'Makanan dan Minuman', 4),
                    _buildLevelInfo('Level 4', 'Bagian Tubuh dan Pakaian', 4),
                    _buildLevelInfo('Level 5', 'Transportasi dan Tempat', 4),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.blue.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isLoading ? Colors.blue : Colors.green,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _status,
                        style: TextStyle(
                          color: _isLoading ? Colors.blue.shade800 : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Data Sample',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.delete),
              label: const Text(
                'Hapus Semua Data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelInfo(String level, String description, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$level: $description ($count materi)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
} 