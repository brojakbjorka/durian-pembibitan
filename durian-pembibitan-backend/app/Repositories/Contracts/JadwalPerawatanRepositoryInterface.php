<?php

namespace App\Repositories\Contracts;

interface JadwalPerawatanRepositoryInterface extends RepositoryInterface
{
    public function getPendingSchedules();
    public function getByBibitId(string $bibitId);
}
