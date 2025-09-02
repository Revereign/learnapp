import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/usecases/auth/update_equip_badge.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../data/datasources/auth_remote_data_source.dart';

class MedalViewingPage extends StatefulWidget {
  const MedalViewingPage({super.key});

  @override
  State<MedalViewingPage> createState() => _MedalViewingPageState();
}

class _MedalViewingPageState extends State<MedalViewingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final UpdateEquipBadge _updateEquipBadge;
  
  List<bool>? achievements;
  int? currentEquipBadge;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateEquipBadge = UpdateEquipBadge(
      AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(auth: FirebaseAuth.instance),
      ),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            achievements = data['achieve'] != null 
                ? List<bool>.from(data['achieve']) 
                : List.filled(6, false);
            currentEquipBadge = data['equipBadge'] ?? 0;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _updateBadge(int badgeIndex) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _updateEquipBadge(user.uid, badgeIndex);
        setState(() {
          currentEquipBadge = badgeIndex;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(badgeIndex == 0 ? 'Badge dilepas!' : 'Badge dipakai!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating badge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBadgeInfo(int badgeIndex) {
    final badgeInfo = [
      'Selesaikan Kuis Pada Semua Level Dengan Minimal Skor 5',
      'Selesaikan 5 Game Dengan Nilai Sempurna',
      'Selesaikan Semua Game Dengan Nilai Sempurna',
      'Selesaikan 3 Kuis Dengan Nilai Sempurna',
      'Selesaikan 7 Kuis Dengan Nilai Sempurna',
      'Selesaikan Semua Kuis dengan Nilai Sempurna',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue.shade600),
            const SizedBox(width: 10),
            Text(
              'Petunjuk',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        content: Text(
          badgeInfo[badgeIndex],
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade200,
                Colors.orange.shade200,
                Colors.red.shade200,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade200,
              Colors.orange.shade200,
              Colors.red.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Koleksi Medali',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final isUnlocked = achievements?[index] ?? false;
                      final isEquipped = currentEquipBadge == (index + 1);
                      
                      return _buildBadgeCard(
                        index + 1,
                        isUnlocked,
                        isEquipped,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(int badgeIndex, bool isUnlocked, bool isEquipped) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: isEquipped 
            ? Border.all(color: Colors.amber.shade600, width: 3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isUnlocked ? null : () => _showBadgeInfo(badgeIndex - 1),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/badges/badge_$badgeIndex.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          color: isUnlocked ? null : Colors.grey,
                          colorBlendMode: isUnlocked ? BlendMode.srcOver : BlendMode.saturation,
                        ),
                        if (!isUnlocked)
                          Container(
                            color: Colors.black.withOpacity(0.6),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Badge Title
                Text(
                  'Badge $badgeIndex',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.grey.shade800 : Colors.grey.shade500,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Action Button
                if (isUnlocked)
                  Container(
                    width: double.infinity,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isEquipped 
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _updateBadge(isEquipped ? 0 : badgeIndex),
                        child: Center(
                          child: Text(
                            isEquipped ? 'Lepas' : 'Pakai',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Terkunci',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
