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
        Schema::create('katalog_dauns', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('varietas')->unique();
            $table->text('deskripsi');
            $table->text('ciri_khas');
            $table->string('foto_daun_url')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('katalog_dauns');
    }
};
