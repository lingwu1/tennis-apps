import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_manager.dart';
import '../models/api_exception.dart';

/// API使用示例
class ApiUploadFile{
  static final ApiManager _apiManager = ApiManager();

  /// 初始化API管理器
  static void init() {
    _apiManager.init();
  }
  /// POST请求获取blob地址
  static Future<Map<String, dynamic>?> getAzBlob(String videoFormat) async {
    try {
      final response = await _apiManager.post<Map<String, dynamic>>(
        '/api/v1/upload/request',
        data: {
          'user_id': '123',
          'video_format': videoFormat
        },
      );

      if (response.success) {
        developer.log('获取blob地址成功：${response.data}');
        return response.data;
      } else {
        developer.log('获取blob地址失败：${response.message}');
        return null;
      }
    } on ApiException catch (e) {
      developer.log('API错误：${e.userFriendlyMessage}');
      return null;
    }
  }

    /// 保存文件
  static Future<Map<String, dynamic>?> savedVideo(String videoId, String videoFormat) async {
    try {
      final response = await _apiManager.post<Map<String, dynamic>>(
        '/api/v1/videos/$videoId/metadata',
        data: {
          'user_id': '123',
          'file_size': 1,
          'video_format': videoFormat
        },
      );

      if (response.success) {
        developer.log('savedVideo成功：${response.data}');
        return response.data;
      } else {
        developer.log('savedVideo失败：${response.message}');
        return null;
      }
    } on ApiException catch (e) {
      developer.log('API错误：${e.userFriendlyMessage}');
      return null;
    }
  }
  // 获取结果
    static Future<Map<String, dynamic>?> getAnalysis(String videoId) async {
    try {
      final response = await _apiManager.get<Map<String, dynamic>>(
        '/videos/$videoId/analysis'
      );

      if (response.success) {
        developer.log('getAnalysis success${response.data}');
        return response.data;
      } else {
        developer.log('getAnalysis failed${response.message}');
        return null;
      }
    } on ApiException catch (e) {
      developer.log('API错误：${e.userFriendlyMessage}');
      return null;
    }
  }

  /// 使用SAS URL直接上传文件到Azure Blob Storage
  static Future<bool> uploadFileToBlob(
    String sasUrl, 
    File file, {
    Function(double)? onProgress,
  }) async {
    try {
      // 读取文件内容
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // 根据文件扩展名确定内容类型
      String contentType = _getContentType(fileExtension);
      
      // 创建PUT请求
      var request = http.Request('PUT', Uri.parse(sasUrl));
      request.headers['Content-Type'] = contentType;
      request.headers['Content-Length'] = fileBytes.length.toString();
      request.headers['x-ms-blob-type'] = 'BlockBlob';
      request.bodyBytes = fileBytes;
      
      // 发送请求并监听进度
      var response = await request.send();
      
      // 监听上传进度
      if (onProgress != null) {
        int totalBytes = fileBytes.length;
        int sentBytes = 0;
        
        // 由于http包的限制，我们模拟进度更新
        // 在实际应用中，可能需要使用支持进度回调的HTTP客户端
        for (int i = 0; i <= 100; i += 5) {
          await Future.delayed(const Duration(milliseconds: 50));
          onProgress(i / 100);
        }
      }
      
      if (response.statusCode == 201) {
        developer.log('文件上传成功');
        return true;
      } else {
        developer.log('文件上传失败: ${response.statusCode} - ${response.reasonPhrase}');
        // 读取响应内容以获取更详细的错误信息
        final responseBody = await response.stream.bytesToString();
        developer.log('错误详情: $responseBody');
        return false;
      }
    } catch (e) {
      developer.log('上传文件时发生错误: $e');
      return false;
    }
  }

  /// 根据文件扩展名获取内容类型
  static String _getContentType(String extension) {
    switch (extension) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

}