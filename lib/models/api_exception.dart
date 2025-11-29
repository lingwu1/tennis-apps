/// API异常类型枚举
enum ApiExceptionType {
  /// 网络超时
  timeout,
  
  /// 网络连接错误
  connectionError,
  
  /// 响应错误
  badResponse,
  
  /// 请求取消
  cancel,
  
  /// 证书错误
  badCertificate,
  
  /// 未知错误
  unknown,
}

/// 自定义API异常类
class ApiException implements Exception {
  /// 错误消息
  final String message;
  
  /// 异常类型
  final ApiExceptionType type;
  
  /// HTTP状态码
  final int? statusCode;
  
  /// 原始错误
  final dynamic originalError;
  
  /// 时间戳
  final DateTime timestamp;

  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 创建超时异常
  factory ApiException.timeout({
    String message = '请求超时',
    int? statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message,
      type: ApiExceptionType.timeout,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  /// 创建连接错误异常
  factory ApiException.connectionError({
    String message = '网络连接失败',
    int? statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message,
      type: ApiExceptionType.connectionError,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  /// 创建响应错误异常
  factory ApiException.badResponse({
    required String message,
    required int statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message,
      type: ApiExceptionType.badResponse,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  /// 创建请求取消异常
  factory ApiException.cancel({
    String message = '请求已取消',
    int? statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message,
      type: ApiExceptionType.cancel,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  /// 创建证书错误异常
  factory ApiException.badCertificate({
    String message = '证书验证失败',
    int? statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message,
      type: ApiExceptionType.badCertificate,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  /// 创建未知错误异常
  factory ApiException.unknown({
    required String message,
    int? statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message,
      type: ApiExceptionType.unknown,
      statusCode: statusCode,
      originalError: originalError,
    );
  }

  /// 从DioException创建ApiException
  factory ApiException.fromDioException(dynamic dioException) {
    if (dioException is Exception) {
      return ApiException.unknown(
        message: dioException.toString(),
        originalError: dioException,
      );
    }
    
    return ApiException.unknown(
      message: '未知错误',
      originalError: dioException,
    );
  }

  /// 检查是否为网络相关错误
  bool get isNetworkError {
    return type == ApiExceptionType.timeout ||
           type == ApiExceptionType.connectionError;
  }

  /// 检查是否为服务器错误
  bool get isServerError {
    return type == ApiExceptionType.badResponse &&
           statusCode != null &&
           statusCode! >= 500;
  }

  /// 检查是否为客户端错误
  bool get isClientError {
    return type == ApiExceptionType.badResponse &&
           statusCode != null &&
           statusCode! >= 400 &&
           statusCode! < 500;
  }

  /// 检查是否为认证错误
  bool get isAuthError {
    return statusCode == 401 || statusCode == 403;
  }

  /// 检查是否为未找到错误
  bool get isNotFoundError {
    return statusCode == 404;
  }

  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    switch (type) {
      case ApiExceptionType.timeout:
        return '网络连接超时，请检查网络设置后重试';
      case ApiExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case ApiExceptionType.badResponse:
        if (isAuthError) {
          return '登录已过期，请重新登录';
        } else if (isNotFoundError) {
          return '请求的资源不存在';
        } else if (isServerError) {
          return '服务器繁忙，请稍后重试';
        } else if (isClientError) {
          return '请求参数错误，请检查后重试';
        }
        return message;
      case ApiExceptionType.cancel:
        return '请求已取消';
      case ApiExceptionType.badCertificate:
        return '网络证书验证失败';
      case ApiExceptionType.unknown:
        return '操作失败，请重试';
    }
  }

  @override
  String toString() {
    return 'ApiException{message: $message, type: $type, statusCode: $statusCode, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiException &&
        other.message == message &&
        other.type == type &&
        other.statusCode == statusCode &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        type.hashCode ^
        statusCode.hashCode ^
        timestamp.hashCode;
  }
}
