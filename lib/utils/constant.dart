import 'package:flutter/material.dart';

class AppConstants{
  static const String appName =  'Urine Track';

  // ---------- BLE ----------
  // UUID ต้องตรงกับที่ตั้งค่าไว้ในโค้ด ESP32S3 (ฝั่ง firmware)
  // นี่คือค่าตัวอย่าง ให้แก้ตามที่ ESP32 จริงประกาศไว้
  static const String bleServiceUuid = '9813eeb1-cbe3-4d79-a952-4b505f9c05d6';
  static const String bleCharacteristicUuid =
      '607773fd-6aa5-49af-90a7-e84fe7b46e8e';

  // ชื่ออุปกรณ์ ESP32 ที่จะสแกนหา (ตั้งชื่อใน firmware ให้ตรงกัน)
  static const String bleDeviceNamePrefix = 'ESP32_URINE';

  // ---------- Database ----------
  static const String dbName = 'urine_track.db';
  static const int dbVersion = 1;

  static const String tablePatients = 'patients';
  static const String tableUrineRecords = 'urine_records';

  // ---------- UI ----------
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;

  static const Color primaryColor = Color(0xFF2E7D9A);
  static const Color bedCardColor = Color(0xFFEAF4F8);
}