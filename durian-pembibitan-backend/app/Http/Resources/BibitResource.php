<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BibitResource extends JsonResource
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
            'kode_bibit' => $this->kode_bibit,
            'varietas' => $this->varietas,
            'tanggal_tanam' => $this->tanggal_tanam?->format('Y-m-d'),
            'status' => $this->status,
            'lokasi_blok' => $this->lokasi_blok,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'foto_url' => $this->foto_url ? asset($this->foto_url) : null,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
