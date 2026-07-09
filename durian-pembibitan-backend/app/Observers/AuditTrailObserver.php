<?php

namespace App\Observers;

use App\Services\AuditTrailService;
use Illuminate\Database\Eloquent\Model;

class AuditTrailObserver
{
    protected AuditTrailService $auditTrailService;

    public function __construct(AuditTrailService $auditTrailService)
    {
        $this->auditTrailService = $auditTrailService;
    }

    public function created(Model $model): void
    {
        $modul = $this->getModulName($model);
        $this->auditTrailService->log('Tambah', $modul, $model->id, 'Sukses');
    }

    public function updated(Model $model): void
    {
        $modul = $this->getModulName($model);
        
        // Detect password reset or profile updates
        $aktivitas = 'Edit';
        if ($model instanceof \App\Models\User && $model->wasChanged('password')) {
            $aktivitas = 'Reset Password';
        } elseif (method_exists($model, 'trashed') && $model->wasChanged('deleted_at') && !$model->trashed()) {
            $aktivitas = 'Restore';
        }

        $this->auditTrailService->log($aktivitas, $modul, $model->id, 'Sukses');
    }

    public function deleted(Model $model): void
    {
        $modul = $this->getModulName($model);
        
        // Soft delete counts as deleted
        $this->auditTrailService->log('Hapus', $modul, $model->id, 'Sukses');
    }

    protected function getModulName(Model $model): string
    {
        $className = class_basename($model);
        switch ($className) {
            case 'Bibit':
                return 'Bibit';
            case 'Okulasi':
                return 'Okulasi';
            case 'JadwalPerawatan':
                return 'Jadwal';
            case 'RiwayatPerkembangan':
                return 'Perkembangan';
            case 'User':
                return 'User';
            case 'KatalogDaun':
                return 'Katalog Daun';
            default:
                return 'Sistem';
        }
    }
}
