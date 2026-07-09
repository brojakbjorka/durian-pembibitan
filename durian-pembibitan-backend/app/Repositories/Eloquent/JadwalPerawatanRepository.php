<?php

namespace App\Repositories\Eloquent;

use App\Models\JadwalPerawatan;
use App\Repositories\Contracts\JadwalPerawatanRepositoryInterface;

class JadwalPerawatanRepository extends BaseRepository implements JadwalPerawatanRepositoryInterface
{
    public function __construct(JadwalPerawatan $model)
    {
        parent::__construct($model);
    }

    public function getPendingSchedules()
    {
        return $this->model->where('status_pelaksanaan', 'Belum Selesai')
                           ->orderBy('tanggal_jadwal', 'asc')
                           ->get();
    }

    public function getByBibitId(string $bibitId)
    {
        return $this->model->where('bibit_id', $bibitId)->orderBy('tanggal_jadwal', 'desc')->get();
    }
}
