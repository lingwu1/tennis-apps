import 'dart:async';
import 'dart:io';
import '../api/api_manager.dart';
import '../api/upload_file.dart';
import '../models/api_response.dart';
import '../models/api_exception.dart';

class FileUploadService {
  static final ApiManager _apiManager = ApiManager();
  
  /// 上传文件
  static Future<ApiResponse<Map<String, dynamic>>> uploadFile({
    required File file,
    required String fileName,
    required Function(double) onProgress,
    String? fileType,
  }) async {
    try {
      // 检查文件大小
      if (!isFileSizeValid(file)) {
        return ApiResponse.error(
          message: '文件大小超过限制（最大100MB）',
          statusCode: 400,
        );
      }
      
      // 检查文件格式
      if (!isSupportedFileFormat(fileName)) {
        return ApiResponse.error(
          message: '不支持的文件格式',
          statusCode: 400,
        );
      }
      
      // 1. 获取Azure Blob Storage的SAS URL
      final blobData = await ApiUploadFile.getAzBlob(_getFileType(fileName));
      if (blobData == null || blobData['sas_url'] == null) {
        return ApiResponse.error(
          message: '获取上传地址失败',
          statusCode: 500,
        );
      }

      // 2. 使用SAS URL直接上传文件到Azure Blob Storage
      final success = await ApiUploadFile.uploadFileToBlob(
        blobData['sas_url'],
        file,
        onProgress: onProgress,
      );
      
      if (success) {
        return ApiResponse.success(
          data: {
            'fileId': 'file_${DateTime.now().millisecondsSinceEpoch}',
            'fileName': fileName,
            'fileSize': await file.length(),
            'fileType': fileType ?? _getFileType(fileName),
            'uploadTime': DateTime.now().toIso8601String(),
          },
          message: 'File uploaded successfully',
        );
      } else {
        return ApiResponse.error(
          message: '文件上传失败',
          statusCode: 500,
        );
      }
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.userFriendlyMessage,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: '上传失败：$e',
        statusCode: 500,
      );
    }
  }
  
  /// 模拟上传（用于演示）
  static Future<ApiResponse<Map<String, dynamic>>> simulateUpload({
    required File file,
    required String fileName,
    required Function(double) onProgress,
    String? fileType,
  }) async {
    try {
      // 检查文件大小
      if (!isFileSizeValid(file)) {
        return ApiResponse.error(
          message: '文件大小超过限制（最大100MB）',
          statusCode: 400,
        );
      }
      
      // 检查文件格式
      if (!isSupportedFileFormat(fileName)) {
        return ApiResponse.error(
          message: '不支持的文件格式',
          statusCode: 400,
        );
      }
      
      // 1. 获取Azure Blob Storage的SAS URL
      final blobData = await ApiUploadFile.getAzBlob(_getFileType(fileName));
      if (blobData == null || blobData['sas_url'] == null) {
        return ApiResponse.error(
          message: '获取上传地址失败',
          statusCode: 500,
        );
      }

      // 2. 使用SAS URL直接上传文件到Azure Blob Storage
      final success = await ApiUploadFile.uploadFileToBlob(
        blobData['sas_url'],
        file,
        onProgress: onProgress,
      );
      
      if (success) {
        return ApiResponse.success(
          data: {
            'fileId': 'file_${DateTime.now().millisecondsSinceEpoch}',
            'fileName': fileName,
            'fileSize': await file.length(),
            'fileType': fileType ?? _getFileType(fileName),
            'uploadTime': DateTime.now().toIso8601String(),
          },
          message: 'File uploaded successfully',
        );
      } else {
        return ApiResponse.error(
          message: '文件上传失败',
          statusCode: 500,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Upload error: $e',
        statusCode: 500,
      );
    }
  }
  
  /// 检查文件大小限制（例如：100MB）
  static bool isFileSizeValid(File file) {
    const int maxSizeInBytes = 100 * 1024 * 1024; // 100MB
    return file.lengthSync() <= maxSizeInBytes;
  }
  
  /// 获取文件扩展名
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }
  
  /// 检查是否为支持的文件格式
  static bool isSupportedFileFormat(String fileName) {
    final supportedFormats = [
      // 视频格式
      'mp4', 'mov', 'avi', 'mkv', 'webm',
      // 图片格式
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
      // 文档格式
      'pdf', 'doc', 'docx', 'txt', 'rtf',
      // 设计文件格式
      'psd', 'ai', 'aep', 'prproj', 'sketch',
      // 音频格式
      'mp3', 'wav', 'aac', 'flac',
    ];
    final extension = getFileExtension(fileName);
    return supportedFormats.contains(extension);
  }
  
  /// 获取文件类型
  static String _getFileType(String fileName) {
    final extension = getFileExtension(fileName);
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return 'video';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'image';
    } else if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return 'document';
    } else if (['psd', 'ai', 'aep', 'prproj', 'sketch'].contains(extension)) {
      return 'design';
    } else if (['mp3', 'wav', 'aac', 'flac'].contains(extension)) {
      return 'audio';
    } else {
      return 'other';
    }
  }
  
  /// 获取文件上传历史
  static Future<ApiResponse<List<Map<String, dynamic>>>> getUploadHistory() async {
    try {
      final response = await _apiManager.get<List<Map<String, dynamic>>>(
        '/upload/history',
      );
      return response;
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.userFriendlyMessage,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: '获取上传历史失败：$e',
        statusCode: 500,
      );
    }
  }
  
  /// 删除已上传的文件
  static Future<ApiResponse<bool>> deleteFile(String fileId) async {
    try {
      final response = await _apiManager.delete<bool>(
        '/upload/file/$fileId',
      );
      return response;
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.userFriendlyMessage,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: '删除文件失败：$e',
        statusCode: 500,
      );
    }
  }
  
  /// 获取文件上传状态
  static Future<ApiResponse<Map<String, dynamic>>> getUploadStatus(String fileId) async {
    try {
      final response = await _apiManager.get<Map<String, dynamic>>(
        '/upload/status/$fileId',
      );
      return response;
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.userFriendlyMessage,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: '获取上传状态失败：$e',
        statusCode: 500,
      );
    }
  }
}
