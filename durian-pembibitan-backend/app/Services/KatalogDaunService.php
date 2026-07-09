<?php

namespace App\Services;

use App\Repositories\Contracts\KatalogDaunRepositoryInterface;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class KatalogDaunService
{
    protected KatalogDaunRepositoryInterface $katalogDaunRepository;

    public function __construct(KatalogDaunRepositoryInterface $katalogDaunRepository)
    {
        $this->katalogDaunRepository = $katalogDaunRepository;
    }

    public function getAll()
    {
        return $this->katalogDaunRepository->all();
    }

    public function getById(string $id)
    {
        return $this->katalogDaunRepository->find($id);
    }

    public function create(array $data)
    {
        if (isset($data['foto_daun']) && $data['foto_daun'] instanceof \Illuminate\Http\UploadedFile) {
            $file = $data['foto_daun'];
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('katalog', $filename, 'public');
            $data['foto_daun_url'] = 'storage/' . $path;
        }
        unset($data['foto_daun']);

        return $this->katalogDaunRepository->create($data);
    }

    public function update(string $id, array $data)
    {
        $katalog = $this->katalogDaunRepository->find($id);

        if (isset($data['foto_daun']) && $data['foto_daun'] instanceof \Illuminate\Http\UploadedFile) {
            if ($katalog->foto_daun_url && Storage::disk('public')->exists(str_replace('storage/', '', $katalog->foto_daun_url))) {
                Storage::disk('public')->delete(str_replace('storage/', '', $katalog->foto_daun_url));
            }

            $file = $data['foto_daun'];
            $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('katalog', $filename, 'public');
            $data['foto_daun_url'] = 'storage/' . $path;
        }
        unset($data['foto_daun']);

        return $this->katalogDaunRepository->update($id, $data);
    }

    public function delete(string $id)
    {
        return $this->katalogDaunRepository->delete($id);
    }
}
