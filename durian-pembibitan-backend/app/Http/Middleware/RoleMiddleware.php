<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user || !in_array($user->role, $roles)) {
            // Log unauthorized access attempt to Audit Trail
            $auditService = app(\App\Services\AuditTrailService::class);
            $auditService->log('Akses Ditolak', 'Sistem', null, 'Gagal');

            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki hak akses untuk tindakan ini.',
            ], 403);
        }

        return $next($request);
    }
}
