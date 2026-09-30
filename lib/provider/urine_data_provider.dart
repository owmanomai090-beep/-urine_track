import 'package:flutter/material.dart';
import '../model/patient.dart';
import '../model/urine_record.dart';
import '../service/db_service.dart';
import '../utils/aki_assessment.dart';

class UrineDataProvider extends ChangeNotifier {
  final DbService _dbService = DbService();

  List<UrineRecord> _records = [];
  List<UrineRecord> get records => _records;

  // ผลประเมิน AKI ของผู้ป่วยแต่ละคน (key = patient.id) ใช้แสดงป้ายบนการ์ดเตียง
  final Map<String, AkiResult> _akiResults = {};
  AkiResult? akiFor(String patientId) => _akiResults[patientId];

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
  Future<void> addNewRecord(UrineRecord record) async {
    await _dbService.insertUrineRecord(record);
    _records.insert(0, record);
    notifyListeners();
  }

  /// คำนวณ AKI ของผู้ป่วยทุกคนที่ส่งเข้ามา (ไม่แตะ _records ของหน้ารายละเอียด)
  Future<void> loadAkiForPatients(List<Patient> patients) async {
    for (final p in patients) {
      final recs = await _dbService.getRecordsByPatient(p.id);
      _akiResults[p.id] = AkiAssessment.assess(recs, p.weight);
    }
    notifyListeners();
  }

  void clear() {
    _records = [];
    notifyListeners();
  }
}