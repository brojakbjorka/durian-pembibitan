import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/shared/providers.dart';
import '../../core/shared/models/jadwal_perawatan_model.dart';

class JadwalFormScreen extends ConsumerStatefulWidget {
  final String? id;
  final String? bibitId;
  const JadwalFormScreen({super.key, this.id, this.bibitId});

  @override
  ConsumerState<JadwalFormScreen> createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends ConsumerState<JadwalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jenisController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _selectedBibitId;
  String _status = 'Belum Selesai';
  bool _isLoading = false;

  final List<String> _jenisSuggestions = [
    'Penyiraman',
    'Pemupukan NPK',
    'Penyemprotan Fungisida',
    'Penyemprotan Insektisida',
    'Penyiangan Gulma',
    'Pemangkasan Cabang'
  ];

  @override
  void initState() {
    super.initState();
    _selectedBibitId = widget.bibitId;
    if (widget.id != null) {
      _loadJadwalData();
    } else {
      _tanggalController.text = DateTime.now().toIso8601String().substring(0, 10);
    }
  }

  void _loadJadwalData() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/jadwal-perawatan/${widget.id}');
      if (response.data['success'] == true) {
        final jadwal = JadwalPerawatanModel.fromJson(response.data['data']);
        _selectedBibitId = jadwal.bibitId;
        _jenisController.text = jadwal.jenisPerawatan;
        _tanggalController.text = jadwal.tanggalJadwal;
        _status = jadwal.statusPelaksanaan;
        _catatanController.text = jadwal.catatan ?? '';
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data jadwal.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _tanggalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBibitId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bibit wajib dipilih.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final dio = ref.read(dioClientProvider).dio;
        final data = {
          'bibit_id': _selectedBibitId,
          'jenis_perawatan': _jenisController.text.trim(),
          'tanggal_jadwal': _tanggalController.text,
          'status_pelaksanaan': _status,
          'catatan': _catatanController.text.trim(),
        };

        Response response;
        if (widget.id == null) {
          response = await dio.post('/jadwal-perawatan', data: data);
        } else {
          response = await dio.put('/jadwal-perawatan/${widget.id}', data: data);
        }

        if (!mounted) return;

        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.id == null ? 'Jadwal berhasil dibuat.' : 'Jadwal berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(jadwalListProvider);
          ref.invalidate(dashboardStatsProvider);
          context.pop();
        }
      } on DioException catch (e) {
        if (!mounted) return;
        final message = e.response?.data['message'] ?? 'Gagal menyimpan data jadwal.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan koneksi.'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibitsFuture = ref.watch(bibitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bibit Dropdown
                    bibitsFuture.when(
                      data: (list) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedBibitId,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Bibit',
                            prefixIcon: Icon(Icons.grass),
                          ),
                          items: list.map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text('${b.kodeBibit} - ${b.varietas}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedBibitId = val);
                          },
                          validator: (val) => val == null ? 'Bibit wajib dipilih.' : null,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Gagal memuat bibit: $e'),
                    ),
                    const SizedBox(height: 16),

                    // Jenis Perawatan AutoComplete/Field
                    TextFormField(
                      controller: _jenisController,
                      decoration: InputDecoration(
                        labelText: 'Jenis Perawatan',
                        prefixIcon: const Icon(Icons.dry_cleaning),
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (val) {
                            _jenisController.text = val;
                          },
                          itemBuilder: (context) {
                            return _jenisSuggestions.map((s) {
                              return PopupMenuItem(value: s, child: Text(s));
                            }).toList();
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Jenis perawatan wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Jadwal
                    TextFormField(
                      controller: _tanggalController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Jadwal',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal jadwal wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status Pelaksanaan',
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                      items: ['Belum Selesai', 'Selesai']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Catatan
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan tambahan',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('SIMPAN'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
