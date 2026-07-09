<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\RoleMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->report(function (\Throwable $e) {
            try {
                // Ignore minor HTTP validation errors to avoid noise
                if ($e instanceof \Illuminate\Validation\ValidationException || $e instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
                    return;
                }
                
                $auditService = app(\App\Services\AuditTrailService::class);
                $auditService->log(
                    'Error: ' . substr($e->getMessage(), 0, 150),
                    'Sistem',
                    null,
                    'Error'
                );
            } catch (\Throwable $ex) {
                // Fallback to prevent infinite loops
            }
        });
    })->create();
