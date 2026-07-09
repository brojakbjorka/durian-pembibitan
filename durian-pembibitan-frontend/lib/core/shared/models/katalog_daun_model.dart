class KatalogDaunModel {
  final String id;
  final String varietas;
  final String deskripsi;
  final String ciriKhas;
  final String? fotoDaunUrl;

  KatalogDaunModel({
    required this.id,
    required this.varietas,
    required this.deskripsi,
    required this.ciriKhas,
    this.fotoDaunUrl,
  });

  factory KatalogDaunModel.fromJson(Map<String, dynamic> json) {
    return KatalogDaunModel(
      id: json['id'] ?? '',
      varietas: json['varietas'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      ciriKhas: json['ciri_khas'] ?? '',
      fotoDaunUrl: json['foto_daun_url'],
    );
  }
}
