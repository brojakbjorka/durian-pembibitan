class RiwayatPerkembanganModel {
  final String id;
  final String bibitId;
  final String tanggalCatat;
  final int tinggiCm;
  final int jumlahDaun;
  final String kondisiBatang;
  final String? fotoPerkembanganUrl;
  final String? catatan;

  RiwayatPerkembanganModel({
    required this.id,
    required this.bibitId,
    required this.tanggalCatat,
    required this.tinggiCm,
    required this.jumlahDaun,
    required this.kondisiBatang,
    this.fotoPerkembanganUrl,
    this.catatan,
  });

  factory RiwayatPerkembanganModel.fromJson(Map<String, dynamic> json) {
    return RiwayatPerkembanganModel(
      id: json['id'] ?? '',
      bibitId: json['bibit_id'] ?? '',
      tanggalCatat: json['tanggal_catat'] ?? '',
      tinggiCm: json['tinggi_cm'] ?? 0,
      jumlahDaun: json['jumlah_daun'] ?? 0,
      kondisiBatang: json['kondisi_batang'] ?? '',
      fotoPerkembanganUrl: json['foto_perkembangan_url'],
      catatan: json['catatan'],
    );
  }
}
