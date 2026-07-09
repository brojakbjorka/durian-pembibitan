<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuditTrailResource extends JsonResource
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
            'user_id' => $this->user_id,
            'user_name' => $this->user?->name ?? 'Tamu',
            'email' => $this->email,
            'role' => $this->role,
            'aktivitas' => $this->aktivitas,
            'modul' => $this->modul,
            'record_id' => $this->record_id,
            'url' => $this->url,
            'http_method' => $this->http_method,
            'browser' => $this->browser,
            'device' => $this->device,
            'ip' => $this->ip,
            'status' => $this->status,
            'timestamp' => $this->created_at?->toIso8601String(),
        ];
    }
}
