<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class KatalogDaunResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'varietas' => $this->varietas,
            'deskripsi' => $this->deskripsi,
            'ciri_khas' => $this->ciri_khas,
            'foto_daun_url' => $this->foto_daun_url ? asset($this->foto_daun_url) : null,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
