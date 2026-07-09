<?php

namespace App\Services;

use App\Repositories\Contracts\AuditTrailRepositoryInterface;
use Illuminate\Support\Facades\Auth;

class AuditTrailService
{
    protected AuditTrailRepositoryInterface $auditTrailRepository;

    public function __construct(AuditTrailRepositoryInterface $auditTrailRepository)
    {
        $this->auditTrailRepository = $auditTrailRepository;
    }

    /**
     * Log user activity manually.
     */
    public function log(string $aktivitas, string $modul, ?string $recordId = null, string $status = 'Sukses')
    {
        $request = request();
        $user = Auth::user();
        $userAgent = $request->header('User-Agent', '');

        $data = [
            'user_id' => $user ? $user->id : null,
            'email' => $user ? $user->email : ($request->input('email') ?? null),
            'role' => $user ? $user->role : null,
            'aktivitas' => $aktivitas,
            'modul' => $modul,
            'record_id' => $recordId,
            'url' => $request->fullUrl(),
            'http_method' => $request->method(),
            'browser' => $this->getBrowser($userAgent),
            'device' => $this->getDevice($userAgent),
            'ip' => $request->ip(),
            'status' => $status,
            'created_at' => now(),
        ];

        return $this->auditTrailRepository->create($data);
    }

    /**
     * Parse browser name from User Agent.
     */
    private function getBrowser(string $userAgent): string
    {
        if (empty($userAgent)) return 'Unknown';
        if (preg_match('/MSIE/i', $userAgent) && !preg_match('/Opera/i', $userAgent)) return 'Internet Explorer';
        if (preg_match('/Firefox/i', $userAgent)) return 'Firefox';
        if (preg_match('/Chrome/i', $userAgent) && !preg_match('/Edg/i', $userAgent)) return 'Chrome';
        if (preg_match('/Safari/i', $userAgent) && !preg_match('/Chrome/i', $userAgent)) return 'Safari';
        if (preg_match('/Opera|OPR/i', $userAgent)) return 'Opera';
        if (preg_match('/Edge|Edg/i', $userAgent)) return 'Edge';
        return 'Unknown Browser';
    }

    /**
     * Parse device type from User Agent.
     */
    private function getDevice(string $userAgent): string
    {
        if (empty($userAgent)) return 'Unknown';
        $userAgentLower = strtolower($userAgent);
        if (str_contains($userAgentLower, 'mobile') || str_contains($userAgentLower, 'android') || str_contains($userAgentLower, 'iphone') || str_contains($userAgentLower, 'ipod')) {
            return 'Mobile';
        }
        if (str_contains($userAgentLower, 'ipad') || str_contains($userAgentLower, 'tablet')) {
            return 'Tablet';
        }
        return 'Desktop';
    }

    /**
     * Query and paginate logs.
     */
    public function getLogs(array $filters, int $perPage = 15)
    {
        return $this->auditTrailRepository->filterAndPaginate($filters, $perPage);
    }

    /**
     * Query personal logs.
     */
    public function getPersonalLogs(int $userId, int $perPage = 15)
    {
        return $this->auditTrailRepository->getByUser($userId, $perPage);
    }
}
