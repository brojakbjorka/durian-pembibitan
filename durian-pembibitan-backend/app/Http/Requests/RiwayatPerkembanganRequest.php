<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RiwayatPerkembanganRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'bibit_id' => ['required', 'exists:bibits,id'],
            'tanggal_catat' => ['required', 'date'],
            'tinggi_cm' => ['required', 'integer', 'min:1'], // Tinggi > 0
            'jumlah_daun' => ['required', 'integer', 'min:0'],
            'kondisi_batang' => ['required', 'string', 'max:100'],
            'foto' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:5120'], // Max 5MB
            'catatan' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'bibit_id.required' => 'Bibit wajib dipilih.',
            'bibit_id.exists' => 'Bibit yang dipilih tidak valid.',
            'tanggal_catat.required' => 'Tanggal pencatatan wajib diisi.',
            'tanggal_catat.date' => 'Format tanggal pencatatan tidak valid.',
            'tinggi_cm.required' => 'Tinggi wajib diisi.',
            'tinggi_cm.integer' => 'Tinggi harus berupa angka bulat.',
            'tinggi_cm.min' => 'Tinggi bibit harus lebih dari 0 cm.',
            'jumlah_daun.required' => 'Jumlah daun wajib diisi.',
            'jumlah_daun.integer' => 'Jumlah daun harus berupa angka bulat.',
            'jumlah_daun.min' => 'Jumlah daun minimal 0.',
            'kondisi_batang.required' => 'Kondisi batang wajib diisi.',
            'foto.image' => 'File harus berupa gambar.',
            'foto.mimes' => 'Format gambar harus JPG, JPEG, atau PNG.',
            'foto.max' => 'Ukuran gambar maksimal 5MB.',
        ];
    }
}
