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
        Schema::create('okulasis', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('bibit_id')->constrained('bibits')->cascadeOnDelete();
            $table->date('tanggal_okulasi');
            $table->string('entres_varietas');
            $table->string('status_keberhasilan')->default('Proses'); // Proses, Berhasil, Gagal
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
        Schema::dropIfExists('okulasis');
    }
};
