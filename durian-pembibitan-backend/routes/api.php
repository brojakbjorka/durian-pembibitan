<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BibitController;
use App\Http\Controllers\Api\KatalogDaunController;
use App\Http\Controllers\Api\OkulasiController;
use App\Http\Controllers\Api\JadwalPerawatanController;
use App\Http\Controllers\Api\RiwayatPerkembanganController;
use App\Http\Controllers\Api\AuditTrailController;
use App\Http\Controllers\Api\UserController;

// Public routes
Route::post('/login', [AuthController::class, 'login']);

// Authenticated routes
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth & Profile
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::put('/profile/password', [AuthController::class, 'updatePassword']);

    // Admin Only routes
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('/users', UserController::class);
        
        Route::get('/audit-trails', [AuditTrailController::class, 'index']);
        Route::get('/audit-trails/export', [AuditTrailController::class, 'export']);
    });

    // Petani Only (Operational) routes
    Route::middleware('role:petani')->group(function () {
        Route::get('/dashboard', [BibitController::class, 'dashboard']);
        Route::get('/bibits/map', [BibitController::class, 'mapCoords']);
        Route::get('/bibits/export/excel', [BibitController::class, 'exportExcel']);
        Route::get('/bibits/export/pdf', [BibitController::class, 'exportPdf']);
        
        Route::apiResource('/bibits', BibitController::class);
        Route::apiResource('/okulasi', OkulasiController::class);
        Route::apiResource('/jadwal-perawatan', JadwalPerawatanController::class);
        Route::apiResource('/riwayat-perkembangan', RiwayatPerkembanganController::class);
        
        Route::get('/katalog-daun', [KatalogDaunController::class, 'index']);
        Route::get('/katalog-daun/{id}', [KatalogDaunController::class, 'show']);
        
        Route::get('/my-audit-trails', [AuditTrailController::class, 'myLogs']);
    });
});
