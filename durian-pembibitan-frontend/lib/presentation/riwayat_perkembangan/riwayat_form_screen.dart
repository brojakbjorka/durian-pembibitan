import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/shared/providers.dart';
import '../../core/shared/models/riwayat_perkembangan_model.dart';

class RiwayatFormScreen extends ConsumerStatefulWidget {
  final String? id;
  final String bibitId;
  const RiwayatFormScreen({super.key, this.id, required this.bibitId});

  @override
  ConsumerState<RiwayatFormScreen> createState() => _RiwayatFormScreenState();
}

class _RiwayatFormScreenState extends ConsumerState<RiwayatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _daunController = TextEditingController();
  final _batangController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _selectedBibitId;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _existingFotoUrl;

  @override
  void initState() {
    super.initState();
    _selectedBibitId = widget.bibitId.isEmpty ? null : widget.bibitId;
    if (widget.id != null) {
      _loadRiwayatData();
    } else {
      _tanggalController.text = DateTime.now().toIso8601String().substring(0, 10);
    }
  }

  void _loadRiwayatData() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/riwayat-perkembangan/${widget.id}');
      if (response.data['success'] == true) {
        final riwayat = RiwayatPerkembanganModel.fromJson(response.data['data']);
        _selectedBibitId = riwayat.bibitId;
        _tanggalController.text = riwayat.tanggalCatat;
        _tinggiController.text = riwayat.tinggiCm.toString();
        _daunController.text = riwayat.jumlahDaun.toString();
        _batangController.text = riwayat.kondisiBatang;
        _catatanController.text = riwayat.catatan ?? '';
        _existingFotoUrl = riwayat.fotoPerkembanganUrl;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data perkembangan.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _tinggiController.dispose();
    _daunController.dispose();
    _batangController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ukuran gambar maksimal 5MB.'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      setState(() {
        _imageFile = picked;
      });
    }
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

        final Map<String, dynamic> dataMap = {
          'bibit_id': _selectedBibitId,
          'tanggal_catat': _tanggalController.text,
          'tinggi_cm': int.tryParse(_tinggiController.text) ?? 0,
          'jumlah_daun': int.tryParse(_daunController.text) ?? 0,
          'kondisi_batang': _batangController.text.trim(),
          'catatan': _catatanController.text.trim(),
        };

        if (_imageFile != null) {
          dataMap['foto'] = await MultipartFile.fromFile(
            _imageFile!.path,
            filename: _imageFile!.name,
          );
        }

        Response response;
        if (widget.id == null) {
          response = await dio.post(
            '/riwayat-perkembangan',
            data: FormData.fromMap(dataMap),
          );
        } else {
          dataMap['_method'] = 'PUT';
          response = await dio.post(
            '/riwayat-perkembangan/${widget.id}',
            data: FormData.fromMap(dataMap),
          );
        }

        if (!mounted) return;

        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.id == null ? 'Perkembangan berhasil ditambahkan.' : 'Perkembangan berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(riwayatListProvider(_selectedBibitId ?? ''));
          context.pop();
        }
      } on DioException catch (e) {
        if (!mounted) return;
        final message = e.response?.data['message'] ?? 'Gagal menyimpan perkembangan.';
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
        title: Text(widget.id == null ? 'Catat Perkembangan' : 'Edit Perkembangan'),
      ),
      body: _isLoading && widget.id != null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker for crop height status
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                                )
                              : _existingFotoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(_existingFotoUrl!, fit: BoxFit.cover),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt, size: 36, color: Colors.blue),
                                        SizedBox(height: 8),
                                        Text('Foto Progress', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bibit Selector
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
                      error: (e, s) => Text('Gagal: $e'),
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Pencatatan
                    TextFormField(
                      controller: _tanggalController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pencatatan',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tinggi
                    TextFormField(
                      controller: _tinggiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tinggi Bibit (cm) - Harus > 0',
                        prefixIcon: Icon(Icons.height),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tinggi wajib diisi.';
                        final val = int.tryParse(value);
                        if (val == null || val <= 0) return 'Tinggi harus lebih besar dari 0.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah Daun
                    TextFormField(
                      controller: _daunController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Daun (helai)',
                        prefixIcon: Icon(Icons.forest_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Jumlah daun wajib diisi.';
                        final val = int.tryParse(value);
                        if (val == null || val < 0) return 'Jumlah daun tidak boleh negatif.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kondisi Batang
                    TextFormField(
                      controller: _batangController,
                      decoration: const InputDecoration(
                        labelText: 'Kondisi Batang (misal: Kokoh, Cokelat, Berjamur)',
                        prefixIcon: Icon(Icons.commit),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kondisi batang wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Catatan
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 2,
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
