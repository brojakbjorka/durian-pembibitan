<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Okulasi extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'bibit_id',
        'tanggal_okulasi',
        'entres_varietas',
        'status_keberhasilan',
        'catatan',
    ];

    protected $casts = [
        'tanggal_okulasi' => 'date',
    ];

    public function bibit(): BelongsTo
    {
        return $this->belongsTo(Bibit::class, 'bibit_id');
    }
}
