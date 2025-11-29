# 基于API配置的接口调用使用说明

## 📋 概述

本项目已经完成了基于`api_config.dart`配置的API接口调用系统，提供了统一的环境管理、API服务管理和配置管理功能。

## 🏗️ 项目结构

```
lib/
├── api/
│   ├── api_config.dart              # API配置（环境、超时、URL等）
│   ├── api_manager.dart             # API管理器（统一管理所有API服务）
│   ├── api_service.dart             # API服务基类
│   ├── http_client.dart             # HTTP客户端配置
│   ├── api_response.dart            # API响应模型
│   ├── api_usage_example.dart       # 使用示例
│   ├── api.dart                     # API模块导出
│   └── service/                     # API服务实现
│       ├── user_api_service.dart    # 用户API服务
│       └── demo_api_service.dart    # Demo API服务
├── views/
│   ├── simple_api_demo.dart         # 简单API调用Demo
│   ├── api_demo_page.dart           # 完整API Demo页面
│   └── environment_demo.dart        # 环境切换Demo
└── main.dart                        # 应用入口
```

## ⚙️ 配置说明

### API配置 (api_config.dart)

```dart
class ApiConfig {
  // 环境配置
  static const String devBaseUrl = 'http://localhost:3000';
  static const String testBaseUrl = 'http://localhost:3000';
  static const String prodBaseUrl = 'https://api.example.com';
  
  // 当前环境
  static const Environment currentEnvironment = Environment.dev;
  
  // 超时配置
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
  
  // 调试配置
  static const bool enableDebugLog = true;
  
  // 默认请求头
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

## 🚀 使用方法

### 1. 基本使用

```dart
import 'package:apps/api/api.dart';

// 初始化API管理器
final apiManager = ApiManager();
apiManager.initialize();

// 使用用户API服务
final userResponse = await apiManager.userApi.getUserInfo(1);

// 使用Demo API服务
final articlesResponse = await apiManager.demoApi.getArticles();
```

### 2. 环境切换

```dart
// 切换到测试环境
apiManager.switchEnvironment(Environment.test);

// 切换到生产环境
apiManager.switchEnvironment(Environment.prod);

// 切换回开发环境
apiManager.switchEnvironment(Environment.dev);
```

### 3. 认证管理

```dart
// 设置认证token
apiManager.setAuthToken('your_token_here');

// 清除认证token
apiManager.clearAuthToken();
```

### 4. 自定义Header

```dart
// 设置自定义header
apiManager.setHeader('X-App-Version', '1.0.0');
apiManager.setHeader('X-Platform', 'Flutter');

// 移除自定义header
apiManager.removeHeader('X-Platform');
```

## 📱 Demo页面

### 1. 环境切换Demo (EnvironmentDemo)
- 显示当前环境信息
- 支持切换开发/测试/生产环境
- 测试当前环境的API调用
- 显示环境配置信息

### 2. 简单API Demo (SimpleApiDemo)
- 基本的GET、POST、PUT、DELETE请求
- 使用api_config配置的API地址
- 实时显示API调用结果
- 支持用户API和Demo API服务

### 3. 完整API Demo (ApiDemoPage)
- 所有API功能的完整演示
- 文件上传和下载
- 请求取消功能
- 实时日志显示

## 🔧 API服务使用示例

### 用户API服务

```dart
// 用户登录
final loginRequest = LoginRequest(
  email: 'user@example.com',
  password: 'password123',
);
final loginResponse = await apiManager.userApi.login(loginRequest);

// 获取用户信息
final userInfo = await apiManager.userApi.getUserInfo(1);

// 更新用户信息
final updateData = {'name': 'New Name'};
final updateResponse = await apiManager.userApi.updateUser(1, updateData);

// 获取用户列表
final userList = await apiManager.userApi.getUserList(
  page: 1,
  size: 20,
  keyword: 'search',
);

// 上传用户头像
final avatarFile = File('path/to/avatar.jpg');
final avatarResponse = await apiManager.userApi.uploadAvatar(1, avatarFile);
```

### Demo API服务

```dart
// 获取文章列表
final articles = await apiManager.demoApi.getArticles(page: 1, size: 10);

// 获取单个文章
final article = await apiManager.demoApi.getArticle(1);

// 创建文章
final createRequest = CreateArticleRequest(
  title: 'New Article',
  content: 'Article content',
  author: 'Author Name',
  tags: ['tag1', 'tag2'],
);
final createResponse = await apiManager.demoApi.createArticle(createRequest);

// 更新文章
final updateRequest = UpdateArticleRequest(
  title: 'Updated Title',
  content: 'Updated content',
);
final updateResponse = await apiManager.demoApi.updateArticle(1, updateRequest);

// 搜索文章
final searchRequest = SearchArticleRequest(
  keyword: 'Flutter',
  page: 1,
  size: 10,
);
final searchResponse = await apiManager.demoApi.searchArticles(searchRequest);

// 获取统计数据
final stats = await apiManager.demoApi.getStatistics();
```

## 🌍 环境管理

### 环境切换

```dart
// 获取当前环境信息
final envInfo = apiManager.getEnvironmentInfo();
print('当前环境: ${envInfo['currentEnvironment']}');
print('API地址: ${envInfo['baseUrl']}');

// 切换环境
apiManager.switchEnvironment(Environment.test);
```

### 环境配置

在`api_config.dart`中修改环境配置：

```dart
// 修改当前环境
static const Environment currentEnvironment = Environment.prod;

// 修改API地址
static const String prodBaseUrl = 'https://your-api.com';
```

## 🔍 错误处理

所有API调用都返回`ApiResponse<T>`对象，包含：

```dart
class ApiResponse<T> {
  final int code;           // 状态码
  final String message;     // 响应消息
  final T? data;           // 响应数据
  bool get isSuccess;      // 是否成功
}

// 使用示例
final response = await apiManager.userApi.getUserInfo(1);
if (response.isSuccess) {
  print('成功: ${response.data?.name}');
} else {
  print('失败: ${response.message}');
}
```

## 📊 调试和日志

### 启用调试日志

在`api_config.dart`中：

```dart
static const bool enableDebugLog = true;
```

### 查看环境信息

```dart
final envInfo = apiManager.getEnvironmentInfo();
print('环境信息: $envInfo');
```

## 🚀 运行Demo

1. 启动应用：
   ```bash
   flutter run
   ```

2. 访问不同的Demo页面：
   - 环境切换Demo：`/environment-demo`
   - 简单API Demo：`/simple-api-demo`
   - 完整API Demo：`/api-demo`

3. 测试API调用：
   - 点击按钮测试各种API调用
   - 查看实时响应结果
   - 切换环境测试不同配置

## 📝 注意事项

1. **环境配置**：确保`api_config.dart`中的API地址正确
2. **网络权限**：确保应用有网络访问权限
3. **错误处理**：始终检查API响应的`isSuccess`状态
4. **超时设置**：根据网络情况调整超时时间
5. **认证管理**：及时设置和清除认证token

## 🔄 扩展功能

### 添加新的API服务

1. 在`service/`目录下创建新的API服务文件
2. 继承`ApiService`基类
3. 在`ApiManager`中添加服务实例
4. 导出到`api.dart`文件中

### 自定义配置

在`api_config.dart`中添加新的配置项：

```dart
// 添加新的配置
static const String customHeader = 'Custom-Value';
static const int customTimeout = 60;
```

这个系统提供了完整的API调用解决方案，支持环境管理、统一配置和错误处理，可以满足各种API调用需求。
