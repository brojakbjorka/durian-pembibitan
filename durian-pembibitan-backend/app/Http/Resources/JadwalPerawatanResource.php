<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class JadwalPerawatanResource extends JsonResource
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
            'bibit_id' => $this->bibit_id,
            'jenis_perawatan' => $this->jenis_perawatan,
            'tanggal_jadwal' => $this->tanggal_jadwal?->format('Y-m-d'),
            'status_pelaksanaan' => $this->status_pelaksanaan,
            'catatan' => $this->catatan,
            'bibit' => new BibitResource($this->whenLoaded('bibit')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
