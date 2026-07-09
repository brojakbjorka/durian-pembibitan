# PROJECT RULES

- Jangan mengubah struktur folder tanpa alasan.
- Semua endpoint menggunakan REST API.
- Semua response menggunakan format JSON yang konsisten.
- Jangan menggunakan query SQL mentah jika dapat menggunakan Eloquent.
- Semua CRUD harus menggunakan Service dan Repository.
- Semua validasi menggunakan Form Request.
- Semua perubahan data harus tercatat pada Audit Trail.
- Tidak boleh ada hardcoded credential.
- Gunakan environment (.env) untuk konfigurasi.
- Terapkan prinsip SOLID, DRY, KISS, dan Clean Code.
- Semua fitur baru harus disertai validasi, otorisasi, dan pencatatan Audit Trail bila relevan.
