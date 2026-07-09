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
        Schema::create('riwayat_perkembangans', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('bibit_id')->constrained('bibits')->cascadeOnDelete();
            $table->date('tanggal_catat');
            $table->integer('tinggi_cm');
            $table->integer('jumlah_daun');
            $table->string('kondisi_batang');
            $table->string('foto_perkembangan_url')->nullable();
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
        Schema::dropIfExists('riwayat_perkembangans');
    }
};
