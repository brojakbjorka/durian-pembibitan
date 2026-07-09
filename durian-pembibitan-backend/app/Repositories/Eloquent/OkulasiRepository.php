<?php

namespace App\Repositories\Eloquent;

use App\Models\Okulasi;
use App\Repositories\Contracts\OkulasiRepositoryInterface;

class OkulasiRepository extends BaseRepository implements OkulasiRepositoryInterface
{
    public function __construct(Okulasi $model)
    {
        parent::__construct($model);
    }

    public function getByBibitId(string $bibitId)
    {
        return $this->model->where('bibit_id', $bibitId)->orderBy('tanggal_okulasi', 'desc')->get();
    }
}
