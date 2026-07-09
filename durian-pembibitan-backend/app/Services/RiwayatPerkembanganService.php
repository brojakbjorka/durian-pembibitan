<?php

namespace App\Services;

use App\Repositories\Contracts\RiwayatPerkembanganRepositoryInterface;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class RiwayatPerkembanganService
{
    protected RiwayatPerkembanganRepositoryInterface $riwayatRepository;

    public function __construct(RiwayatPerkembanganRepositoryInterface $riwayatRepository)
    {
        $this->riwayatRepository = $riwayatRepository;
    }

    public function getAll()
    {
        return $this->riwayatRepository->all();
    }

    public function getById(string $id)
    {
        return $this->riwayatRepository->find($id);
    }

    public function getByBibit(string $bibitId)
    {
        return $this->riwayatRepository->getByBibitId($bibitId);
    }

    public function getLatest(string $bibitId)
    {
        return $this->riwayatRepository->getLatestPerkembangan($bibitId);
    }

    public function create(array $data)
    {
        if (isset($data['foto']) && $data['foto'] instanceof \Illuminate\Http\UploadedFile) {
            $file = $data['foto'];
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('perkembangan', $filename, 'public');
            $data['foto_perkembangan_url'] = 'storage/' . $path;
        }
        unset($data['foto']);

        return $this->riwayatRepository->create($data);
    }

    public function update(string $id, array $data)
    {
        $riwayat = $this->riwayatRepository->find($id);

        if (isset($data['foto']) && $data['foto'] instanceof \Illuminate\Http\UploadedFile) {
            if ($riwayat->foto_perkembangan_url && Storage::disk('public')->exists(str_replace('storage/', '', $riwayat->foto_perkembangan_url))) {
                Storage::disk('public')->delete(str_replace('storage/', '', $riwayat->foto_perkembangan_url));
            }

            $file = $data['foto'];
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('perkembangan', $filename, 'public');
            $data['foto_perkembangan_url'] = 'storage/' . $path;
        }
        unset($data['foto']);

        return $this->riwayatRepository->update($id, $data);
    }

    public function delete(string $id)
    {
        return $this->riwayatRepository->delete($id);
    }
}
