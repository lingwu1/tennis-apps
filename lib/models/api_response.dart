/// 统一的API响应数据模型
class ApiResponse<T> {
  /// 请求是否成功
  final bool success;
  
  /// 响应消息
  final String message;
  
  /// 响应数据
  final T? data;
  
  /// HTTP状态码
  final int statusCode;
  
  /// 时间戳
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从JSON创建ApiResponse
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'] as T?,
      statusCode: json['statusCode'] ?? 0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'statusCode': statusCode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 创建成功响应
  factory ApiResponse.success({
    required T data,
    String message = 'Success',
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// 创建失败响应
  factory ApiResponse.error({
    required String message,
    T? data,
    int statusCode = 400,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// 检查是否有数据
  bool get hasData => data != null;

  /// 检查是否为空数据
  bool get isEmpty => data == null;

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, data: $data, statusCode: $statusCode, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponse<T> &&
        other.success == success &&
        other.message == message &&
        other.data == data &&
        other.statusCode == statusCode &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        data.hashCode ^
        statusCode.hashCode ^
        timestamp.hashCode;
  }
}
