# Dio网络请求封装使用指南

本项目使用Dio封装了统一的网络请求管理器，提供了完整的HTTP请求功能、错误处理、文件上传下载等功能。

## 目录结构

```
lib/
├── api/
│   ├── api_manager.dart      # Dio网络请求管理器
│   └── api_examples.dart     # 使用示例
├── models/
│   ├── api_response.dart     # 统一响应数据模型
│   └── api_exception.dart    # 自定义异常处理
└── services/
    └── video_upload_service.dart  # 视频上传服务（已更新使用Dio）
```

## 快速开始

### 1. 初始化API管理器

```dart
import 'package:your_app/api/api_manager.dart';

void main() {
  // 在应用启动时初始化
  ApiManager().init();
  runApp(MyApp());
}
```

### 2. 基础HTTP请求

#### GET请求
```dart
import 'package:your_app/api/api_manager.dart';
import 'package:your_app/models/api_response.dart';

final apiManager = ApiManager();

// 简单GET请求
final response = await apiManager.get<Map<String, dynamic>>('/user/profile');

if (response.success) {
  print('用户信息：${response.data}');
} else {
  print('请求失败：${response.message}');
}

// 带查询参数的GET请求
final response = await apiManager.get<Map<String, dynamic>>(
  '/users',
  queryParameters: {
    'page': 1,
    'limit': 10,
    'search': '张三',
  },
);
```

#### POST请求
```dart
// 创建数据
final response = await apiManager.post<Map<String, dynamic>>(
  '/user/create',
  data: {
    'name': '张三',
    'email': 'zhangsan@example.com',
    'age': 25,
  },
);

if (response.success) {
  print('用户创建成功：${response.data}');
}
```

#### PUT请求
```dart
// 更新数据
final response = await apiManager.put<Map<String, dynamic>>(
  '/user/update',
  data: {
    'userId': '123',
    'name': '李四',
    'email': 'lisi@example.com',
  },
);
```

#### DELETE请求
```dart
// 删除数据
final response = await apiManager.delete<bool>(
  '/user/delete',
  data: {
    'userId': '123',
  },
);
```

### 3. 文件上传

#### 单文件上传
```dart
import 'dart:io';

final file = File('/path/to/your/file.jpg');

final response = await apiManager.uploadFile<Map<String, dynamic>>(
  '/upload/image',
  file,
  fieldName: 'image',  // 表单字段名
  data: {
    'description': '用户头像',
    'category': 'avatar',
  },
  onSendProgress: (sent, total) {
    print('上传进度：${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

#### 多文件上传
```dart
final files = [
  File('/path/to/file1.jpg'),
  File('/path/to/file2.jpg'),
  File('/path/to/file3.jpg'),
];

