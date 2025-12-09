import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/api_exception.dart';

/// Dio网络请求管理器
class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  late Dio _dio;
  static const String _baseUrl =
      'https://tennis.makingdayscount.net'; // 替换为您的API端点
  static const int _connectTimeout = 30000; // 连接超时时间（毫秒）
  static const int _receiveTimeout = 30000; // 接收超时时间（毫秒）
  static const int _sendTimeout = 30000; // 发送超时时间（毫秒）

  /// 初始化Dio配置
  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        sendTimeout: const Duration(milliseconds: _sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // 添加拦截器
    _addInterceptors();
  }

  /// 添加拦截器
  void _addInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加认证token
          _addAuthToken(options);

          // 打印请求日志
          if (kDebugMode) {
            developer.log('🚀 Request: ${options.method} ${options.uri}');
            developer.log('📤 Headers: ${options.headers}');
            if (options.data != null) {
              developer.log('📦 Data: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // 打印响应日志
          if (kDebugMode) {
            developer.log(
              '✅ Response: ${response.statusCode} ${response.requestOptions.uri}',
            );
            developer.log('📥 Data: ${response.data}');
          }

          handler.next(response);
        },
        onError: (error, handler) {
          // 打印错误日志
          if (kDebugMode) {
            developer.log('❌ Error: ${error.message}');
            developer.log('🔍 Error Type: ${error.type}');
          }

          handler.next(error);
        },
      ),
    );

    // 日志拦截器（仅在调试模式下启用）
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => developer.log(obj.toString()),
        ),
      );
    }
  }

  /// 添加认证token
  void _addAuthToken(RequestOptions options) {
    // 这里可以从本地存储或状态管理中获取token
    // 示例：从SharedPreferences获取token
    // final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('auth_token'));
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    options.headers['x-dev-token'] =
        'a4f361b2c5184b7b9f6e8e1d0c3a5f92e4c6d8a9b0f2e1d4c5a7b9e2f4d6c8a';
  }

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 文件上传
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        ...?data,
      });

      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 多文件上传
  Future<ApiResponse<T>> uploadMultipleFiles<T>(
    String path,
    List<File> files, {
    String fieldName = 'files',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final multipartFiles = await Future.wait(
        files.map(
          (file) => MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );

      final formData = FormData.fromMap({fieldName: multipartFiles, ...?data});

      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 下载文件
  Future<ApiResponse<T>> downloadFile<T>(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        options: options,
        cancelToken: cancelToken,
      );

      return ApiResponse<T>(
        success: true,
        message: 'Download completed',
        data: null,
        statusCode: 200,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse<T>(
        success: true,
        message: 'Request successful',
        data: response.data as T?,
        statusCode: statusCode,
      );
    } else {
      return ApiResponse<T>(
        success: false,
        message: 'Request failed with status: $statusCode',
        data: null,
        statusCode: statusCode,
      );
    }
  }

  /// 处理Dio错误
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: '网络连接超时，请检查网络设置',
          type: ApiExceptionType.timeout,
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        String message = '请求失败';

        switch (statusCode) {
          case 400:
            message = '请求参数错误';
            break;
          case 401:
            message = '未授权，请重新登录';
            break;
          case 403:
            message = '禁止访问';
            break;
          case 404:
            message = '请求的资源不存在';
            break;
          case 500:
            message = '服务器内部错误';
            break;
          default:
            message = '请求失败，状态码：$statusCode';
        }

        return ApiException(
          message: message,
          type: ApiExceptionType.badResponse,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: '请求已取消',
          type: ApiExceptionType.cancel,
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: '网络连接失败，请检查网络设置',
          type: ApiExceptionType.connectionError,
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: '证书验证失败',
          type: ApiExceptionType.badCertificate,
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: '未知错误：${error.message}',
          type: ApiExceptionType.unknown,
          statusCode: error.response?.statusCode,
        );
    }
  }

  /// 获取Dio实例（用于高级用法）
  Dio get dio => _dio;

  /// 更新基础URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// 添加请求头
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// 移除请求头
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// 清除所有请求头
  void clearHeaders() {
    _dio.options.headers.clear();
  }
}
