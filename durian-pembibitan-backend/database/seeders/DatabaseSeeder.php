<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Bibit;
use App\Models\KatalogDaun;
use App\Models\Okulasi;
use App\Models\JadwalPerawatan;
use App\Models\RiwayatPerkembangan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed Users
        $admin = User::create([
            'name' => 'Admin Nursery',
            'email' => 'admin@nursery.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        $petani = User::create([
            'name' => 'Petani Durian',
            'email' => 'petani@nursery.com',
            'password' => Hash::make('password123'),
            'role' => 'petani',
        ]);

        // 2. Seed Katalog Daun
        $daunMusangKing = KatalogDaun::create([
            'varietas' => 'Musang King',
            'deskripsi' => 'Daun durian Musang King berbentuk lonjong panjang dengan ujung yang runcing (tapering). Permukaan daun bagian atas memiliki kilau hijau gelap yang khas.',
            'ciri_khas' => 'Warna bagian bawah daun berwarna keperakan atau keemasan di bawah sinar matahari. Tepi daun rata dan melengkung mulus.',
            'foto_daun_url' => 'katalog/musang_king.jpg',
        ]);

        $daunBawor = KatalogDaun::create([
            'varietas' => 'Bawor',
            'deskripsi' => 'Daun durian Bawor cenderung lebih lebar, tebal, dan berbentuk bulat telur terbalik. Memiliki struktur helai daun yang kokoh.',
            'ciri_khas' => 'Ujung daun membulat dengan duri kecil. Daun lebih kaku dan tebal dibandingkan varietas lainnya dengan warna hijau pekat.',
            'foto_daun_url' => 'katalog/bawor.jpg',
        ]);

        $daunMontong = KatalogDaun::create([
            'varietas' => 'Montong',
            'deskripsi' => 'Daun durian Montong berbentuk memanjang lebar dan sedikit melengkung ke bawah. Struktur helai daun agak tipis.',
            'ciri_khas' => 'Warna daun cenderung hijau muda kekuningan. Tepi daun bergelombang jelas dengan ujung runcing tajam.',
            'foto_daun_url' => 'katalog/montong.jpg',
        ]);

        $daunD24 = KatalogDaun::create([
            'varietas' => 'D24',
            'deskripsi' => 'Daun durian D24 memiliki bentuk oval bulat dengan ukuran sedang, tidak terlalu panjang.',
            'ciri_khas' => 'Daun cenderung melengkung ke dalam menyerupai mangkok kecil. Warna daun hijau muda segar dan mengkilap.',
            'foto_daun_url' => 'katalog/d24.jpg',
        ]);

        // 3. Seed Bibit
        $bibit1 = Bibit::create([
            'kode_bibit' => 'MK-001',
            'varietas' => 'Musang King',
            'tanggal_tanam' => '2026-01-15',
            'status' => 'Sehat',
            'lokasi_blok' => 'Blok A-01',
            'latitude' => -7.5641,
            'longitude' => 110.8251,
            'foto_url' => null,
        ]);

        $bibit2 = Bibit::create([
            'kode_bibit' => 'BW-001',
            'varietas' => 'Bawor',
            'tanggal_tanam' => '2026-02-10',
            'status' => 'Sehat',
            'lokasi_blok' => 'Blok B-03',
            'latitude' => -7.5645,
            'longitude' => 110.8258,
            'foto_url' => null,
        ]);

        $bibit3 = Bibit::create([
            'kode_bibit' => 'MT-001',
            'varietas' => 'Montong',
            'tanggal_tanam' => '2026-03-01',
            'status' => 'Sakit',
            'lokasi_blok' => 'Blok C-02',
            'latitude' => -7.5638,
            'longitude' => 110.8245,
            'foto_url' => null,
        ]);

        // 4. Seed Okulasi
        Okulasi::create([
            'bibit_id' => $bibit1->id,
            'tanggal_okulasi' => '2026-02-15',
            'entres_varietas' => 'Musang King Super',
            'status_keberhasilan' => 'Berhasil',
            'catatan' => 'Okulasi tumbuh dengan baik, tunas entres telah berkembang sekitar 10cm.',
        ]);

        Okulasi::create([
            'bibit_id' => $bibit3->id,
            'tanggal_okulasi' => '2026-04-10',
            'entres_varietas' => 'Montong Jingga',
            'status_keberhasilan' => 'Proses',
            'catatan' => 'Plester okulasi terpasang dengan baik, sedang menunggu pecah mata tunas.',
        ]);

        // 5. Seed Jadwal Perawatan
        JadwalPerawatan::create([
            'bibit_id' => $bibit1->id,
            'jenis_perawatan' => 'Penyiraman',
            'tanggal_jadwal' => '2026-07-09',
            'status_pelaksanaan' => 'Belum Selesai',
            'catatan' => 'Lakukan penyiraman pagi dan sore hari.',
        ]);

        JadwalPerawatan::create([
            'bibit_id' => $bibit2->id,
            'jenis_perawatan' => 'Pemupukan NPK',
            'tanggal_jadwal' => '2026-07-10',
            'status_pelaksanaan' => 'Belum Selesai',
            'catatan' => 'Dosis 10 gram per bibit, ditaburkan melingkar di sekeliling tajuk.',
        ]);

        JadwalPerawatan::create([
            'bibit_id' => $bibit3->id,
            'jenis_perawatan' => 'Penyemprotan Fungisida',
            'tanggal_jadwal' => '2026-07-08',
            'status_pelaksanaan' => 'Selesai',
            'catatan' => 'Penyemprotan untuk mengatasi jamur pada daun yang sakit.',
        ]);

        // 6. Seed Riwayat Perkembangan
        RiwayatPerkembangan::create([
            'bibit_id' => $bibit1->id,
            'tanggal_catat' => '2026-02-15',
            'tinggi_cm' => 30,
            'jumlah_daun' => 12,
            'kondisi_batang' => 'Kokoh, Hijau',
            'foto_perkembangan_url' => null,
            'catatan' => 'Perkembangan awal setelah tanam.',
        ]);

        RiwayatPerkembangan::create([
            'bibit_id' => $bibit1->id,
            'tanggal_catat' => '2026-05-15',
            'tinggi_cm' => 55,
            'jumlah_daun' => 28,
            'kondisi_batang' => 'Sangat Kokoh, Mulai Mencokelat',
            'foto_perkembangan_url' => null,
            'catatan' => 'Pertumbuhan cepat setelah okulasi berhasil.',
        ]);
    }
}
