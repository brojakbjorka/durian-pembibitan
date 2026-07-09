<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class JadwalPerawatan extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $table = 'jadwal_perawatans';

    protected $fillable = [
        'bibit_id',
        'jenis_perawatan',
        'tanggal_jadwal',
        'status_pelaksanaan',
        'catatan',
    ];

    protected $casts = [
        'tanggal_jadwal' => 'date',
    ];

    public function bibit(): BelongsTo
    {
        return $this->belongsTo(Bibit::class, 'bibit_id');
    }
}
