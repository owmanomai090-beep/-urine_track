import 'package:flutter/material.dart';

class AppConstants{
  static const String appName =  'Urine Track';

  // ---------- BLE ----------
  // UUID ต้องตรงกับที่ตั้งค่าไว้ในโค้ด ESP32S3 (ฝั่ง firmware)
  // นี่คือค่าตัวอย่าง ให้แก้ตามที่ ESP32 จริงประกาศไว้
  static const String bleServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String bleCharacteristicUuid =
      'beb5483e-36e1-4688-b7f5-ea07361b26a8';

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