import 'package:flutter/material.dart';
import '../model/urine_record.dart';
import '../service/db_service.dart';

class UrineDataProvider extends ChangeNotifier {
  final DbService _dbService = DbService();

  List<UrineRecord> _records = [];
  List<UrineRecord> get records => _records;

  //ข้อมูลล่าสุด ใช้แสดงค่าปัจจุบันที่หน้าจอ
  UrineRecord? get lateRecord => _records.isNotEmpty ? _records.first : null;
  //โหลดข้อมูลย้อนหลังทั้งหมดของผู้ป่วย
  Future<void> loadRecordsForPatient(String patientId) async {
    _records = await _dbService.getRecordsByPatient(patientId);
    notifyListeners();
  }
  Future<void> loadRecordsByDateRange(
      String patientId,
      DateTime start,
      DateTime end,
      ) async {
    _records = await _dbService.getRecordsByDateRange(patientId, start, end);
    notifyListeners();
  }
  //เรียกจาก ble_service ทุกครั้งที่มีข้อมูลใหม่เข้ามาจาก ESP32
  Future<void> addNewRecord(UrineRecord record) async{
    await _dbService.insertUrineRecord(record);
    _records.insert(0, record);
    notifyListeners();
  }
  void clear() {
    _records = [];
    notifyListeners();
  }
}