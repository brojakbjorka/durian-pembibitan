import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/shared/providers.dart';

class FarmerLogsScreen extends ConsumerWidget {
  const FarmerLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsFuture = ref.watch(farmerLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas Saya'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(farmerLogsProvider);
        },
        child: logsFuture.when(
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(child: Text('Belum ada log aktivitas.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: log.status == 'Sukses' ? Colors.green[50] : Colors.red[50],
                      child: Icon(
                        log.status == 'Sukses' ? Icons.check_circle_outline : Icons.error_outline,
                        color: log.status == 'Sukses' ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text('${log.aktivitas} - ${log.modul}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('IP: ${log.ip} | Device: ${log.device}'),
                        Text('Waktu: ${log.timestamp}'),
                      ],
                    ),
                    trailing: Text(
                      log.status,
                      style: TextStyle(
                        color: log.status == 'Sukses' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Gagal memuat log audit: $e')),
        ),
      ),
    );
  }
}
