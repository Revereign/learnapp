import '../../domain/entities/materi.dart';

class SampleData {
  static List<Materi> getSampleMateri() {
    return [
      // Level 1 - Kosakata Dasar
      Materi(
        id: '1_1',
        kosakata: '一',
        arti: 'Satu',
        level: 1,
      ),
      Materi(
        id: '1_2',
        kosakata: '二',
        arti: 'Dua',
        level: 1,
      ),
      Materi(
        id: '1_3',
        kosakata: '三',
        arti: 'Tiga',
        level: 1,
      ),
      Materi(
        id: '1_4',
        kosakata: '红色',
        arti: 'Merah',
        level: 1,
      ),
      Materi(
        id: '1_5',
        kosakata: '蓝色',
        arti: 'Biru',
        level: 1,
      ),
      Materi(
        id: '1_6',
        kosakata: '黄色',
        arti: 'Kuning',
        level: 1,
      ),

      // Level 2 - Keluarga dan Binatang
      Materi(
        id: '2_1',
        kosakata: '妈妈',
        arti: 'Ibu',
        level: 2,
      ),
      Materi(
        id: '2_2',
        kosakata: '爸爸',
        arti: 'Ayah',
        level: 2,
      ),
      Materi(
        id: '2_3',
        kosakata: '狗',
        arti: 'Anjing',
        level: 2,
      ),
      Materi(
        id: '2_4',
        kosakata: '猫',
        arti: 'Kucing',
        level: 2,
      ),
      Materi(
        id: '2_5',
        kosakata: '鸟',
        arti: 'Burung',
        level: 2,
      ),

      // Level 3 - Makanan dan Minuman
      Materi(
        id: '3_1',
        kosakata: '米饭',
        arti: 'Nasi',
        level: 3,
      ),
      Materi(
        id: '3_2',
        kosakata: '水',
        arti: 'Air',
        level: 3,
      ),
      Materi(
        id: '3_3',
        kosakata: '苹果',
        arti: 'Apel',
        level: 3,
      ),
      Materi(
        id: '3_4',
        kosakata: '面包',
        arti: 'Roti',
        level: 3,
      ),

      // Level 4 - Bagian Tubuh dan Pakaian
      Materi(
        id: '4_1',
        kosakata: '头',
        arti: 'Kepala',
        level: 4,
      ),
      Materi(
        id: '4_2',
        kosakata: '手',
        arti: 'Tangan',
        level: 4,
      ),
      Materi(
        id: '4_3',
        kosakata: '衣服',
        arti: 'Pakaian',
        level: 4,
      ),
      Materi(
        id: '4_4',
        kosakata: '鞋子',
        arti: 'Sepatu',
        level: 4,
      ),

      // Level 5 - Transportasi dan Tempat
      Materi(
        id: '5_1',
        kosakata: '汽车',
        arti: 'Mobil',
        level: 5,
      ),
      Materi(
        id: '5_2',
        kosakata: '学校',
        arti: 'Sekolah',
        level: 5,
      ),
      Materi(
        id: '5_3',
        kosakata: '家',
        arti: 'Rumah',
        level: 5,
      ),
      Materi(
        id: '5_4',
        kosakata: '公园',
        arti: 'Taman',
        level: 5,
      ),
    ];
  }
} 