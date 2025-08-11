class Materi {
  final String id;
  final String kosakata;
  final String arti;
  final int level;
  final String? gambarBase64;

  Materi({
    required this.id,
    required this.kosakata,
    required this.arti,
    required this.level,
    this.gambarBase64,
  });
}
