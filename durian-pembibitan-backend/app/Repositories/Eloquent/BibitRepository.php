<?php

namespace App\Repositories\Eloquent;

use App\Models\Bibit;
use App\Models\JadwalPerawatan;
use App\Models\Okulasi;
use App\Repositories\Contracts\BibitRepositoryInterface;

class BibitRepository extends BaseRepository implements BibitRepositoryInterface
{
    public function __construct(Bibit $model)
    {
        parent::__construct($model);
    }

    public function findByKodeBibit(string $kodeBibit)
    {
        return $this->model->where('kode_bibit', $kodeBibit)->first();
    }

    public function getMapCoordinates()
    {
        return $this->model->whereNotNull('latitude')
                           ->whereNotNull('longitude')
                           ->get(['id', 'kode_bibit', 'varietas', 'status', 'latitude', 'longitude', 'lokasi_blok']);
    }

    public function getDashboardStats()
    {
        return [
            'total_bibit' => $this->model->count(),
            'sehat_count' => $this->model->where('status', 'Sehat')->count(),
            'sakit_count' => $this->model->where('status', 'Sakit')->count(),
            'mati_count' => $this->model->where('status', 'Mati')->count(),
            'total_okulasi' => Okulasi::count(),
            'pending_perawatan' => JadwalPerawatan::where('status_pelaksanaan', 'Belum Selesai')->count(),
        ];
    }
}
