<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\KatalogDaunResource;
use App\Services\KatalogDaunService;
use App\Traits\ApiResponse;

class KatalogDaunController extends Controller
{
    use ApiResponse;

    protected KatalogDaunService $katalogDaunService;

    public function __construct(KatalogDaunService $katalogDaunService)
    {
        $this->katalogDaunService = $katalogDaunService;
    }

    /**
     * Get leaf catalog list.
     */
    public function index()
    {
        $katalogs = $this->katalogDaunService->getAll();
        return $this->successResponse(KatalogDaunResource::collection($katalogs), 'Katalog daun berhasil diambil.');
    }

    /**
     * Get leaf catalog detail.
     */
    public function show(string $id)
    {
        $katalog = $this->katalogDaunService->getById($id);
        return $this->successResponse(new KatalogDaunResource($katalog), 'Detail katalog daun berhasil diambil.');
    }
}
