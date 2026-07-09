import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';
import '../services/dio_client.dart';
import 'package:dio/dio.dart';
import 'models/bibit_model.dart';
import 'models/katalog_daun_model.dart';
import 'models/okulasi_model.dart';
import 'models/jadwal_perawatan_model.dart';
import 'models/riwayat_perkembangan_model.dart';
import 'models/audit_trail_model.dart';
import 'models/user_model.dart';

// 1. Secure Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// 2. Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
});

// 3. Auth State Model
class AuthState {
  final bool isAuthenticated;
  final String? role;
  final String? name;
  final String? email;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.role,
    this.name,
    this.email,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? role,
    String? name,
    String? email,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 4. Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => _checkAuthStatus());
    return AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final secureStorage = ref.read(secureStorageProvider);
    state = state.copyWith(isLoading: true);
    try {
      final token = await secureStorage.getToken();
      final role = await secureStorage.getRole();
      final userData = await secureStorage.getUserData();

      if (token != null && role != null) {
        state = AuthState(
          isAuthenticated: true,
          role: role,
          name: userData['name'],
          email: userData['email'],
        );
      } else {
        state = AuthState(isAuthenticated: false);
      }
    } catch (e) {
      state = AuthState(isAuthenticated: false, errorMessage: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    final secureStorage = ref.read(secureStorageProvider);
    final dioClient = ref.read(dioClientProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await dioClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final user = data['user'];
        final role = user['role'];
        final name = user['name'];
        final userEmail = user['email'];

        await secureStorage.saveToken(token);
        await secureStorage.saveRole(role);
        await secureStorage.saveUserData(name, userEmail);

        state = AuthState(
          isAuthenticated: true,
          role: role,
          name: name,
          email: userEmail,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.data['message'] ?? 'Login gagal.',
        );
        return false;
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Email atau password salah.';
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Koneksi gagal.');
      return false;
    }
  }

  Future<void> logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    final dioClient = ref.read(dioClientProvider);
    state = state.copyWith(isLoading: true);
    try {
      await dioClient.dio.post('/logout');
    } catch (_) {
      // Allow local logout anyway
    } finally {
      await secureStorage.clearAll();
      state = AuthState(isAuthenticated: false);
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    final secureStorage = ref.read(secureStorageProvider);
    final dioClient = ref.read(dioClientProvider);
    try {
      final response = await dioClient.dio.put('/profile', data: {
        'name': name,
        'email': email,
      });

      if (response.data['success'] == true) {
        await secureStorage.saveUserData(name, email);
        state = state.copyWith(name: name, email: email);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    final dioClient = ref.read(dioClientProvider);
    try {
      final response = await dioClient.dio.put('/profile/password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });

      if (response.data['success'] == true) {
        return null; // Success, no error message
      }
      return response.data['message'] ?? 'Gagal mengganti password.';
    } on DioException catch (e) {
      return e.response?.data['message'] ?? 'Kredensial atau input salah.';
    } catch (_) {
      return 'Koneksi gagal.';
    }
  }
}

// 5. Auth State Notifier Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// 6. Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/dashboard');
  return response.data['data'] as Map<String, dynamic>;
});

// 7. Bibit List Provider
final bibitListProvider = FutureProvider.autoDispose<List<BibitModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/bibits');
  final list = response.data['data'] as List;
  return list.map((e) => BibitModel.fromJson(e)).toList();
});

// 8. Katalog Daun List Provider
final katalogDaunListProvider = FutureProvider.autoDispose<List<KatalogDaunModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/katalog-daun');
  final list = response.data['data'] as List;
  return list.map((e) => KatalogDaunModel.fromJson(e)).toList();
});

// 9. Okulasi List Provider
final okulasiListProvider = FutureProvider.autoDispose<List<OkulasiModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/okulasi');
  final list = response.data['data'] as List;
  return list.map((e) => OkulasiModel.fromJson(e)).toList();
});

// 10. Jadwal Perawatan List Provider
final jadwalListProvider = FutureProvider.autoDispose<List<JadwalPerawatanModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/jadwal-perawatan');
  final list = response.data['data'] as List;
  return list.map((e) => JadwalPerawatanModel.fromJson(e)).toList();
});

// 11. Riwayat Perkembangan List Provider
final riwayatListProvider = FutureProvider.autoDispose.family<List<RiwayatPerkembanganModel>, String>((ref, bibitId) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/riwayat-perkembangan', queryParameters: {
    if (bibitId.isNotEmpty) 'bibit_id': bibitId,
  });
  final list = response.data['data'] as List;
  return list.map((e) => RiwayatPerkembanganModel.fromJson(e)).toList();
});

// 12. User List Provider
final userListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/users');
  final list = response.data['data'] as List;
  return list.map((e) => UserModel.fromJson(e)).toList();
});

// 13. Farmer Logs Provider
final farmerLogsProvider = FutureProvider.autoDispose<List<AuditTrailModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/my-audit-trails');
  final list = response.data['data']['logs'] as List;
  return list.map((e) => AuditTrailModel.fromJson(e)).toList();
});

// 14. Admin Logs Provider with Filters
class AdminLogsFilter {
  final String search;
  final String role;
  final String aktivitas;
  final String modul;
  final String status;
  final String startDate;
  final String endDate;

  AdminLogsFilter({
    this.search = '',
    this.role = '',
    this.aktivitas = '',
    this.modul = '',
    this.status = '',
    this.startDate = '',
    this.endDate = '',
  });

  Map<String, String> toMap() {
    return {
      if (search.isNotEmpty) 'search': search,
      if (role.isNotEmpty) 'role': role,
      if (aktivitas.isNotEmpty) 'aktivitas': aktivitas,
      if (modul.isNotEmpty) 'modul': modul,
      if (status.isNotEmpty) 'status': status,
      if (startDate.isNotEmpty) 'start_date': startDate,
      if (endDate.isNotEmpty) 'end_date': endDate,
    };
  }
}

final adminLogsProvider = FutureProvider.autoDispose.family<List<AuditTrailModel>, AdminLogsFilter>((ref, filter) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/audit-trails', queryParameters: filter.toMap());
  final list = response.data['data']['logs'] as List;
  return list.map((e) => AuditTrailModel.fromJson(e)).toList();
});
