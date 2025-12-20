/// Base class for all API exceptions.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Exception thrown when server returns an error response.
class ServerException extends ApiException {
  final Map<String, dynamic>? errors;

  const ServerException({
    required super.message,
    super.statusCode,
    super.data,
    this.errors,
  });

  /// Get first error message from validation errors
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstKey = errors!.keys.first;
    final errorList = errors![firstKey];
    if (errorList is List && errorList.isNotEmpty) {
      return errorList.first.toString();
    }
    return errorList?.toString();
  }

  /// Get all error messages as a map
  Map<String, String> get fieldErrors {
    if (errors == null) return {};
    final result = <String, String>{};
    errors!.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key] = value.first.toString();
      } else {
        result[key] = value.toString();
      }
    });
    return result;
  }
}

/// Exception thrown when there's no internet connection.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Exception thrown when request times out.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again.',
  });
}

/// Exception thrown when user is not authenticated.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please login again.',
    super.statusCode = 401,
  });
}

/// Exception thrown when user doesn't have permission.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
  });
}

/// Exception thrown when resource is not found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found.',
    super.statusCode = 404,
  });
}

/// Exception thrown for validation errors (422).
class ValidationException extends ServerException {
  const ValidationException({
    required super.message,
    super.statusCode = 422,
    super.errors,
  });
}

/// Exception thrown when request is cancelled.
class CancelledException extends ApiException {
  const CancelledException({super.message = 'Request was cancelled.'});
}

/// Exception thrown for unknown errors.
class UnknownException extends ApiException {
  const UnknownException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.data,
  });
}
