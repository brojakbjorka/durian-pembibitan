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
        Schema::create('audit_trails', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('email')->nullable();
            $table->string('role')->nullable();
            $table->string('aktivitas'); // Login, Logout, Tambah, Edit, Hapus, Reset Password, Gagal Login, Error
            $table->string('modul'); // Auth, Bibit, Okulasi, Jadwal, Perkembangan, Katalog Daun, User
            $table->string('record_id')->nullable(); // UUID or ID of the affected resource
            $table->string('url');
            $table->string('http_method');
            $table->string('browser');
            $table->string('device');
            $table->string('ip');
            $table->string('status'); // Sukses, Gagal, Error
            $table->timestamp('created_at')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audit_trails');
    }
};
