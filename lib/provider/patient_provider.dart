import 'package:flutter/material.dart';
import '../model/patient.dart';
import '../service/db_service.dart';

class PatientProvider extends ChangeNotifier {
  final DbService _dbService = DbService();

  List<Patient> _patients = [];
  Patient? _selectedPatient;

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;

  // โหลดข้อมูลผู้ป่วยจาก DB (เรียกตอนเปิดแอปหรือเข้าหน้า Menu)
  Future<void> loadPatients() async {
    _patients = await _dbService.getAllPatients();
    notifyListeners();
  }

  // หาผู้ป่วยจาก bedId
  Patient? getPatientByBedId(String bedId) {
    try {
      return _patients.firstWhere((p) => p.bedId == bedId);
    } catch (e) {
      return null;
    }
  }

  // เลือกผู้ป่วยตอนกดดูรายละเอียด
  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    await _dbService.insertPatient(patient);
    await loadPatients();
  }

  Future<void> removePatient(String id) async {
    await _dbService.deletePatient(id);
    await loadPatients();
  }
}