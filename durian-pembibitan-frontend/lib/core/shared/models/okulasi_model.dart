class OkulasiModel {
  final String id;
  final String bibitId;
  final String tanggalOkulasi;
  final String entresVarietas;
  final String statusKeberhasilan;
  final String? catatan;

  OkulasiModel({
    required this.id,
    required this.bibitId,
    required this.tanggalOkulasi,
    required this.entresVarietas,
    required this.statusKeberhasilan,
    this.catatan,
  });

  factory OkulasiModel.fromJson(Map<String, dynamic> json) {
    return OkulasiModel(
      id: json['id'] ?? '',
      bibitId: json['bibit_id'] ?? '',
      tanggalOkulasi: json['tanggal_okulasi'] ?? '',
      entresVarietas: json['entres_varietas'] ?? '',
      statusKeberhasilan: json['status_keberhasilan'] ?? 'Proses',
      catatan: json['catatan'],
    );
  }
}
