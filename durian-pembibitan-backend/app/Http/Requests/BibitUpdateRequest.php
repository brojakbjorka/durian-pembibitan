<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class BibitUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('bibit');
        return [
            'kode_bibit' => ['required', 'string', 'max:50', 'unique:bibits,kode_bibit,' . $id],
            'varietas' => ['required', 'string', 'max:100'],
            'tanggal_tanam' => ['required', 'date'],
            'status' => ['required', 'string', 'max:50'],
            'lokasi_blok' => ['required', 'string', 'max:100'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'foto' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:5120'],
        ];
    }

    public function messages(): array
    {
        return [
            'kode_bibit.required' => 'Kode bibit wajib diisi.',
            'kode_bibit.unique' => 'Kode bibit sudah digunakan.',
            'varietas.required' => 'Varietas wajib diisi.',
            'tanggal_tanam.required' => 'Tanggal tanam wajib diisi.',
            'tanggal_tanam.date' => 'Format tanggal tanam tidak valid.',
            'status.required' => 'Status wajib diisi.',
            'lokasi_blok.required' => 'Lokasi blok wajib diisi.',
            'latitude.numeric' => 'Latitude harus berupa angka.',
            'longitude.numeric' => 'Longitude harus berupa angka.',
            'foto.image' => 'File harus berupa gambar.',
            'foto.mimes' => 'Format gambar harus JPG, JPEG, atau PNG.',
            'foto.max' => 'Ukuran gambar maksimal 5MB.',
        ];
    }
}
