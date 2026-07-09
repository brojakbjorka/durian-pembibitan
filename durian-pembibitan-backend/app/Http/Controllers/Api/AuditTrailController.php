<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AuditTrailResource;
use App\Services\AuditTrailService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use App\Models\AuditTrail;

class AuditTrailController extends Controller
{
    use ApiResponse;

    protected AuditTrailService $auditTrailService;

    public function __construct(AuditTrailService $auditTrailService)
    {
        $this->auditTrailService = $auditTrailService;
    }

    /**
     * Display a listing of the resource (Admin only).
     */
    public function index(Request $request)
    {
        $filters = $request->only(['search', 'user_id', 'role', 'aktivitas', 'modul', 'status', 'start_date', 'end_date']);
        $perPage = $request->input('per_page', 15);

        $logs = $this->auditTrailService->getLogs($filters, $perPage);
        return $this->successResponse([
            'logs' => AuditTrailResource::collection($logs),
            'pagination' => [
                'current_page' => $logs->currentPage(),
                'last_page' => $logs->lastPage(),
                'per_page' => $logs->perPage(),
                'total' => $logs->total(),
            ]
        ], 'Audit trail berhasil diambil.');
    }

    /**
     * Display a listing of personal logs (Petani only).
     */
    public function myLogs(Request $request)
    {
        $user = $request->user();
        $perPage = $request->input('per_page', 15);

        $logs = $this->auditTrailService->getPersonalLogs($user->id, $perPage);
        return $this->successResponse([
            'logs' => AuditTrailResource::collection($logs),
            'pagination' => [
                'current_page' => $logs->currentPage(),
                'last_page' => $logs->lastPage(),
                'per_page' => $logs->perPage(),
                'total' => $logs->total(),
            ]
        ], 'Audit trail pribadi berhasil diambil.');
    }

    /**
     * Export audit trail to CSV/Excel (Admin only).
     */
    public function export(Request $request)
    {
        $filters = $request->only(['search', 'user_id', 'role', 'aktivitas', 'modul', 'status', 'start_date', 'end_date']);

        $query = AuditTrail::with('user');

        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('aktivitas', 'like', "%{$search}%")
                  ->orWhere('modul', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('browser', 'like', "%{$search}%")
                  ->orWhere('device', 'like', "%{$search}%")
                  ->orWhere('status', 'like', "%{$search}%")
                  ->orWhere('ip', 'like', "%{$search}%");
            });
        }

        if (!empty($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        if (!empty($filters['role'])) {
            $query->where('role', $filters['role']);
        }

        if (!empty($filters['aktivitas'])) {
            $query->where('aktivitas', $filters['aktivitas']);
        }

        if (!empty($filters['modul'])) {
            $query->where('modul', $filters['modul']);
        }

        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (!empty($filters['start_date'])) {
            $query->whereDate('created_at', '>=', $filters['start_date']);
        }

        if (!empty($filters['end_date'])) {
            $query->whereDate('created_at', '<=', $filters['end_date']);
        }

        $logs = $query->orderBy('created_at', 'desc')->get();

        $headers = [
            "Content-type" => "text/csv; charset=UTF-8",
            "Content-Disposition" => "attachment; filename=audit_trail_nursery.csv",
            "Pragma" => "no-cache",
            "Cache-Control" => "must-revalidate, post-check=0, pre-check=0",
            "Expires" => "0"
        ];

        $callback = function() use ($logs) {
            $file = fopen('php://output', 'w');
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF)); // BOM for Excel UTF-8

            fputcsv($file, ['ID', 'User ID', 'Nama User', 'Email', 'Role', 'Aktivitas', 'Modul', 'Record ID', 'URL', 'HTTP Method', 'Browser', 'Device', 'IP', 'Status', 'Timestamp']);

            foreach ($logs as $log) {
                fputcsv($file, [
                    $log->id,
                    $log->user_id,
                    $log->user?->name ?? 'Tamu',
                    $log->email,
                    $log->role,
                    $log->aktivitas,
                    $log->modul,
                    $log->record_id,
                    $log->url,
                    $log->http_method,
                    $log->browser,
                    $log->device,
                    $log->ip,
                    $log->status,
                    $log->created_at?->toIso8601String(),
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
