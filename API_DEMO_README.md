# Flutter Dio API封装使用Demo

这个项目展示了如何使用基于Dio的API封装进行各种类型的HTTP请求。

## 项目结构

```
lib/
├── api/
│   ├── api_service.dart          # API服务基类
│   ├── http_client.dart          # HTTP客户端配置
│   ├── api_config.dart           # API配置
│   ├── api_response.dart         # API响应模型
│   ├── user_api_service.dart     # 用户API服务示例
│   └── demo_api_service.dart     # Demo API服务
├── views/
│   ├── api_demo_page.dart        # 完整API Demo页面
│   └── simple_api_demo.dart      # 简单API Demo页面
└── main.dart                     # 应用入口
```

## 核心特性

### 1. 统一的API服务基类 (ApiService)
- 支持GET、POST、PUT、DELETE请求
- 支持文件上传和下载
- 统一的错误处理
- 支持取消令牌
- 支持自定义Header

### 2. HTTP客户端配置 (HttpClient)
- 单例模式
- 请求/响应拦截器
- 超时配置
- 调试日志
- 统一错误处理

### 3. 响应模型 (ApiResponse)
- 泛型支持
- 标准化的响应格式
- 分页支持
- 列表响应支持

## 使用方法

### 1. 基本使用

```dart
// 创建API服务实例
final apiService = ApiService();

// 设置基础URL
apiService.setBaseUrl('https://api.example.com');

// 设置认证token
apiService.setAuthToken('your_token_here');

// GET请求
final response = await apiService.get<Map<String, dynamic>>(
  '/users/1',
  fromJson: (json) => json as Map<String, dynamic>,
);

// POST请求
final response = await apiService.post<Map<String, dynamic>>(
  '/users',
  data: {'name': 'John', 'email': 'john@example.com'},
  fromJson: (json) => json as Map<String, dynamic>,
);
```

### 2. 业务API服务

```dart
class UserApiService extends ApiService {
  static const String _basePath = '/api/users';

  Future<ApiResponse<User>> getUser(int userId) async {
    return get<User>(
      '$_basePath/$userId',
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<User>> createUser(CreateUserRequest request) async {
    return post<User>(
      '$_basePath',
      data: request.toJson(),
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }
}
```

### 3. 文件上传

```dart
// 单文件上传
final response = await apiService.uploadFile<String>(
  '/upload',
  file,
  fieldName: 'file',
  fromJson: (json) => json as String,
);

// 多文件上传
final response = await apiService.uploadFiles<List<String>>(
  '/upload/multiple',
  files,
  fieldName: 'files',
  fromJson: (json) => List<String>.from(json as List),
);
```

### 4. 文件下载

```dart
await apiService.downloadFile(
  'https://example.com/file.pdf',
  '/path/to/save/file.pdf',
  onReceiveProgress: (received, total) {
    print('下载进度: ${(received / total * 100).toStringAsFixed(0)}%');
  },
);
```

### 5. 带取消令牌的请求

```dart
final cancelToken = CancelToken();

// 发送请求
final response = await apiService.get<Map<String, dynamic>>(
  '/data',
  cancelToken: cancelToken,
  fromJson: (json) => json as Map<String, dynamic>,
);

// 取消请求
cancelToken.cancel('用户取消请求');
```

## Demo页面

### 简单Demo (SimpleApiDemo)
- 基本的GET、POST、PUT、DELETE请求
- 带查询参数的请求
- 带自定义Header的请求
- 使用业务API服务的示例

### 完整Demo (ApiDemoPage)
- 所有API功能的完整演示
- 文件上传和下载
- 多文件上传
- 请求取消
- 实时日志显示

## 运行Demo

1. 确保已安装Flutter SDK
2. 在项目根目录运行：
   ```bash
   flutter pub get
   flutter run
   ```

3. 应用启动后会显示API Demo页面，点击按钮即可测试各种API调用

## 配置说明

### API配置 (api_config.dart)
```dart
class ApiConfig {
  // 环境配置
  static const String devBaseUrl = 'https://dev-api.example.com';
  static const String testBaseUrl = 'https://test-api.example.com';
  static const String prodBaseUrl = 'https://api.example.com';
  
  // 当前环境
  static const Environment currentEnvironment = Environment.dev;
  
  // 超时配置
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
}
```

### HTTP客户端配置
```dart
// 在HttpClient中配置
_dio.options = BaseOptions(
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
  sendTimeout: const Duration(seconds: 30),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
);
```

## 错误处理

API封装提供了统一的错误处理：

- 网络超时错误
- HTTP状态码错误
- 连接错误
- 请求取消错误

所有错误都会被转换为用户友好的错误消息。

## 扩展功能

### 添加新的API服务
1. 继承`ApiService`类
2. 定义API路径常量
3. 实现具体的API方法
4. 定义相应的数据模型

### 自定义拦截器
在`HttpClient`中添加自定义拦截器：

```dart
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      // 请求前处理
      handler.next(options);
    },
    onResponse: (response, handler) {
      // 响应后处理
      handler.next(response);
    },
    onError: (error, handler) {
      // 错误处理
      handler.next(error);
    },
  ),
);
```

## 注意事项

1. 确保网络权限配置正确
2. 处理网络异常情况
3. 合理设置超时时间
4. 注意内存泄漏，及时取消不需要的请求
5. 在生产环境中关闭调试日志

## 依赖包

```yaml
dependencies:
  dio: ^5.3.2
  json_annotation: ^4.8.1

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

这个API封装提供了完整的HTTP请求解决方案，支持各种常见的API调用场景，并且具有良好的扩展性和可维护性。
