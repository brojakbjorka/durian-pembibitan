import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/shared/providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _deleteUser(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: const Text('Apakah Anda yakin ingin menghapus pengguna ini? Tindakan ini mendukung Soft Delete.'),
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
        final response = await dio.delete('/users/$id');
        if (!context.mounted) return;
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengguna berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(userListProvider);
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus pengguna.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersFuture = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Card(
              color: Colors.blueGrey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 48, color: Colors.blueGrey),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sistem Administrator',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Manajemen Akun & Monitoring Audit Trail',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/audit'),
                      icon: const Icon(Icons.history_edu),
                      label: const Text('Audit Trail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Users List Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Pengguna Sistem',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin/users/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('TAMBAH USER'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Users List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userListProvider);
                },
                child: usersFuture.when(
                  data: (users) => ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.role == 'admin' ? Colors.blueGrey[100] : const Color(0xFFE8F5E9),
                            child: Icon(
                              user.role == 'admin' ? Icons.security : Icons.person,
                              color: user.role == 'admin' ? Colors.blueGrey[800] : const Color(0xFF2E7D32),
                            ),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(user.role.toUpperCase()),
                                backgroundColor: user.role == 'admin' ? Colors.blueGrey[50] : Colors.green[50],
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () => context.push('/admin/users/form?id=${user.id}'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteUser(context, ref, user.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Gagal memuat daftar pengguna: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
