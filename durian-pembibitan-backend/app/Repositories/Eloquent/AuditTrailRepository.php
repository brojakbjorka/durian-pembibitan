<?php

namespace App\Repositories\Eloquent;

use App\Models\AuditTrail;
use App\Repositories\Contracts\AuditTrailRepositoryInterface;

class AuditTrailRepository extends BaseRepository implements AuditTrailRepositoryInterface
{
    public function __construct(AuditTrail $model)
    {
        parent::__construct($model);
    }

    public function filterAndPaginate(array $filters, int $perPage = 15)
    {
        $query = $this->model->newQuery();

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

        return $query->orderBy('created_at', 'desc')->paginate($perPage);
    }

    public function getByUser(int $userId, int $perPage = 15)
    {
        return $this->model->where('user_id', $userId)
                           ->orderBy('created_at', 'desc')
                           ->paginate($perPage);
    }
}
