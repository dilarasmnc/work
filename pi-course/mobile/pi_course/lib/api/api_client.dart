import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Android emulator için 10.0.2.2
  static const String baseUrl = "http://10.0.2.2:8000/api/";

  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));
  final storage = const FlutterSecureStorage();

  ApiClient() {
    // Varsayılan JSON başlığı
    dio.options.headers["Content-Type"] = "application/json";
  }

  Future<void> setToken(String token) async {
    await storage.write(key: "access_token", value: token);
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  Future<void> loadToken() async {
    final token = await storage.read(key: "access_token");
    if (token != null) {
      dio.options.headers["Authorization"] = "Bearer $token";
    }
  }

  Future<void> clearToken() async {
    await storage.delete(key: "access_token");
    dio.options.headers.remove("Authorization");
  }
}

final apiClient = ApiClient();
