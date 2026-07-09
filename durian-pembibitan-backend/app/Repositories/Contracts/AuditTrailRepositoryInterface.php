<?php

namespace App\Repositories\Contracts;

interface AuditTrailRepositoryInterface extends RepositoryInterface
{
    public function filterAndPaginate(array $filters, int $perPage = 15);
    public function getByUser(int $userId, int $perPage = 15);
}
