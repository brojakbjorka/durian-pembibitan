<?php

namespace App\Services;

use App\Repositories\Contracts\JadwalPerawatanRepositoryInterface;

class JadwalPerawatanService
{
    protected JadwalPerawatanRepositoryInterface $jadwalRepository;

    public function __construct(JadwalPerawatanRepositoryInterface $jadwalRepository)
    {
        $this->jadwalRepository = $jadwalRepository;
    }

    public function getAll()
    {
        return $this->jadwalRepository->all();
    }

    public function getById(string $id)
    {
        return $this->jadwalRepository->find($id);
    }

    public function getByBibit(string $bibitId)
    {
        return $this->jadwalRepository->getByBibitId($bibitId);
    }

    public function getPending()
    {
        return $this->jadwalRepository->getPendingSchedules();
    }

    public function create(array $data)
    {
        return $this->jadwalRepository->create($data);
    }

    public function update(string $id, array $data)
    {
        return $this->jadwalRepository->update($id, $data);
    }

    public function delete(string $id)
    {
        return $this->jadwalRepository->delete($id);
    }
}
