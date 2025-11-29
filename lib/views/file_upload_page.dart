import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../api/upload_file.dart';
import 'dart:developer' as developer;

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final List<UploadFileItem> _uploadFiles = [];
  bool _isUploading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _getAzBlob() async {
  //   try {
  //     // 调用getAzBlob接口
  //     await ApiUploadFile.getAzBlob("mp4");
  //   } catch (e) {
  //     _showErrorSnackBar('获取配置失败: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _uploadFiles.isEmpty ? _buildEmptyState() : _buildFileList(),
            ),
            _buildChooseFileButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'upload',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (_uploadFiles.isNotEmpty)
            GestureDetector(
              onTap: _toggleEditMode,
              child: Text(
                _isEditMode ? 'Done' : 'Edit',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 云朵图标和文件图标
          Stack(
            alignment: Alignment.center,
            children: [
              // 背景文件图标
              ...List.generate(5, (index) {
                final colors = [
                  const Color(0xFFE879F9), // 紫色
                  const Color(0xFFFDE047), // 黄色
                  const Color(0xFFFB923C), // 橙色
                  const Color(0xFF60A5FA), // 蓝色
                  const Color(0xFF34D399), // 绿色
                ];
                final positions = [
                  const Offset(-30, -20),
                  const Offset(30, -20),
                  const Offset(-40, 10),
                  const Offset(40, 10),
                  const Offset(0, 30),
                ];
                return Positioned(
                  left: positions[index].dx,
                  top: positions[index].dy,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _getFileIcon(index),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                );
              }),
              // 云朵图标
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF93C5FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            '选择文件开始上传',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _uploadFiles.length,
      itemBuilder: (context, index) {
        final file = _uploadFiles[index];
        return _buildFileItem(file, index);
      },
    );
  }

  Widget _buildFileItem(UploadFileItem file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 编辑模式下的删除按钮
          if (_isEditMode) ...[
            GestureDetector(
              onTap: () => _deleteFile(index),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // 文件图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getFileTypeColor(file.fileName),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getFileTypeAbbreviation(file.fileName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // 进度条
                LinearProgressIndicator(
                  value: file.progress,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(file.status),
                  ),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 状态图标或操作按钮
          if (_isEditMode)
            _buildEditActions(file, index)
          else
            _buildStatusIcon(file.status),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFF10B981),
          size: 20,
        );
      case UploadStatus.uploading:
        return const Icon(
          Icons.play_circle,
          color: Color(0xFFF59E0B),
          size: 20,
        );
      case UploadStatus.paused:
        return const Icon(
          Icons.pause_circle,
          color: Color(0xFF3B82F6),
          size: 20,
        );
      case UploadStatus.failed:
        return const Icon(
          Icons.error,
          color: Color(0xFFEF4444),
          size: 20,
        );
      case UploadStatus.pending:
        return const Icon(
          Icons.schedule,
          color: Color(0xFF6B7280),
          size: 20,
        );
    }
  }

  Widget _buildChooseFileButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _pickFiles,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Choose File',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm', 'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            // 添加日志输出
            developer.log('选择文件: ${file.name}, 路径: $file');
            
            // 创建上传文件项
            final uploadFile = UploadFileItem(
              fileName: file.name,
              filePath: file.path!,
              status: UploadStatus.pending,
              videoFormat: "",
              videoId: "",
              progress: 0.0,
            );
            
            setState(() {
              _uploadFiles.add(uploadFile);
            });
            
            // 使用新的上传方法
            _uploadFile(uploadFile);
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('选择文件失败: $e');
    }
  }


  Future<void> _uploadFile(UploadFileItem file) async {
    setState(() {
      file.status = UploadStatus.uploading;
      _isUploading = true;
    });

    try {
      // 1. 获取Azure Blob Storage的SAS URL
      String ext = _getFileExtension(file.fileName);
      final blobData = await ApiUploadFile.getAzBlob(ext);
      if (blobData == null || blobData['sas_url'] == null) {
        setState(() {
          file.status = UploadStatus.failed;
          _isUploading = _uploadFiles.any((f) => f.status == UploadStatus.uploading);
        });
        _showErrorSnackBar('获取上传地址失败');
        return;
      }

      // 2. 使用SAS URL直接上传文件到Azure Blob Storage
      final success = await ApiUploadFile.uploadFileToBlob(
        blobData['sas_url'],
        File(file.filePath),
        onProgress: (progress) {
          setState(() {
            file.progress = progress;
          });
        },
      );

      setState(() async{
        if (success) {
          file.status = UploadStatus.completed;
          developer.log('文件上传成功: ${file.fileName}');
          await ApiUploadFile.savedVideo(blobData['video_id'], ext);
          
            // 每25秒调用一次getAnalysis接口，直到status_message是100%
            // 记录开始时间
            final startTime = DateTime.now();
            Timer.periodic(const Duration(seconds: 25), (timer) async {
              try {
                // 检查是否超过5分钟
                final elapsed = DateTime.now().difference(startTime);
                if (elapsed.inMinutes >= 5) {
                  timer.cancel();
                  developer.log('分析超时，已停止检查: ${file.videoId}');
                  return;
                }
                
                final analysisResult = await ApiUploadFile.getAnalysis(file.videoId);
                if (analysisResult != null && analysisResult['status_message'] == '100%') {
                  timer.cancel();
                  developer.log('分析完成: ${file.videoId}');
                }
              } catch (e) {
                developer.log('获取分析结果失败: $e');
              }
            });

        } else {
          file.status = UploadStatus.failed;
          developer.log('文件上传失败: ${file.fileName}');
        }
        _isUploading = _uploadFiles.any((f) => f.status == UploadStatus.uploading);
      });
    } catch (e) {
      setState(() {
        file.status = UploadStatus.failed;
        _isUploading = _uploadFiles.any((f) => f.status == UploadStatus.uploading);
      });
      _showErrorSnackBar('上传失败: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }


  Widget _buildEditActions(UploadFileItem file, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (file.status == UploadStatus.uploading || file.status == UploadStatus.paused)
          GestureDetector(
            onTap: () => _toggleUpload(file, index),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: file.status == UploadStatus.uploading 
                    ? const Color(0xFFF59E0B) 
                    : const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                file.status == UploadStatus.uploading ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        if (file.status == UploadStatus.failed)
          GestureDetector(
            onTap: () => _retryUpload(file, index),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  void _deleteFile(int index) {
    setState(() {
      _uploadFiles.removeAt(index);
      _isUploading = _uploadFiles.any((f) => f.status == UploadStatus.uploading);
    });
  }

  void _toggleUpload(UploadFileItem file, int index) {
    setState(() {
      if (file.status == UploadStatus.uploading) {
        file.status = UploadStatus.paused;
        _isUploading = _uploadFiles.any((f) => f.status == UploadStatus.uploading);
      } else if (file.status == UploadStatus.paused) {
        file.status = UploadStatus.uploading;
        _isUploading = true;
        _uploadFile(file);
      }
    });
  }

  void _retryUpload(UploadFileItem file, int index) {
    setState(() {
      file.status = UploadStatus.uploading;
      file.progress = 0.0;
      _isUploading = true;
    });
    _uploadFile(file);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 获取文件扩展名
  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  IconData _getFileIcon(int index) {
    final icons = [
      Icons.description,
      Icons.image,
      Icons.video_file,
      Icons.audio_file,
      Icons.folder,
    ];
    return icons[index % icons.length];
  }

  Color _getFileTypeColor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'aep':
        return const Color(0xFF8B5CF6); // 紫色
      case 'psd':
        return const Color(0xFF3B82F6); // 蓝色
      case 'ai':
        return const Color(0xFFF59E0B); // 橙色
      case 'mp4':
      case 'mov':
      case 'avi':
        return const Color(0xFFEF4444); // 红色
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Color(0xFF10B981); // 绿色
      default:
        return const Color(0xFF6B7280); // 灰色
    }
  }

  String _getFileTypeAbbreviation(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'aep':
        return 'AE';
      case 'psd':
        return 'PS';
      case 'ai':
        return 'AI';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'MP4';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'IMG';
      default:
        return 'DOC';
    }
  }

  Color _getProgressColor(UploadStatus status) {
    switch (status) {
      case UploadStatus.completed:
        return const Color(0xFF10B981); // 绿色
      case UploadStatus.uploading:
        return const Color(0xFFF59E0B); // 黄色
      case UploadStatus.paused:
        return const Color(0xFF3B82F6); // 蓝色
      case UploadStatus.failed:
        return const Color(0xFFEF4444); // 红色
      default:
        return const Color(0xFF3B82F6); // 蓝色
    }
  }
}

class UploadFileItem {
  final String fileName;
  final String filePath;
  UploadStatus status;
  double progress;
  String videoId;
  String videoFormat;

  UploadFileItem({
    required this.fileName,
    required this.filePath,
    required this.status,
    required this.progress,
    required this.videoId,
    required this.videoFormat
  });
}

enum UploadStatus {
  pending,
  uploading,
  paused,
  completed,
  failed,
}
