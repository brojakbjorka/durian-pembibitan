<?php

namespace App\Repositories\Contracts;

interface KatalogDaunRepositoryInterface extends RepositoryInterface
{
    public function findByVarietas(string $varietas);
}
