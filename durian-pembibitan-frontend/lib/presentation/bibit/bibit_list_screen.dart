import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../core/shared/providers.dart';
import '../../core/config/app_config.dart';

class BibitListScreen extends ConsumerStatefulWidget {
  const BibitListScreen({super.key});

  @override
  ConsumerState<BibitListScreen> createState() => _BibitListScreenState();
}

class _BibitListScreenState extends ConsumerState<BibitListScreen> {
  String _searchQuery = '';

  Future<void> _exportFile(String type) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get(
        '/bibits/export/$type',
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data as List<int>;
      final directory = await getTemporaryDirectory();
      final ext = type == 'excel' ? 'csv' : 'pdf';
      final filename = 'daftar_bibit_durian_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      // Fallback for Web/other platforms: Open in external browser
      try {
        final token = await ref.read(secureStorageProvider).getToken();
        final urlString = '${AppConfig.baseUrl}/bibits/export/$type?token=$token';
        await launchUrl(Uri.parse(urlString), mode: LaunchMode.externalApplication);
      } catch (ex) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengekspor file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteBibit(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bibit'),
        content: const Text('Apakah Anda yakin ingin menghapus data bibit ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dio = ref.read(dioClientProvider).dio;
        final response = await dio.delete('/bibits/$id');
        if (response.data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bibit berhasil dihapus.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          ref.invalidate(bibitListProvider);
          ref.invalidate(dashboardStatsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus bibit.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibitsFuture = ref.watch(bibitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Bibit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Cetak PDF',
            onPressed: () => _exportFile('pdf'),
          ),
          IconButton(
            icon: const Icon(Icons.grid_on, color: Colors.green),
            tooltip: 'Cetak Excel',
            onPressed: () => _exportFile('excel'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search & Add Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kode bibit atau varietas...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push('/bibits/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('TAMBAH'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bibit List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(bibitListProvider);
                },
                child: bibitsFuture.when(
                  data: (bibits) {
                    final filteredList = bibits.where((b) {
                      return b.kodeBibit.toLowerCase().contains(_searchQuery) ||
                          b.varietas.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredList.isEmpty) {
                      return const Center(child: Text('Tidak ada data bibit.'));
                    }

                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final bibit = filteredList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Photo / Icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: bibit.fotoUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            bibit.fotoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, o, s) => const Icon(Icons.grass, color: Colors.green),
                                          ),
                                        )
                                      : const Icon(Icons.grass, color: Colors.green, size: 40),
                                ),
                                const SizedBox(width: 16),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bibit.kodeBibit,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Varietas: ${bibit.varietas}'),
                                      Text('Lokasi: ${bibit.lokasiBlok}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: bibit.status == 'Sehat'
                                                ? Colors.green
                                                : bibit.status == 'Sakit'
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            bibit.status,
                                            style: TextStyle(
                                              color: bibit.status == 'Sehat'
                                                  ? Colors.green
                                                  : bibit.status == 'Sakit'
                                                      ? Colors.orange
                                                      : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () => context.push('/bibits/form?id=${bibit.id}'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deleteBibit(bibit.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Gagal memuat data bibit: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
