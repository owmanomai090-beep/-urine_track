import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/patient.dart';
import '../model/urine_record.dart';
import '../provider/urine_data_provider.dart';
import '../service/ble_service.dart';
import '../utils/constant.dart';
import '../utils/urine_color_map.dart';
import '../widgets/aki_card.dart';
import '../widgets/patient_info_card.dart';
import '../widgets/urine_chart.dart';
import 'history_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  /// true = ช่วงทดสอบ: ใช้ "ชั่วโมง" ที่ ESP32 จำลองส่งมาเป็นเวลาของ record
  /// false = ใช้งานจริง: ใช้เวลาปัจจุบันตอนรับข้อมูล
  static const bool _useDeviceHour = true;

  StreamSubscription<UrineReading>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UrineDataProvider>();
      provider.loadRecordsForPatient(widget.patient.id);

      // รับข้อมูลสดจาก ESP32 แล้วบันทึกเป็น record ของผู้ป่วยคนนี้
      _sub = BleService.instance.readings.listen((r) async {
        if (!mounted) return;
        final now = DateTime.now();
        final ts = _useDeviceHour
            ? DateTime(now.year, now.month, now.day, r.hour, now.minute,
            now.second)
            : now;
        try {
          await provider.addNewRecord(UrineRecord(
            patientId: widget.patient.id,
            timestamp: ts,
            volumeMl: r.volume.toDouble(),
            colorCode: UrineColorMap.fromRgb(r.r, r.g, r.b),
          ));
          debugPrint('saved hour ${r.hour}');
        } catch (e) {
          debugPrint('save error: $e');
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urineProvider = context.watch<UrineDataProvider>();
    final latest = urineProvider.lateRecord;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'เตียง ${widget.patient.bedId.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'ดูข้อมูลย้อนหลัง',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(patient: widget.patient),
                ),
              );
              if (!mounted) return;
              context
                  .read<UrineDataProvider>()
                  .loadRecordsForPatient(widget.patient.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              urineProvider.loadRecordsForPatient(widget.patient.id),
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              PatientInfoCard(patient: widget.patient),
              const SizedBox(height: 16),

              // สถานะ AKI (U0-U3) อัปเดตสดตามข้อมูลที่เข้ามา
              AkiCard(
                records: urineProvider.records,
                weightKg: widget.patient.weight,
              ),
              const SizedBox(height: 16),

              // สถานะล่าสุด
              if (latest != null) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppConstants.cardBorderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ปริมาตรล่าสุด',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text(
                              '${latest.volumeMl.toStringAsFixed(0)} มล.',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('สีปัสสาวะ',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: UrineColorMap.getColor(
                                        latest.colorCode),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey.shade400),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(UrineColorMap.getLabel(latest.colorCode)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // กราฟเส้น 24 ชั่วโมง ปริมาตร + สี
              const UrineChart(),
            ],
          ),
        ),
      ),
    );
  }
}