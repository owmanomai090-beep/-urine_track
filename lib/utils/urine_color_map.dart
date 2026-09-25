import 'package:flutter/material.dart';

class UrineColorMap {
  // Urine Color Chart มาตรฐาน 1 (ใสมาก) ถึง 8 (เข้มมาก/ผิดปกติ)
  static const Map<int, Color> _colorMap = {
    1: Color(0xFFFFFDE7), // ใสเกือบไม่มีสี
    2: Color(0xFFFFF9C4),
    3: Color(0xFFFFF59D),
    4: Color(0xFFFFEE58),
    5: Color(0xFFFFCA28),
    6: Color(0xFFFFA726),
    7: Color(0xFFEF6C00),
    8: Color(0xFFBF360C), // เข้มมาก ควรเฝ้าระวัง
  };

  static const Map<int, String> _labelMap = {
    1: 'ใสมาก',
    2: 'ใส',
    3: 'เหลืองอ่อน',
    4: 'เหลือง',
    5: 'เหลืองเข้ม',
    6: 'ส้มอ่อน',
    7: 'ส้มเข้ม',
    8: 'น้ำตาล/เข้มมาก',
  };

  static Color getColor(int code) {
    return _colorMap[code] ?? Colors.grey.shade300;
  }

  static String getLabel(int code) {
    return _labelMap[code] ?? 'ไม่ทราบ';
  }

  // true ถ้าสีเข้มถึงระดับที่ควรแจ้งเตือน (ปรับเกณฑ์ได้ตามคำแนะนำแพทย์)
  static bool isWarning(int code) {
    return code >= 6;
  }
}