import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/shared/providers.dart';
import '../../core/shared/models/bibit_model.dart';

class BibitFormScreen extends ConsumerStatefulWidget {
  final String? bibitId;
  const BibitFormScreen({super.key, this.bibitId});

  @override
  ConsumerState<BibitFormScreen> createState() => _BibitFormScreenState();
}

class _BibitFormScreenState extends ConsumerState<BibitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _varietasController = TextEditingController();
  final _tanggalTanamController = TextEditingController();
  final _blokController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String _status = 'Sehat';
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _existingFotoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.bibitId != null) {
      _loadBibitData();
    } else {
      _tanggalTanamController.text = DateTime.now().toIso8601String().substring(0, 10);
    }
  }

  void _loadBibitData() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/bibits/${widget.bibitId}');
      if (response.data['success'] == true) {
        final bibit = BibitModel.fromJson(response.data['data']);
        _kodeController.text = bibit.kodeBibit;
        _varietasController.text = bibit.varietas;
        _tanggalTanamController.text = bibit.tanggalTanam;
        _status = bibit.status;
        _blokController.text = bibit.lokasiBlok;
        _latController.text = bibit.latitude?.toString() ?? '';
        _lngController.text = bibit.longitude?.toString() ?? '';
        _existingFotoUrl = bibit.fotoUrl;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data bibit.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _varietasController.dispose();
    _tanggalTanamController.dispose();
    _blokController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      // Validate photo size (max 5MB)
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran gambar maksimal 5MB.'),
              backgroundColor: Colors.red,
            ),
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
        _tanggalTanamController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final dio = ref.read(dioClientProvider).dio;

        // Build MultiPart form data
        final Map<String, dynamic> dataMap = {
          'kode_bibit': _kodeController.text.trim(),
          'varietas': _varietasController.text.trim(),
          'tanggal_tanam': _tanggalTanamController.text,
          'status': _status,
          'lokasi_blok': _blokController.text.trim(),
          if (_latController.text.isNotEmpty) 'latitude': double.tryParse(_latController.text),
          if (_lngController.text.isNotEmpty) 'longitude': double.tryParse(_lngController.text),
        };

        if (_imageFile != null) {
          dataMap['foto'] = await MultipartFile.fromFile(
            _imageFile!.path,
            filename: _imageFile!.name,
          );
        }

        Response response;
        if (widget.bibitId == null) {
          // Store mode
          response = await dio.post(
            '/bibits',
            data: FormData.fromMap(dataMap),
          );
        } else {
          // Update mode (use POST with method override header/field for Laravel)
          dataMap['_method'] = 'PUT';
          response = await dio.post(
            '/bibits/${widget.bibitId}',
            data: FormData.fromMap(dataMap),
          );
        }

        if (!mounted) return;

        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.bibitId == null ? 'Bibit berhasil ditambahkan.' : 'Bibit berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(bibitListProvider);
          ref.invalidate(dashboardStatsProvider);
          context.pop();
        }
      } on DioException catch (e) {
        if (!mounted) return;
        final message = e.response?.data['message'] ?? 'Gagal menyimpan data.';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bibitId == null ? 'Tambah Bibit' : 'Edit Bibit'),
      ),
      body: _isLoading && widget.bibitId != null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Section
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E7D32), width: 1),
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
                                        Icon(Icons.camera_alt, size: 40, color: Color(0xFF2E7D32)),
                                        SizedBox(height: 8),
                                        Text('Pilih Foto (Max 5MB)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kode Bibit
                    TextFormField(
                      controller: _kodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Bibit (Unik)',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kode bibit wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Varietas
                    TextFormField(
                      controller: _varietasController,
                      decoration: const InputDecoration(
                        labelText: 'Varietas',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Varietas wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Tanam
                    TextFormField(
                      controller: _tanggalTanamController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Tanam',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal tanam wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Lokasi Blok
                    TextFormField(
                      controller: _blokController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi Blok (misal: Blok A-01)',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Lokasi blok wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status Bibit',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: ['Sehat', 'Sakit', 'Mati']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Coordinates (Latitude & Longitude)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (double.tryParse(value) == null) return 'Format salah.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (double.tryParse(value) == null) return 'Format salah.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
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
