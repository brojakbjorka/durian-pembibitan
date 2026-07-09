<?php

namespace App\Repositories\Contracts;

interface RiwayatPerkembanganRepositoryInterface extends RepositoryInterface
{
    public function getByBibitId(string $bibitId);
    public function getLatestPerkembangan(string $bibitId);
}
