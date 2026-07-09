import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/shared/providers.dart';

class OkulasiListScreen extends ConsumerWidget {
  const OkulasiListScreen({super.key});

  void _deleteOkulasi(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Okulasi'),
        content: const Text('Apakah Anda yakin ingin menghapus data okulasi ini?'),
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
        final response = await dio.delete('/okulasi/$id');
        if (!context.mounted) return;
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Okulasi berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(okulasiListProvider);
          ref.invalidate(dashboardStatsProvider);
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus okulasi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final okulasiFuture = ref.watch(okulasiListProvider);
    final bibitsFuture = ref.watch(bibitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Okulasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Okulasi button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Okulasi & Budding',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/okulasi/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('TAMBAH'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Okulasi List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(okulasiListProvider);
                  ref.invalidate(bibitListProvider);
                },
                child: okulasiFuture.when(
                  data: (okulasis) {
                    if (okulasis.isEmpty) {
                      return const Center(child: Text('Belum ada data okulasi.'));
                    }

                    // Get bibits mapping to show code
                    final bibits = bibitsFuture.value ?? [];
                    final bibitMap = {for (var b in bibits) b.id: b.kodeBibit};

                    return ListView.builder(
                      itemCount: okulasis.length,
                      itemBuilder: (context, index) {
                        final okulasi = okulasis[index];
                        final kodeBibit = bibitMap[okulasi.bibitId] ?? 'Unknown Bibit';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              'Bibit: $kodeBibit',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Entres: ${okulasi.entresVarietas}'),
                                Text('Tanggal Okulasi: ${okulasi.tanggalOkulasi}'),
                                if (okulasi.catatan != null && okulasi.catatan!.isNotEmpty)
                                  Text('Catatan: ${okulasi.catatan}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(
                                    okulasi.statusKeberhasilan,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                  backgroundColor: okulasi.statusKeberhasilan == 'Berhasil'
                                      ? Colors.green
                                      : okulasi.statusKeberhasilan == 'Gagal'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => context.push('/okulasi/form?id=${okulasi.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteOkulasi(context, ref, okulasi.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Gagal memuat data okulasi: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
