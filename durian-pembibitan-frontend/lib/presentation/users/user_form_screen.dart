import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/shared/providers.dart';
import '../../core/shared/models/user_model.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final String? userId;
  const UserFormScreen({super.key, this.userId});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'petani';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserData();
    }
  }

  void _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/users/${widget.userId}');
      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        _nameController.text = user.name;
        _emailController.text = user.email;
        _role = user.role;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data pengguna.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final dio = ref.read(dioClientProvider).dio;
        final data = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _role,
          if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
        };

        Response response;
        if (widget.userId == null) {
          response = await dio.post('/users', data: data);
        } else {
          response = await dio.put('/users/${widget.userId}', data: data);
        }

        if (!mounted) return;

        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.userId == null ? 'Pengguna berhasil dibuat.' : 'Pengguna berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(userListProvider);
          context.pop();
        }
      } on DioException catch (e) {
        if (!mounted) return;
        final message = e.response?.data['message'] ?? 'Gagal menyimpan data pengguna.';
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
        title: Text(widget.userId == null ? 'Tambah Pengguna' : 'Edit Pengguna'),
      ),
      body: _isLoading && widget.userId != null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi.' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email wajib diisi.';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Format email tidak valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: widget.userId == null ? 'Kata Sandi' : 'Kata Sandi Baru (Kosongkan jika tidak diubah)',
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (widget.userId == null && (value == null || value.isEmpty)) {
                          return 'Kata sandi wajib diisi.';
                        }
                        if (value != null && value.isNotEmpty && value.length < 8) {
                          return 'Kata sandi minimal 8 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                      items: ['admin', 'petani']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val.toUpperCase())))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _role = val);
                      },
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
