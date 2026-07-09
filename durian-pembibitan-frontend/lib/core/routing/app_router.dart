import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers.dart';

// Screens
import '../../presentation/auth/login_screen.dart';
import '../../presentation/dashboard/petani_dashboard_screen.dart';
import '../../presentation/dashboard/admin_dashboard_screen.dart';
import '../../presentation/bibit/bibit_list_screen.dart';
import '../../presentation/bibit/bibit_form_screen.dart';
import '../../presentation/katalog_daun/katalog_daun_list_screen.dart';
import '../../presentation/okulasi/okulasi_list_screen.dart';
import '../../presentation/okulasi/okulasi_form_screen.dart';
import '../../presentation/jadwal_perawatan/jadwal_list_screen.dart';
import '../../presentation/jadwal_perawatan/jadwal_form_screen.dart';
import '../../presentation/riwayat_perkembangan/riwayat_list_screen.dart';
import '../../presentation/riwayat_perkembangan/riwayat_form_screen.dart';
import '../../presentation/map/map_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/audit_trail/farmer_logs_screen.dart';
import '../../presentation/audit_trail/admin_logs_screen.dart';
import '../../presentation/users/user_form_screen.dart';

/// A [ChangeNotifier] that notifies GoRouter when auth state changes,
/// triggering redirect re-evaluation.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (previous, current) {
      notifyListeners();
    });
  }
}

final _authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(_authChangeNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == '/login';

      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // If authenticated
      if (isLoggingIn) {
        return authState.role == 'admin' ? '/admin' : '/dashboard';
      }

      // Check role permissions
      final isAdminLoc = state.matchedLocation.startsWith('/admin');
      if (authState.role == 'admin' && !isAdminLoc) {
        return '/admin';
      }
      if (authState.role == 'petani' && isAdminLoc) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Farmer Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const PetaniDashboardScreen(),
      ),
      GoRoute(
        path: '/bibits',
        builder: (context, state) => const BibitListScreen(),
      ),
      GoRoute(
        path: '/bibits/form',
        builder: (context, state) {
          final bibitId = state.uri.queryParameters['id'];
          return BibitFormScreen(bibitId: bibitId);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/katalog',
        builder: (context, state) => const KatalogDaunListScreen(),
      ),
      GoRoute(
        path: '/okulasi',
        builder: (context, state) => const OkulasiListScreen(),
      ),
      GoRoute(
        path: '/okulasi/form',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final bibitId = state.uri.queryParameters['bibitId'];
          return OkulasiFormScreen(id: id, bibitId: bibitId);
        },
      ),
      GoRoute(
        path: '/jadwal',
        builder: (context, state) => const JadwalListScreen(),
      ),
      GoRoute(
        path: '/jadwal/form',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final bibitId = state.uri.queryParameters['bibitId'];
          return JadwalFormScreen(id: id, bibitId: bibitId);
        },
      ),
      GoRoute(
        path: '/riwayat',
        builder: (context, state) {
          final bibitId = state.uri.queryParameters['bibitId'] ?? '';
          return RiwayatListScreen(bibitId: bibitId);
        },
      ),
      GoRoute(
        path: '/riwayat/form',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final bibitId = state.uri.queryParameters['bibitId'] ?? '';
          return RiwayatFormScreen(id: id, bibitId: bibitId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/my-logs',
        builder: (context, state) => const FarmerLogsScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users/form',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return UserFormScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AdminLogsScreen(),
      ),
    ],
  );
});

