import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/shared/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  bool _isProfileLoading = false;
  bool _isPasswordLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _nameController.text = auth.name ?? '';
    _emailController.text = auth.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      setState(() => _isProfileLoading = true);
      final success = await ref.read(authProvider.notifier).updateProfile(
            _nameController.text.trim(),
            _emailController.text.trim(),
          );
      setState(() => _isProfileLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Profil berhasil disimpan.' : 'Gagal menyimpan profil.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() => _isPasswordLoading = true);
      final error = await ref.read(authProvider.notifier).changePassword(
            _currentPwdController.text,
            _newPwdController.text,
            _confirmPwdController.text,
          );
      setState(() => _isPasswordLoading = false);

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
          _currentPwdController.clear();
          _newPwdController.clear();
          _confirmPwdController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi.' : null,
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isProfileLoading ? null : _saveProfile,
                        child: _isProfileLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('SIMPAN PROFIL'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Keamanan (Ganti Password)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF795548)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _currentPwdController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Kata Sandi Saat Ini',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Kata sandi saat ini wajib diisi.' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPwdController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Kata Sandi Baru (Min. 8 karakter)',
                          prefixIcon: Icon(Icons.lock_reset),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Kata sandi baru wajib diisi.';
                          if (value.length < 8) return 'Kata sandi minimal 8 karakter.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPwdController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Konfirmasi kata sandi wajib diisi.';
                          if (value != _newPwdController.text) return 'Konfirmasi kata sandi tidak cocok.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isPasswordLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF795548)),
                        child: _isPasswordLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('GANTI KATA SANDI'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
