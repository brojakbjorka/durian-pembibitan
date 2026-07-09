<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OkulasiResource extends JsonResource
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
            'tanggal_okulasi' => $this->tanggal_okulasi?->format('Y-m-d'),
            'entres_varietas' => $this->entres_varietas,
            'status_keberhasilan' => $this->status_keberhasilan,
            'catatan' => $this->catatan,
            'bibit' => new BibitResource($this->whenLoaded('bibit')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