final response = await apiManager.uploadMultipleFiles<Map<String, dynamic>>(
  '/upload/multiple',
  files,
  fieldName: 'images',
  data: {
    'albumName': '我的相册',
  },
  onSendProgress: (sent, total) {
    print('上传进度：${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

### 4. 文件下载
```dart
final response = await apiManager.downloadFile(
  '/download/file/123',
  '/path/to/save/file.pdf',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      print('下载进度：${(received / total * 100).toStringAsFixed(1)}%');
    }
  },
);
```

### 5. 错误处理

```dart
try {
  final response = await apiManager.get<Map<String, dynamic>>('/api/data');
  
  if (response.success) {
    print('请求成功：${response.data}');
  } else {
    print('请求失败：${response.message}');
  }
} on ApiException catch (e) {
  // 根据异常类型进行不同处理
  switch (e.type) {
    case ApiExceptionType.timeout:
      print('网络超时，请检查网络连接');
      break;
    case ApiExceptionType.connectionError:
      print('网络连接失败，请检查网络设置');
      break;
    case ApiExceptionType.badResponse:
      if (e.isAuthError) {
        print('认证失败，请重新登录');
        // 跳转到登录页面
      } else if (e.isNotFoundError) {
        print('请求的资源不存在');
      } else if (e.isServerError) {
        print('服务器错误，请稍后重试');
      }
      break;
    case ApiExceptionType.cancel:
      print('请求已取消');
      break;
    default:
      print('未知错误：${e.message}');
      break;
  }
}
```

### 6. 高级功能

#### 请求取消
```dart
import 'package:dio/dio.dart';

final cancelToken = CancelToken();

// 5秒后取消请求
Timer(Duration(seconds: 5), () {
  cancelToken.cancel('请求超时');
});

final response = await apiManager.get<Map<String, dynamic>>(
  '/long-running-task',
  cancelToken: cancelToken,
);
```

#### 自定义请求头
```dart
// 添加自定义请求头
apiManager.addHeader('X-Custom-Header', 'custom-value');
apiManager.addHeader('X-API-Version', 'v1.0');

// 发送请求
final response = await apiManager.get<Map<String, dynamic>>('/api/data');

// 清理请求头
apiManager.removeHeader('X-Custom-Header');
apiManager.removeHeader('X-API-Version');
```

#### 更新基础URL
```dart
// 切换到测试环境
apiManager.updateBaseUrl('https://test-api.example.com');

// 切换到生产环境
apiManager.updateBaseUrl('https://api.example.com');
```

#### 批量请求
```dart
// 并行执行多个请求
final futures = [
  apiManager.get<Map<String, dynamic>>('/user/profile'),
  apiManager.get<List<Map<String, dynamic>>>('/user/posts'),
  apiManager.get<Map<String, dynamic>>('/user/settings'),
];

final results = await Future.wait(futures);

for (int i = 0; i < results.length; i++) {
  final response = results[i];
  if (response.success) {
    print('请求${i + 1}成功：${response.data}');
  } else {
    print('请求${i + 1}失败：${response.message}');
  }
}
```

## 配置说明

### 基础配置
- **连接超时**：30秒
- **接收超时**：30秒
- **发送超时**：30秒
- **基础URL**：可在`api_manager.dart`中修改
- **默认请求头**：`Content-Type: application/json`, `Accept: application/json`

### 拦截器功能
- **请求拦截器**：自动添加认证token、打印请求日志
- **响应拦截器**：打印响应日志
- **错误拦截器**：打印错误日志
- **日志拦截器**：仅在调试模式下启用

### 错误类型
- `timeout`：网络超时
- `connectionError`：网络连接错误
- `badResponse`：响应错误（4xx、5xx状态码）
- `cancel`：请求取消
- `badCertificate`：证书错误
- `unknown`：未知错误

## 视频上传服务

视频上传服务已更新使用Dio封装，提供了以下功能：

```dart
import 'package:your_app/services/video_upload_service.dart';

// 上传视频
final response = await VideoUploadService.uploadVideo(
  videoFile: videoFile,
  fileName: 'training_video.mp4',
  onProgress: (progress) {
    print('上传进度：${(progress * 100).toStringAsFixed(1)}%');
  },
);

if (response.success) {
  print('视频上传成功：${response.data}');
} else {
  print('上传失败：${response.message}');
}

// 获取上传历史
final historyResponse = await VideoUploadService.getUploadHistory();

// 删除视频
final deleteResponse = await VideoUploadService.deleteVideo('video_id');

// 获取上传状态
final statusResponse = await VideoUploadService.getUploadStatus('video_id');
```

## 最佳实践

1. **统一错误处理**：使用`ApiException`进行统一的错误处理
2. **类型安全**：为响应数据指定正确的泛型类型
3. **进度监听**：对于文件上传下载，使用进度回调提供用户体验
4. **请求取消**：对于长时间运行的请求，提供取消功能
5. **重试机制**：对于网络错误，实现适当的重试逻辑
6. **日志记录**：在调试模式下启用详细日志，生产环境关闭
7. **认证管理**：在请求拦截器中统一处理认证token

## 注意事项

1. 确保在应用启动时调用`ApiManager().init()`进行初始化
2. 根据实际API接口调整基础URL和请求路径
3. 根据业务需求调整超时时间和重试策略
4. 在生产环境中关闭详细日志以提高性能
5. 合理使用请求取消功能避免资源浪费
