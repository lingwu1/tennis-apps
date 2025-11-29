import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../api/api_manager.dart';
import '../api/upload_file.dart';
import '../models/api_response.dart';
import '../models/api_exception.dart';

class VideoUploadService {
  static final ApiManager _apiManager = ApiManager();
  
  /// 上传视频文件
  static Future<ApiResponse<Map<String, dynamic>>> uploadVideo({
    required File videoFile,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      // 检查文件大小
      if (!isFileSizeValid(videoFile)) {
        return ApiResponse.error(
          message: '文件大小超过限制（最大100MB）',
          statusCode: 400,
        );
      }
      
      // 检查文件格式
      if (!isSupportedVideoFormat(fileName)) {
        return ApiResponse.error(
          message: '不支持的文件格式，请选择MP4、MOV、AVI、MKV或WEBM格式',
          statusCode: 400,
        );
      }
      
      // 1. 获取Azure Blob Storage的SAS URL
      final blobData = await ApiUploadFile.getAzBlob('video');
      if (blobData == null || blobData['sas_url'] == null) {
        return ApiResponse.error(
          message: '获取上传地址失败',
          statusCode: 500,
        );
      }

      // 2. 使用SAS URL直接上传文件到Azure Blob Storage
      final success = await ApiUploadFile.uploadFileToBlob(
        blobData['sas_url'],
        videoFile,
        onProgress: onProgress,
      );
      
      if (success) {
        return ApiResponse.success(
          data: {
            'videoId': 'video_${DateTime.now().millisecondsSinceEpoch}',
            'fileName': fileName,
            'fileSize': await videoFile.length(),
            'fileType': 'video',
            'uploadTime': DateTime.now().toIso8601String(),
          },
          message: 'Video uploaded successfully',
        );
      } else {
        return ApiResponse.error(
          message: '视频上传失败',
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
    required File videoFile,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      // 检查文件大小
      if (!isFileSizeValid(videoFile)) {
        return ApiResponse.error(
          message: '文件大小超过限制（最大100MB）',
          statusCode: 400,
        );
      }
      
      // 检查文件格式
      if (!isSupportedVideoFormat(fileName)) {
        return ApiResponse.error(
          message: '不支持的文件格式，请选择MP4、MOV、AVI、MKV或WEBM格式',
          statusCode: 400,
        );
      }
      
      // 1. 获取Azure Blob Storage的SAS URL
      final blobData = await ApiUploadFile.getAzBlob('video');
      if (blobData == null || blobData['sas_url'] == null) {
        return ApiResponse.error(
          message: '获取上传地址失败',
          statusCode: 500,
        );
      }

      // 2. 使用SAS URL直接上传文件到Azure Blob Storage
      final success = await ApiUploadFile.uploadFileToBlob(
        blobData['sas_url'],
        videoFile,
        onProgress: onProgress,
      );
      
      if (success) {
        return ApiResponse.success(
          data: {
            'videoId': 'video_${DateTime.now().millisecondsSinceEpoch}',
            'fileName': fileName,
            'fileSize': await videoFile.length(),
            'uploadTime': DateTime.now().toIso8601String(),
          },
          message: 'Video uploaded successfully',
        );
      } else {
        return ApiResponse.error(
          message: '视频上传失败',
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
  
  /// 获取临时目录
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
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
  
  /// 检查是否为支持的视频格式
  static bool isSupportedVideoFormat(String fileName) {
    final supportedFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
    final extension = getFileExtension(fileName);
    return supportedFormats.contains(extension);
  }
  
  /// 获取视频上传历史
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
  
  /// 删除已上传的视频
  static Future<ApiResponse<bool>> deleteVideo(String videoId) async {
    try {
      final response = await _apiManager.delete<bool>(
        '/upload/video/$videoId',
      );
      return response;
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.userFriendlyMessage,
        statusCode: e.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: '删除视频失败：$e',
        statusCode: 500,
      );
    }
  }
  
  /// 获取视频上传状态
  static Future<ApiResponse<Map<String, dynamic>>> getUploadStatus(String videoId) async {
    try {
      final response = await _apiManager.get<Map<String, dynamic>>(
        '/upload/status/$videoId',
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
