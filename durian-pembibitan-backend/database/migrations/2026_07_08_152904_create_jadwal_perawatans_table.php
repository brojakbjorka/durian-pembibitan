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
        Schema::create('jadwal_perawatans', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('bibit_id')->constrained('bibits')->cascadeOnDelete();
            $table->string('jenis_perawatan'); // Siram, Pupuk, Semprot, Penyiangan, dll
            $table->date('tanggal_jadwal');
            $table->string('status_pelaksanaan')->default('Belum Selesai'); // Belum Selesai, Selesai
            $table->text('catatan')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jadwal_perawatans');
    }
};
