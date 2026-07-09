<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class OkulasiRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'bibit_id' => ['required', 'exists:bibits,id'],
            'tanggal_okulasi' => ['required', 'date'],
            'entres_varietas' => ['required', 'string', 'max:100'],
            'status_keberhasilan' => ['required', 'string', 'in:Proses,Berhasil,Gagal'],
            'catatan' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'bibit_id.required' => 'Bibit wajib dipilih.',
            'bibit_id.exists' => 'Bibit yang dipilih tidak valid.',
            'tanggal_okulasi.required' => 'Tanggal okulasi wajib diisi.',
            'tanggal_okulasi.date' => 'Format tanggal okulasi tidak valid.',
            'entres_varietas.required' => 'Varietas entres wajib diisi.',
            'status_keberhasilan.required' => 'Status keberhasilan wajib diisi.',
            'status_keberhasilan.in' => 'Status keberhasilan harus berupa: Proses, Berhasil, atau Gagal.',
        ];
    }
}
