<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiwayatPerkembangan extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $table = 'riwayat_perkembangans';

    protected $fillable = [
        'bibit_id',
        'tanggal_catat',
        'tinggi_cm',
        'jumlah_daun',
        'kondisi_batang',
        'foto_perkembangan_url',
        'catatan',
    ];

    protected $casts = [
        'tanggal_catat' => 'date',
        'tinggi_cm' => 'integer',
        'jumlah_daun' => 'integer',
    ];

    public function bibit(): BelongsTo
    {
        return $this->belongsTo(Bibit::class, 'bibit_id');
    }
}
