import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'learning_report_page.dart';
import 'edit_child_profile_page.dart';

class ChildProgressMenuPage extends StatefulWidget {
  final String childUid;
  final String childName;

  const ChildProgressMenuPage({
    super.key,
    required this.childUid,
    required this.childName,
  });

  @override
  State<ChildProgressMenuPage> createState() => _ChildProgressMenuPageState();
}

class _ChildProgressMenuPageState extends State<ChildProgressMenuPage> {
  String _currentChildName = '';

  @override
  void initState() {
    super.initState();
    _currentChildName = widget.childName;
  }

  Future<bool> _refreshChildData() async {
    try {
      // Ambil data terbaru dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.childUid)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final newName = data['name'] ?? widget.childName;
        if (newName != _currentChildName) {
          setState(() {
            _currentChildName = newName;
          });
          return true; // Ada perubahan
        }
      }
      return false; // Tidak ada perubahan
    } catch (e) {
      print('Error refreshing child data: $e');
      return false;
    }
  }

  @override
  void dispose() {
    // Kembalikan true untuk menandakan ada perubahan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Akun Anak'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.child_care,
                      size: 60,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentChildName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Menu Options
              Expanded(
                child: Column(
                  children: [
                    _buildMenuCard(
                      context,
                      'Laporan Pembelajaran',
                      'Lihat data lengkap progress belajar anak',
                      Icons.assessment,
                      Colors.green.shade400,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearningReportPage(
                              childUid: widget.childUid,
                              childName: _currentChildName,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildMenuCard(
                      context,
                      'Edit Profil',
                      'Ubah data profil anak',
                      Icons.edit,
                      Colors.orange.shade400,
                      () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditChildProfilePage(
                              childUid: widget.childUid,
                              childName: _currentChildName,
                            ),
                          ),
                        );
                        
                        // Refresh data jika ada perubahan
                        if (result == true) {
                          final hasChanges = await _refreshChildData();
                          if (hasChanges) {
                            // Kembalikan true ke halaman sebelumnya
                            Navigator.pop(context, true);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
