import 'dart:convert';
import 'package:flutter/services.dart';

class CvDataProvider {
  static Map<String, dynamic>? _cachedData;

  static Future<Map<String, dynamic>> loadCvData() async {
    if (_cachedData != null) return _cachedData!;
    final jsonString = await rootBundle.loadString('assets/data/cv_data.json');
    _cachedData = json.decode(jsonString) as Map<String, dynamic>;
    return _cachedData!;
  }

  static Map<String, dynamic> get personalInfo =>
      (_cachedData?['personal_info'] as Map<String, dynamic>?) ?? {};

  static List<dynamic> get experience =>
      (_cachedData?['experience'] as List<dynamic>?) ?? [];

  static List<dynamic> get projects =>
      (_cachedData?['projects'] as List<dynamic>?) ?? [];

  static Map<String, dynamic> get skills =>
      (_cachedData?['skills'] as Map<String, dynamic>?) ?? {};
}
