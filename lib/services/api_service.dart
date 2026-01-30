import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle unauthorized (session expired)
        }
        return handler.next(e);
      },
    ));
  }

  // Get instance
  Dio get dio => _dio;

  // Storage helpers
  Future<void> saveToken(String token) => _storage.write(key: 'jwt', value: token);
  Future<void> deleteToken() => _storage.delete(key: 'jwt');
  Future<String?> getToken() => _storage.read(key: 'jwt');
}
