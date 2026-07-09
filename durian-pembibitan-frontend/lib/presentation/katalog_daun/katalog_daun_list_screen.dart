import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/shared/providers.dart';

class KatalogDaunListScreen extends ConsumerWidget {
  const KatalogDaunListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final katalogFuture = ref.watch(katalogDaunListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Daun Durian'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(katalogDaunListProvider);
        },
        child: katalogFuture.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('Tidak ada katalog daun.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Leaf Photo Placeholder / Dynamic Image
                      Container(
                        height: 180,
                        color: Colors.green[50],
                        child: item.fotoDaunUrl != null
                            ? Image.network(
                                item.fotoDaunUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Center(
                                  child: Icon(Icons.menu_book, size: 50, color: Color(0xFF2E7D32)),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.menu_book, size: 50, color: Color(0xFF2E7D32)),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.varietas,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Deskripsi Varietas:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.deskripsi,
                              style: const TextStyle(color: Colors.black87, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Ciri Khas Fisik Daun:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF795548)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.ciriKhas,
                              style: const TextStyle(color: Colors.black87, height: 1.4),
                            ),
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
          error: (e, s) => Center(child: Text('Gagal memuat katalog: $e')),
        ),
      ),
    );
  }
}
