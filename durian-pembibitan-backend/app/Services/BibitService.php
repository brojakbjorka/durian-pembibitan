<?php

namespace App\Services;

use App\Repositories\Contracts\BibitRepositoryInterface;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class BibitService
{
    protected BibitRepositoryInterface $bibitRepository;

    public function __construct(BibitRepositoryInterface $bibitRepository)
    {
        $this->bibitRepository = $bibitRepository;
    }

    public function getAll()
    {
        return $this->bibitRepository->all();
    }

    public function getById(string $id)
    {
        return $this->bibitRepository->find($id);
    }

    public function create(array $data)
    {
        if (isset($data['foto']) && $data['foto'] instanceof \Illuminate\Http\UploadedFile) {
            $file = $data['foto'];
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('bibits', $filename, 'public');
            $data['foto_url'] = 'storage/' . $path;
        }
        unset($data['foto']);

        return $this->bibitRepository->create($data);
    }

    public function update(string $id, array $data)
    {
        $bibit = $this->bibitRepository->find($id);

        if (isset($data['foto']) && $data['foto'] instanceof \Illuminate\Http\UploadedFile) {
            // Delete old photo if exists
            if ($bibit->foto_url && Storage::disk('public')->exists(str_replace('storage/', '', $bibit->foto_url))) {
                Storage::disk('public')->delete(str_replace('storage/', '', $bibit->foto_url));
            }

            $file = $data['foto'];
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('bibits', $filename, 'public');
            $data['foto_url'] = 'storage/' . $path;
        }
        unset($data['foto']);

        return $this->bibitRepository->update($id, $data);
    }

    public function delete(string $id)
    {
        return $this->bibitRepository->delete($id);
    }

    public function getMapCoords()
    {
        return $this->bibitRepository->getMapCoordinates();
    }

    public function getDashboardStats()
    {
        return $this->bibitRepository->getDashboardStats();
    }
}
