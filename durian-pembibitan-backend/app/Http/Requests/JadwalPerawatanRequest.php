<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class JadwalPerawatanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'bibit_id' => ['required', 'exists:bibits,id'],
            'jenis_perawatan' => ['required', 'string', 'max:100'],
            'tanggal_jadwal' => ['required', 'date'],
            'status_pelaksanaan' => ['required', 'string', 'in:Belum Selesai,Selesai'],
            'catatan' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'bibit_id.required' => 'Bibit wajib dipilih.',
            'bibit_id.exists' => 'Bibit yang dipilih tidak valid.',
            'jenis_perawatan.required' => 'Jenis perawatan wajib diisi.',
            'tanggal_jadwal.required' => 'Tanggal jadwal wajib diisi.',
            'tanggal_jadwal.date' => 'Format tanggal jadwal tidak valid.',
            'status_pelaksanaan.required' => 'Status pelaksanaan wajib diisi.',
            'status_pelaksanaan.in' => 'Status pelaksanaan harus berupa: Belum Selesai atau Selesai.',
        ];
    }
}
