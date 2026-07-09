<?php

namespace App\Repositories\Contracts;

interface BibitRepositoryInterface extends RepositoryInterface
{
    public function findByKodeBibit(string $kodeBibit);
    public function getMapCoordinates();
    public function getDashboardStats();
}
