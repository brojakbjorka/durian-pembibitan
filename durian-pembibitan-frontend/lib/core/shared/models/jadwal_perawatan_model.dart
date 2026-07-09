class JadwalPerawatanModel {
  final String id;
  final String bibitId;
  final String jenisPerawatan;
  final String tanggalJadwal;
  final String statusPelaksanaan;
  final String? catatan;

  JadwalPerawatanModel({
    required this.id,
    required this.bibitId,
    required this.jenisPerawatan,
    required this.tanggalJadwal,
    required this.statusPelaksanaan,
    this.catatan,
  });

  factory JadwalPerawatanModel.fromJson(Map<String, dynamic> json) {
    return JadwalPerawatanModel(
      id: json['id'] ?? '',
      bibitId: json['bibit_id'] ?? '',
      jenisPerawatan: json['jenis_perawatan'] ?? '',
      tanggalJadwal: json['tanggal_jadwal'] ?? '',
      statusPelaksanaan: json['status_pelaksanaan'] ?? 'Belum Selesai',
      catatan: json['catatan'],
    );
  }
}
