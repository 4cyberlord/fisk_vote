import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exceptions.dart';

/// API Client wrapper using Dio.
///
/// Handles all HTTP requests with proper error handling, logging, and interceptors.
class ApiClient {
  late final Dio _dio;
  bool _tokenLoaded = false;

  ApiClient() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
    _loadTokenFromStorage();
  }

  /// Load token from secure storage and set it
  Future<void> _loadTokenFromStorage() async {
    if (_tokenLoaded) return;
    try {
      final token = await TokenStorage.instance.getToken();
      if (token != null && token.isNotEmpty) {
        setAuthToken(token);
      }
      _tokenLoaded = true;
    } catch (e) {
      // Token loading failed, continue without token
      debugPrint('Failed to load token from storage: $e');
    }
  }

  /// Base options for Dio
  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: AppConfig.apiEndpoint,
    connectTimeout: AppConfig.apiTimeoutDuration,
    receiveTimeout: AppConfig.apiTimeoutDuration,
    sendTimeout: AppConfig.apiTimeoutDuration,
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  );

  /// Setup interceptors for logging and error handling
  void _setupInterceptors() {
    // Logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint('🌐 API: $object'),
        ),
      );
    }

    // Error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Transform DioException to our custom exceptions
          final apiException = _handleDioError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    // Also save to secure storage
    TokenStorage.instance.saveToken(token);
    _tokenLoaded = true;
  }

  /// Remove authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    // Also remove from secure storage
    TokenStorage.instance.deleteToken();
    _tokenLoaded = false;
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Ensure token is loaded before making request
      if (!_tokenLoaded) {
        await _loadTokenFromStorage();
      }
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Ensure token is loaded before making request
      if (!_tokenLoaded) {
        await _loadTokenFromStorage();
      }
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// POST request with multipart form data (for file uploads)
  Future<Response<T>> postMultipart<T>(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Ensure token is loaded before making request
      if (!_tokenLoaded) {
        await _loadTokenFromStorage();
      }

      // Create FormData from fields
      final formData = FormData.fromMap(fields);

      // Override content type for multipart
      final requestOptions = options ?? Options();
      final headers = Map<String, dynamic>.from(requestOptions.headers ?? {});
      headers['Content-Type'] = 'multipart/form-data';

      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// Extract our custom exception from DioException
  ApiException _extractException(DioException e) {
    if (e.error is ApiException) {
      return e.error as ApiException;
    }
    return _handleDioError(e);
  }

  /// Transform DioException to ApiException
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.badCertificate:
        return const ApiException(message: 'Security certificate error.');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Connection refused') == true) {
          return const NetworkException();
        }
        return UnknownException(
          message: error.message ?? 'An unexpected error occurred.',
          data: error.error,
        );
    }
  }

  /// Handle bad response (4xx, 5xx errors)
  ApiException _handleBadResponse(Response? response) {
    if (response == null) {
      return const UnknownException();
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract message and errors from response
    String message = 'An error occurred';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['error'] as String? ??
          'An error occurred';
      errors = data['errors'] as Map<String, dynamic>?;
    }

    switch (statusCode) {
      case 400:
        return ServerException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );

      case 401:
        return UnauthorizedException(message: message);

      case 403:
        return ForbiddenException(message: message);

      case 404:
        return NotFoundException(message: message);

      case 422:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );

      case 429:
        return const ApiException(
          message: 'Too many requests. Please wait and try again.',
          statusCode: 429,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );

      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );
    }
  }
}
