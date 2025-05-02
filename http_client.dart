import 'package:dio/dio.dart';
import 'package:vccm/utils/constants.dart';

class SecureHttpClient {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  SecureHttpClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        options.headers['Authorization'] = 'Bearer ${AppConstants.apiKey}';
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle token refresh here
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> securePost(String url, dynamic data) async {
    return _dio.post(url, data: data);
  }
}