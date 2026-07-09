import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../core/shared/providers.dart';
import '../../core/config/app_config.dart';

class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> {
  final _searchController = TextEditingController();
  String _selectedRole = '';
  String _selectedModul = '';
  final String _selectedAktivitas = '';
  String _selectedStatus = '';

  bool _isExporting = false;

  void _exportLogs() async {
    setState(() => _isExporting = true);
    try {
      final dio = ref.read(dioClientProvider).dio;

      final filters = {
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (_selectedRole.isNotEmpty) 'role': _selectedRole,
        if (_selectedModul.isNotEmpty) 'modul': _selectedModul,
        if (_selectedAktivitas.isNotEmpty) 'aktivitas': _selectedAktivitas,
        if (_selectedStatus.isNotEmpty) 'status': _selectedStatus,
      };

      final response = await dio.get(
        '/audit-trails/export',
        queryParameters: filters,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data as List<int>;
      final directory = await getTemporaryDirectory();
      final filename = 'audit_trail_nursery_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      // Fallback for Web: Open URL in external browser
      try {
        final token = await ref.read(secureStorageProvider).getToken();
        final queryParams = [
          'token=$token',
          if (_searchController.text.isNotEmpty) 'search=${_searchController.text}',
          if (_selectedRole.isNotEmpty) 'role=$_selectedRole',
          if (_selectedModul.isNotEmpty) 'modul=$_selectedModul',
          if (_selectedAktivitas.isNotEmpty) 'aktivitas=$_selectedAktivitas',
          if (_selectedStatus.isNotEmpty) 'status=$_selectedStatus',
        ].join('&');
        
        final urlString = '${AppConfig.baseUrl}/audit-trails/export?$queryParams';
        await launchUrl(Uri.parse(urlString), mode: LaunchMode.externalApplication);
      } catch (ex) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengekspor log: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = AdminLogsFilter(
      search: _searchController.text,
      role: _selectedRole,
      modul: _selectedModul,
      aktivitas: _selectedAktivitas,
      status: _selectedStatus,
    );

    final logsFuture = ref.watch(adminLogsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Audit Trail'),
        actions: [
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download, color: Colors.blueGrey),
                  tooltip: 'Ekspor CSV',
                  onPressed: _exportLogs,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari aktivitas, modul, email, browser, IP...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {
                // Trigger riverpod update dynamically
                setState(() {});
              },
            ),
            const SizedBox(height: 12),

            // Filters Grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Role filter
                _buildFilterDropdown(
                  'Role',
                  _selectedRole,
                  ['', 'admin', 'petani'],
                  (val) => setState(() => _selectedRole = val ?? ''),
                ),

                // Modul filter
                _buildFilterDropdown(
                  'Modul',
                  _selectedModul,
                  ['', 'Auth', 'Bibit', 'Okulasi', 'Jadwal', 'Perkembangan', 'Katalog Daun', 'User', 'Sistem'],
                  (val) => setState(() => _selectedModul = val ?? ''),
                ),

                // Status filter
                _buildFilterDropdown(
                  'Status',
                  _selectedStatus,
                  ['', 'Sukses', 'Gagal', 'Error'],
                  (val) => setState(() => _selectedStatus = val ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logs Table List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(adminLogsProvider);
                },
                child: logsFuture.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return const Center(child: Text('Tidak ada audit log yang sesuai.'));
                    }

                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: log.status == 'Sukses'
                                  ? Colors.green[50]
                                  : log.status == 'Gagal'
                                      ? Colors.orange[50]
                                      : Colors.red[50],
                              child: Icon(
                                log.status == 'Sukses'
                                    ? Icons.check_circle_outline
                                    : log.status == 'Gagal'
                                        ? Icons.warning_amber
                                        : Icons.error_outline,
                                color: log.status == 'Sukses'
                                    ? Colors.green
                                    : log.status == 'Gagal'
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                            title: Text('${log.aktivitas} [${log.modul}]'),
                            subtitle: Text('Oleh: ${log.email ?? "Guest"} (${log.role ?? "Guest"})'),
                            trailing: Text(
                              log.status,
                              style: TextStyle(
                                color: log.status == 'Sukses'
                                    ? Colors.green
                                    : log.status == 'Gagal'
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text('Waktu: ${log.timestamp}'),
                                    Text('URL: ${log.url} (${log.httpMethod})'),
                                    Text('Browser: ${log.browser}'),
                                    Text('Device: ${log.device}'),
                                    Text('IP Address: ${log.ip}'),
                                    if (log.recordId != null) Text('ID Record Terkait: ${log.recordId}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Gagal memuat log audit: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String hint,
    String currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          hint: Text(hint),
          items: items.map((val) {
            return DropdownMenuItem(
              value: val,
              child: Text(val.isEmpty ? 'Semua $hint' : val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
