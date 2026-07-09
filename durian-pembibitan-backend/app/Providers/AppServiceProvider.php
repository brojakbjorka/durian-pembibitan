<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(
            \App\Repositories\Contracts\UserRepositoryInterface::class,
            \App\Repositories\Eloquent\UserRepository::class
        );
        $this->app->bind(
            \App\Repositories\Contracts\BibitRepositoryInterface::class,
            \App\Repositories\Eloquent\BibitRepository::class
        );
        $this->app->bind(
            \App\Repositories\Contracts\KatalogDaunRepositoryInterface::class,
            \App\Repositories\Eloquent\KatalogDaunRepository::class
        );
        $this->app->bind(
            \App\Repositories\Contracts\OkulasiRepositoryInterface::class,
            \App\Repositories\Eloquent\OkulasiRepository::class
        );
        $this->app->bind(
            \App\Repositories\Contracts\JadwalPerawatanRepositoryInterface::class,
            \App\Repositories\Eloquent\JadwalPerawatanRepository::class
        );
        $this->app->bind(
            \App\Repositories\Contracts\RiwayatPerkembanganRepositoryInterface::class,
            \App\Repositories\Eloquent\RiwayatPerkembanganRepository::class
        );
        $this->app->bind(
            \App\Repositories\Contracts\AuditTrailRepositoryInterface::class,
            \App\Repositories\Eloquent\AuditTrailRepository::class
        );
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \App\Models\User::observe(\App\Observers\AuditTrailObserver::class);
        \App\Models\Bibit::observe(\App\Observers\AuditTrailObserver::class);
        \App\Models\KatalogDaun::observe(\App\Observers\AuditTrailObserver::class);
        \App\Models\Okulasi::observe(\App\Observers\AuditTrailObserver::class);
        \App\Models\JadwalPerawatan::observe(\App\Observers\AuditTrailObserver::class);
        \App\Models\RiwayatPerkembangan::observe(\App\Observers\AuditTrailObserver::class);
    }
}
