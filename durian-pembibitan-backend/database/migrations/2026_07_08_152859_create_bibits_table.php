<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bibits', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('kode_bibit')->unique();
            $table->string('varietas');
            $table->date('tanggal_tanam');
            $table->string('status')->default('Sehat'); // Sehat, Sakit, Mati, Okulasi, dll
            $table->string('lokasi_blok');
            $table->double('latitude')->nullable();
            $table->double('longitude')->nullable();
            $table->string('foto_url')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bibits');
    }
};
