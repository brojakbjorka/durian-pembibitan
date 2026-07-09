<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RiwayatPerkembanganRequest;
use App\Http\Resources\RiwayatPerkembanganResource;
use App\Services\RiwayatPerkembanganService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class RiwayatPerkembanganController extends Controller
{
    use ApiResponse;

    protected RiwayatPerkembanganService $riwayatService;

    public function __construct(RiwayatPerkembanganService $riwayatService)
    {
        $this->riwayatService = $riwayatService;
    }

    public function index(Request $request)
    {
        if ($request->has('bibit_id')) {
            $riwayats = $this->riwayatService->getByBibit($request->input('bibit_id'));
        } else {
            $riwayats = $this->riwayatService->getAll();
        }
        return $this->successResponse(RiwayatPerkembanganResource::collection($riwayats), 'Data riwayat perkembangan berhasil diambil.');
    }

    public function store(RiwayatPerkembanganRequest $request)
    {
        $data = $request->validated();
        if ($request->hasFile('foto')) {
            $data['foto'] = $request->file('foto');
        }
        $riwayat = $this->riwayatService->create($data);
        return $this->successResponse(new RiwayatPerkembanganResource($riwayat), 'Riwayat perkembangan berhasil ditambahkan.', 201);
    }

    public function show(string $id)
    {
        $riwayat = $this->riwayatService->getById($id);
        $riwayat->load('bibit');
        return $this->successResponse(new RiwayatPerkembanganResource($riwayat), 'Detail riwayat perkembangan berhasil diambil.');
    }

    public function update(RiwayatPerkembanganRequest $request, string $id)
    {
        $data = $request->validated();
        if ($request->hasFile('foto')) {
            $data['foto'] = $request->file('foto');
        }
        $riwayat = $this->riwayatService->update($id, $data);
        return $this->successResponse(new RiwayatPerkembanganResource($riwayat), 'Riwayat perkembangan berhasil diperbarui.');
    }

    public function destroy(string $id)
    {
        $this->riwayatService->delete($id);
        return $this->successResponse(null, 'Riwayat perkembangan berhasil dihapus.');
    }
}
