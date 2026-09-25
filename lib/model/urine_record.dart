import 'dart:convert';

class UrineRecord {
  final int? id;
  final String patientId;
  final DateTime timestamp;
  final double volumeMl;
  final int colorCode;

  UrineRecord({
    this.id,
    required this.patientId,
    required this.timestamp,
    required this.volumeMl,
    required this.colorCode,
  });

  // แปลงจาก Map (ฐานข้อมูล / SQLite) เป็น Object
  factory UrineRecord.fromMap(Map<String, dynamic> map) {
    return UrineRecord(
      id: map['id'] as int?,
      patientId: map['patientId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      volumeMl: (map['volumeMl'] as num).toDouble(), // แก้ไขจากเครื่องหมาย ; เป็น :
      colorCode: map['colorCode'] as int,
    );
  }

  // แปลงจาก Object กลับเป็น Map เพื่อเตรียมบันทึกลงฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'volumeMl': volumeMl,
      'colorCode': colorCode,
    };
  }

  // สำหรับแปลงข้อมูล JSON ที่ส่งมาจาก ESP32 ผ่าน BLE โดยตรง
  factory UrineRecord.fromBleJson(Map<String, dynamic> json, String patientId) {
    return UrineRecord(
      patientId: patientId,
      timestamp: DateTime.now(), // บันทึกเวลาปัจจุบันที่ได้รับข้อมูล
      volumeMl: (json['vol'] as num).toDouble(),
      colorCode: json['color'] as int,
    );
  }
}