<?php

namespace App\Repositories\Eloquent;

use App\Models\RiwayatPerkembangan;
use App\Repositories\Contracts\RiwayatPerkembanganRepositoryInterface;

class RiwayatPerkembanganRepository extends BaseRepository implements RiwayatPerkembanganRepositoryInterface
{
    public function __construct(RiwayatPerkembangan $model)
    {
        parent::__construct($model);
    }

    public function getByBibitId(string $bibitId)
    {
        return $this->model->where('bibit_id', $bibitId)->orderBy('tanggal_catat', 'desc')->get();
    }

    public function getLatestPerkembangan(string $bibitId)
    {
        return $this->model->where('bibit_id', $bibitId)->orderBy('tanggal_catat', 'desc')->first();
    }
}
