import 'package:flutter/material.dart';
import 'views/signup_page.dart';
import 'views/gender_selection.dart';
import 'views/my_training_page.dart';
import 'views/file_upload_page.dart';
import 'api/api_manager.dart';

void main() {
  // 初始化API管理器
  ApiManager().init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'SF Pro Display', // iOS-like font
      ),
      home: const SignUpPage(), // 设置为测试页面作为首页
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/gender': (context) => const GenderSelectionPage(),
        '/training': (context) => const MyTrainingPage(),
        '/upload': (context) => const FileUploadPage(),
      },
    );
  }
}
