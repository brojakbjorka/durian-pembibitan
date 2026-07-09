<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RiwayatPerkembanganResource extends JsonResource
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
            'tanggal_catat' => $this->tanggal_catat?->format('Y-m-d'),
            'tinggi_cm' => $this->tinggi_cm,
            'jumlah_daun' => $this->jumlah_daun,
            'kondisi_batang' => $this->kondisi_batang,
            'foto_perkembangan_url' => $this->foto_perkembangan_url ? asset($this->foto_perkembangan_url) : null,
            'catatan' => $this->catatan,
            'bibit' => new BibitResource($this->whenLoaded('bibit')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
