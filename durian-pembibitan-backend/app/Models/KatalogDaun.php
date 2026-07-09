<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class KatalogDaun extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $table = 'katalog_dauns';

    protected $fillable = [
        'varietas',
        'deskripsi',
        'ciri_khas',
        'foto_daun_url',
    ];
}
