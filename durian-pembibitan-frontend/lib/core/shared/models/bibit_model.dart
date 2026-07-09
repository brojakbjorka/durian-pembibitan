class BibitModel {
  final String id;
  final String kodeBibit;
  final String varietas;
  final String tanggalTanam;
  final String status;
  final String lokasiBlok;
  final double? latitude;
  final double? longitude;
  final String? fotoUrl;

  BibitModel({
    required this.id,
    required this.kodeBibit,
    required this.varietas,
    required this.tanggalTanam,
    required this.status,
    required this.lokasiBlok,
    this.latitude,
    this.longitude,
    this.fotoUrl,
  });

  factory BibitModel.fromJson(Map<String, dynamic> json) {
    return BibitModel(
      id: json['id'] ?? '',
      kodeBibit: json['kode_bibit'] ?? '',
      varietas: json['varietas'] ?? '',
      tanggalTanam: json['tanggal_tanam'] ?? '',
      status: json['status'] ?? 'Sehat',
      lokasiBlok: json['lokasi_blok'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      fotoUrl: json['foto_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_bibit': kodeBibit,
      'varietas': varietas,
      'tanggal_tanam': tanggalTanam,
      'status': status,
      'lokasi_blok': lokasiBlok,
      'latitude': latitude,
      'longitude': longitude,
      'foto_url': fotoUrl,
    };
  }
}
