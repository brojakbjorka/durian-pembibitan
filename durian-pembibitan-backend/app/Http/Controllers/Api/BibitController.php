<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\BibitStoreRequest;
use App\Http\Requests\BibitUpdateRequest;
use App\Http\Resources\BibitResource;
use App\Services\BibitService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;

class BibitController extends Controller
{
    use ApiResponse;

    protected BibitService $bibitService;

    public function __construct(BibitService $bibitService)
    {
        $this->bibitService = $bibitService;
    }

    /**
     * Display a listing of bibit.
     */
    public function index()
    {
        $bibits = $this->bibitService->getAll();
        return $this->successResponse(BibitResource::collection($bibits), 'Data bibit berhasil diambil.');
    }

    /**
     * Store a newly created bibit.
     */
    public function store(BibitStoreRequest $request)
    {
        $data = $request->validated();
        if ($request->hasFile('foto')) {
            $data['foto'] = $request->file('foto');
        }
        $bibit = $this->bibitService->create($data);
        return $this->successResponse(new BibitResource($bibit), 'Bibit berhasil ditambahkan.', 201);
    }

    /**
     * Display the specified bibit.
     */
    public function show(string $id)
    {
        $bibit = $this->bibitService->getById($id);
        return $this->successResponse(new BibitResource($bibit), 'Detail bibit berhasil diambil.');
    }

    /**
     * Update the specified bibit.
     */
    public function update(BibitUpdateRequest $request, string $id)
    {
        $data = $request->validated();
        if ($request->hasFile('foto')) {
            $data['foto'] = $request->file('foto');
        }
        $bibit = $this->bibitService->update($id, $data);
        return $this->successResponse(new BibitResource($bibit), 'Bibit berhasil diperbarui.');
    }

    /**
     * Remove the specified bibit.
     */
    public function destroy(string $id)
    {
        $this->bibitService->delete($id);
        return $this->successResponse(null, 'Bibit berhasil dihapus.');
    }

    /**
     * Get coordinates for map.
     */
    public function mapCoords()
    {
        $coords = $this->bibitService->getMapCoords();
        return $this->successResponse($coords, 'Koordinat peta bibit berhasil diambil.');
    }

    /**
     * Get dashboard stats.
     */
    public function dashboard()
    {
        $stats = $this->bibitService->getDashboardStats();
        return $this->successResponse($stats, 'Statistik dashboard berhasil diambil.');
    }

    /**
     * Export all bibits to CSV (Excel compatible).
     */
    public function exportExcel()
    {
        $bibits = $this->bibitService->getAll();
        $headers = [
            "Content-type" => "text/csv; charset=UTF-8",
            "Content-Disposition" => "attachment; filename=daftar_bibit_durian.csv",
            "Pragma" => "no-cache",
            "Cache-Control" => "must-revalidate, post-check=0, pre-check=0",
            "Expires" => "0"
        ];

        $callback = function() use($bibits) {
            $file = fopen('php://output', 'w');
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF)); // BOM for Excel UTF-8

            fputcsv($file, ['ID', 'Kode Bibit', 'Varietas', 'Tanggal Tanam', 'Status', 'Lokasi Blok', 'Latitude', 'Longitude']);

            foreach ($bibits as $bibit) {
                fputcsv($file, [
                    $bibit->id,
                    $bibit->kode_bibit,
                    $bibit->varietas,
                    $bibit->tanggal_tanam?->format('Y-m-d'),
                    $bibit->status,
                    $bibit->lokasi_blok,
                    $bibit->latitude,
                    $bibit->longitude
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    /**
     * Export all bibits to PDF.
     */
    public function exportPdf()
    {
        $bibits = $this->bibitService->getAll();

        $pdf = Pdf::loadView('reports.bibit', compact('bibits'));
        return $pdf->download('daftar_bibit_durian.pdf');
    }
}
