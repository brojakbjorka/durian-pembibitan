<?php

namespace App\Repositories\Contracts;

interface RepositoryInterface
{
    public function all();
    public function find(string|int $id);
    public function create(array $data);
    public function update(string|int $id, array $data);
    public function delete(string|int $id);
    public function findWithTrashed(string|int $id);
    public function restore(string|int $id);
}
