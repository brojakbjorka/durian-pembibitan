import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'secure_storage_service.dart';

class DioClient {
  final Dio _dio = Dio();
  final SecureStorageService _secureStorage;

  DioClient(this._secureStorage) {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // If we receive 401 Unauthorized, we can handle it or trigger logout
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
