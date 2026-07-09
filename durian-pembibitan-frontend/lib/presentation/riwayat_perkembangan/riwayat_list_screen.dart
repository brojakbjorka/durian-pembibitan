import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/shared/providers.dart';

class RiwayatListScreen extends ConsumerStatefulWidget {
  final String bibitId;
  const RiwayatListScreen({super.key, required this.bibitId});

  @override
  ConsumerState<RiwayatListScreen> createState() => _RiwayatListScreenState();
}

class _RiwayatListScreenState extends ConsumerState<RiwayatListScreen> {
  late String _selectedBibitId;

  @override
  void initState() {
    super.initState();
    _selectedBibitId = widget.bibitId;
  }

  void _deleteRiwayat(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan perkembangan ini?'),
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
        final response = await dio.delete('/riwayat-perkembangan/$id');
        if (response.data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Catatan perkembangan berhasil dihapus.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          ref.invalidate(riwayatListProvider(_selectedBibitId));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus catatan.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final riwayatFuture = ref.watch(riwayatListProvider(_selectedBibitId));
    final bibitsFuture = ref.watch(bibitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Perkembangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bibit Selector & Add Button
            Row(
              children: [
                Expanded(
                  child: bibitsFuture.when(
                    data: (list) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedBibitId.isEmpty ? null : _selectedBibitId,
                        hint: const Text('Pilih Bibit untuk difilter'),
                        decoration: const InputDecoration(
                          labelText: 'Filter Bibit',
                          prefixIcon: Icon(Icons.grass),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Semua Bibit')),
                          ...list.map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text(b.kodeBibit),
                            );
                          })
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedBibitId = val ?? '';
                          });
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Gagal: $e'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/riwayat/form?bibitId=$_selectedBibitId');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('TAMBAH'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Riwayat List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(riwayatListProvider(_selectedBibitId));
                  ref.invalidate(bibitListProvider);
                },
                child: riwayatFuture.when(
                  data: (riwayats) {
                    if (riwayats.isEmpty) {
                      return const Center(child: Text('Belum ada riwayat perkembangan.'));
                    }

                    final bibits = bibitsFuture.value ?? [];
                    final bibitMap = {for (var b in bibits) b.id: b.kodeBibit};

                    return ListView.builder(
                      itemCount: riwayats.length,
                      itemBuilder: (context, index) {
                        final log = riwayats[index];
                        final kodeBibit = bibitMap[log.bibitId] ?? 'Unknown Bibit';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Photo
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: log.fotoPerkembanganUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            log.fotoPerkembanganUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, o, s) => const Icon(Icons.trending_up, color: Colors.blue),
                                          ),
                                        )
                                      : const Icon(Icons.trending_up, color: Colors.blue, size: 30),
                                ),
                                const SizedBox(width: 16),

                                // Metrics details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bibit: $kodeBibit',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Tinggi: ${log.tinggiCm} cm | Daun: ${log.jumlahDaun} helai'),
                                      Text('Batang: ${log.kondisiBatang}'),
                                      Text('Tanggal: ${log.tanggalCatat}'),
                                    ],
                                  ),
                                ),

                                // Actions
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () {
                                        context.push('/riwayat/form?id=${log.id}&bibitId=$_selectedBibitId');
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deleteRiwayat(log.id),
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
                  error: (e, s) => Center(child: Text('Gagal memuat riwayat: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
