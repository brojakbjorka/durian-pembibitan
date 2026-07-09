<?php

namespace App\Repositories\Contracts;

interface OkulasiRepositoryInterface extends RepositoryInterface
{
    public function getByBibitId(string $bibitId);
}
