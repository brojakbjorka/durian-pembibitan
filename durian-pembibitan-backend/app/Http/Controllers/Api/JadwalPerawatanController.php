<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\JadwalPerawatanRequest;
use App\Http\Resources\JadwalPerawatanResource;
use App\Services\JadwalPerawatanService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class JadwalPerawatanController extends Controller
{
    use ApiResponse;

    protected JadwalPerawatanService $jadwalService;

    public function __construct(JadwalPerawatanService $jadwalService)
    {
        $this->jadwalService = $jadwalService;
    }

    public function index(Request $request)
    {
        if ($request->has('pending')) {
            $jadwals = $this->jadwalService->getPending();
        } else {
            $jadwals = $this->jadwalService->getAll();
        }
        return $this->successResponse(JadwalPerawatanResource::collection($jadwals), 'Data jadwal perawatan berhasil diambil.');
    }

    public function store(JadwalPerawatanRequest $request)
    {
        $jadwal = $this->jadwalService->create($request->validated());
        return $this->successResponse(new JadwalPerawatanResource($jadwal), 'Jadwal perawatan berhasil ditambahkan.', 201);
    }

    public function show(string $id)
    {
        $jadwal = $this->jadwalService->getById($id);
        $jadwal->load('bibit');
        return $this->successResponse(new JadwalPerawatanResource($jadwal), 'Detail jadwal perawatan berhasil diambil.');
    }

    public function update(JadwalPerawatanRequest $request, string $id)
    {
        $jadwal = $this->jadwalService->update($id, $request->validated());
        return $this->successResponse(new JadwalPerawatanResource($jadwal), 'Jadwal perawatan berhasil diperbarui.');
    }

    public function destroy(string $id)
    {
        $this->jadwalService->delete($id);
        return $this->successResponse(null, 'Jadwal perawatan berhasil dihapus.');
    }
}
