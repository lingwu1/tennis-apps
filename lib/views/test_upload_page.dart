import 'package:flutter/material.dart';

class TestUploadPage extends StatelessWidget {
  const TestUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Upload'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 80,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 20),
            const Text(
              'File Upload Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '根据图片实现的功能包括：',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem(
                    icon: Icons.cloud_upload,
                    text: '初始状态：云朵图标和文件图标展示',
                  ),
                  _FeatureItem(
                    icon: Icons.file_present,
                    text: '文件选择：支持多文件选择',
                  ),
                  _FeatureItem(
                    icon: Icons.timeline,
                    text: '进度显示：实时上传进度条',
                  ),
                  _FeatureItem(
                    icon: Icons.check_circle,
                    text: '状态管理：完成、上传中、暂停、失败',
                  ),
                  _FeatureItem(
                    icon: Icons.edit,
                    text: '编辑模式：删除、暂停/恢复、重试',
                  ),
                  _FeatureItem(
                    icon: Icons.file_download,
                    text: '文件类型：支持多种格式（视频、图片、文档等）',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '开始上传文件',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
