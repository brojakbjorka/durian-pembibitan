import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/shared/providers.dart';
import '../../core/shared/models/jadwal_perawatan_model.dart';

class JadwalListScreen extends ConsumerWidget {
  const JadwalListScreen({super.key});

  void _markAsDone(BuildContext context, WidgetRef ref, JadwalPerawatanModel jadwal) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.put('/jadwal-perawatan/${jadwal.id}', data: {
        'bibit_id': jadwal.bibitId,
        'jenis_perawatan': jadwal.jenisPerawatan,
        'tanggal_jadwal': jadwal.tanggalJadwal,
        'status_pelaksanaan': 'Selesai',
        'catatan': jadwal.catatan,
      });

      if (!context.mounted) return;

      if (response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perawatan berhasil dilaksanakan!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(jadwalListProvider);
        ref.invalidate(dashboardStatsProvider);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyelesaikan perawatan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteJadwal(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal perawatan ini?'),
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
        final response = await dio.delete('/jadwal-perawatan/$id');
        if (!context.mounted) return;
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(jadwalListProvider);
          ref.invalidate(dashboardStatsProvider);
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus jadwal.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalFuture = ref.watch(jadwalListProvider);
    final bibitsFuture = ref.watch(bibitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Perawatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agenda Pemeliharaan Bibit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/jadwal/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('TAMBAH'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(jadwalListProvider);
                  ref.invalidate(bibitListProvider);
                },
                child: jadwalFuture.when(
                  data: (jadwals) {
                    if (jadwals.isEmpty) {
                      return const Center(child: Text('Tidak ada agenda perawatan.'));
                    }

                    final bibits = bibitsFuture.value ?? [];
                    final bibitMap = {for (var b in bibits) b.id: b.kodeBibit};

                    return ListView.builder(
                      itemCount: jadwals.length,
                      itemBuilder: (context, index) {
                        final jadwal = jadwals[index];
                        final kodeBibit = bibitMap[jadwal.bibitId] ?? 'Unknown Bibit';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              '${jadwal.jenisPerawatan} ($kodeBibit)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Tanggal: ${jadwal.tanggalJadwal}'),
                                if (jadwal.catatan != null && jadwal.catatan!.isNotEmpty)
                                  Text('Catatan: ${jadwal.catatan}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (jadwal.statusPelaksanaan == 'Belum Selesai')
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                    tooltip: 'Tandai Selesai',
                                    onPressed: () => _markAsDone(context, ref, jadwal),
                                  )
                                else
                                  const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => context.push('/jadwal/form?id=${jadwal.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteJadwal(context, ref, jadwal.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Gagal memuat jadwal: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
