<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\OkulasiRequest;
use App\Http\Resources\OkulasiResource;
use App\Services\OkulasiService;
use App\Traits\ApiResponse;

class OkulasiController extends Controller
{
    use ApiResponse;

    protected OkulasiService $okulasiService;

    public function __construct(OkulasiService $okulasiService)
    {
        $this->okulasiService = $okulasiService;
    }

    public function index()
    {
        $okulasis = $this->okulasiService->getAll();
        return $this->successResponse(OkulasiResource::collection($okulasis), 'Data okulasi berhasil diambil.');
    }

    public function store(OkulasiRequest $request)
    {
        $okulasi = $this->okulasiService->create($request->validated());
        return $this->successResponse(new OkulasiResource($okulasi), 'Okulasi berhasil ditambahkan.', 201);
    }

    public function show(string $id)
    {
        $okulasi = $this->okulasiService->getById($id);
        $okulasi->load('bibit');
        return $this->successResponse(new OkulasiResource($okulasi), 'Detail okulasi berhasil diambil.');
    }

    public function update(OkulasiRequest $request, string $id)
    {
        $okulasi = $this->okulasiService->update($id, $request->validated());
        return $this->successResponse(new OkulasiResource($okulasi), 'Okulasi berhasil diperbarui.');
    }

    public function destroy(string $id)
    {
        $this->okulasiService->delete($id);
        return $this->successResponse(null, 'Okulasi berhasil dihapus.');
    }
}
