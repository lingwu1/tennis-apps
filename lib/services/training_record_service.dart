import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_record.dart';

class TrainingRecordService {
  static const String _key = 'training_records';

  /// 保存训练记录
  static Future<void> saveRecord(TrainingRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = await getAllRecords();
      records.insert(0, record); // 新记录添加到最前面
      
      final recordsJson = records.map((r) => r.toJson()).toList();
      await prefs.setString(_key, jsonEncode(recordsJson));
    } catch (e) {
      throw Exception('保存训练记录失败: $e');
    }
  }

  /// 获取所有训练记录
  static Future<List<TrainingRecord>> getAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_key);
      
      if (recordsJson == null) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(recordsJson);
      return decoded.map((json) => TrainingRecord.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 删除训练记录
  static Future<void> deleteRecord(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = await getAllRecords();
      records.removeWhere((record) => record.id == id);
      
      final recordsJson = records.map((r) => r.toJson()).toList();
      await prefs.setString(_key, jsonEncode(recordsJson));
    } catch (e) {
      throw Exception('删除训练记录失败: $e');
    }
  }

  /// 清空所有记录
  static Future<void> clearAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      throw Exception('清空训练记录失败: $e');
    }
  }
}

