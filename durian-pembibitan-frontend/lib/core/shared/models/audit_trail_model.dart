class AuditTrailModel {
  final int id;
  final int? userId;
  final String userName;
  final String? email;
  final String? role;
  final String aktivitas;
  final String modul;
  final String? recordId;
  final String url;
  final String httpMethod;
  final String browser;
  final String device;
  final String ip;
  final String status;
  final String timestamp;

  AuditTrailModel({
    required this.id,
    this.userId,
    required this.userName,
    this.email,
    this.role,
    required this.aktivitas,
    required this.modul,
    this.recordId,
    required this.url,
    required this.httpMethod,
    required this.browser,
    required this.device,
    required this.ip,
    required this.status,
    required this.timestamp,
  });

  factory AuditTrailModel.fromJson(Map<String, dynamic> json) {
    return AuditTrailModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Tamu',
      email: json['email'],
      role: json['role'],
      aktivitas: json['aktivitas'] ?? '',
      modul: json['modul'] ?? '',
      recordId: json['record_id'],
      url: json['url'] ?? '',
      httpMethod: json['http_method'] ?? '',
      browser: json['browser'] ?? '',
      device: json['device'] ?? '',
      ip: json['ip'] ?? '',
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
