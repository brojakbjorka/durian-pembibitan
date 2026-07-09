<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Bibit extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'kode_bibit',
        'varietas',
        'tanggal_tanam',
        'status',
        'lokasi_blok',
        'latitude',
        'longitude',
        'foto_url',
    ];

    protected $casts = [
        'tanggal_tanam' => 'date',
        'latitude' => 'double',
        'longitude' => 'double',
    ];

    public function okulasis(): HasMany
    {
        return $this->hasMany(Okulasi::class, 'bibit_id');
    }

    public function jadwalPerawatans(): HasMany
    {
        return $this->hasMany(JadwalPerawatan::class, 'bibit_id');
    }

    public function riwayatPerkembangans(): HasMany
    {
        return $this->hasMany(RiwayatPerkembangan::class, 'bibit_id');
    }
}
