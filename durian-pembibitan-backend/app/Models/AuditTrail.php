<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuditTrail extends Model
{
    // Disable default timestamps since we only have created_at in the migration
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'email',
        'role',
        'aktivitas',
        'modul',
        'record_id',
        'url',
        'http_method',
        'browser',
        'device',
        'ip',
        'status',
        'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
