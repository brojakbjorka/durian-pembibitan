import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/shared/providers.dart';

class PetaniDashboardScreen extends ConsumerWidget {
  const PetaniDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsFuture = ref.watch(dashboardStatsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                color: const Color(0xFFE8F5E9), // Light green tint
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF2E7D32),
                        child: Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang, ${authState.name ?? "Petani"}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const Text(
                              'Operator Utama Pembibitan Durian',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Section
              const Text(
                'Ringkasan Pembibitan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 12),

              statsFuture.when(
                data: (stats) => GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard('Total Bibit', stats['total_bibit']?.toString() ?? '0', Colors.blue),
                    _buildStatCard('Bibit Sehat', stats['sehat_count']?.toString() ?? '0', const Color(0xFF2E7D32)),
                    _buildStatCard('Bibit Sakit', stats['sakit_count']?.toString() ?? '0', Colors.orange),
                    _buildStatCard('Bibit Mati', stats['mati_count']?.toString() ?? '0', Colors.grey),
                    _buildStatCard('Okulasi', stats['total_okulasi']?.toString() ?? '0', const Color(0xFF795548)),
                    _buildStatCard('Pekerjaan', stats['pending_perawatan']?.toString() ?? '0', Colors.red),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Gagal memuat statistik: $e'),
              ),

              const SizedBox(height: 24),

              // Main Modules
              const Text(
                'Modul Operasional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMenuCard(
                    context,
                    'Master Bibit',
                    'Kelola stok & data bibit durian',
                    Icons.grass,
                    const Color(0xFF2E7D32),
                    () => context.push('/bibits'),
                  ),
                  _buildMenuCard(
                    context,
                    'Peta Lokasi',
                    'Lihat persebaran bibit di blok',
                    Icons.map,
                    Colors.teal,
                    () => context.push('/map'),
                  ),
                  _buildMenuCard(
                    context,
                    'Hasil Okulasi',
                    'Perkembangan tunas & sambungan',
                    Icons.call_split,
                    const Color(0xFF795548),
                    () => context.push('/okulasi'),
                  ),
                  _buildMenuCard(
                    context,
                    'Jadwal Perawatan',
                    'Penyiraman, pemupukan & semprot',
                    Icons.calendar_month,
                    Colors.orange,
                    () => context.push('/jadwal'),
                  ),
                  _buildMenuCard(
                    context,
                    'Perkembangan',
                    'Tinggi, jumlah daun & batang',
                    Icons.trending_up,
                    Colors.blue,
                    () => context.push('/riwayat'),
                  ),
                  _buildMenuCard(
                    context,
                    'Katalog Daun',
                    'Identifikasi & varietas daun',
                    Icons.chrome_reader_mode,
                    Colors.indigo,
                    () => context.push('/katalog'),
                  ),
                  _buildMenuCard(
                    context,
                    'Log Audit Saya',
                    'Riwayat aktivitas Anda',
                    Icons.history_edu,
                    Colors.blueGrey,
                    () => context.push('/my-logs'),
                  ),
                  _buildMenuCard(
                    context,
                    'Profil Saya',
                    'Ubah profil & kata sandi',
                    Icons.manage_accounts,
                    Colors.deepPurple,
                    () => context.push('/profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: color),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
