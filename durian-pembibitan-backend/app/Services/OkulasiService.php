<?php

namespace App\Services;

use App\Repositories\Contracts\OkulasiRepositoryInterface;

class OkulasiService
{
    protected OkulasiRepositoryInterface $okulasiRepository;

    public function __construct(OkulasiRepositoryInterface $okulasiRepository)
    {
        $this->okulasiRepository = $okulasiRepository;
    }

    public function getAll()
    {
        return $this->okulasiRepository->all();
    }

    public function getById(string $id)
    {
        return $this->okulasiRepository->find($id);
    }

    public function getByBibit(string $bibitId)
    {
        return $this->okulasiRepository->getByBibitId($bibitId);
    }

    public function create(array $data)
    {
        return $this->okulasiRepository->create($data);
    }

    public function update(string $id, array $data)
    {
        return $this->okulasiRepository->update($id, $data);
    }

    public function delete(string $id)
    {
        return $this->okulasiRepository->delete($id);
    }
}
