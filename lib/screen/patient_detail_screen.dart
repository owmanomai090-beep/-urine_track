import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/patient.dart';
import '../provider/urine_data_provider.dart';
import '../utils/constant.dart';
import '../utils/urine_color_map.dart';
import '../widgets/patient_info_card.dart';
import '../widgets/urine_volume_chart.dart';
import '../widgets/urine_color_row.dart';
import 'history_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UrineDataProvider>().loadRecordsForPatient(widget.patient.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final urineProvider = context.watch<UrineDataProvider>();

    // provider เก็บล่าสุด -> เก่าสุด (DESC) ต้อง reverse ก่อนวาดกราฟ (เก่า -> ใหม่)
    final chronological = urineProvider.records.reversed.toList();
    final latest = urineProvider.lateRecord;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          'เตียง ${widget.patient.bedId.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'ดูข้อมูลย้อนหลัง',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(patient: widget.patient),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => urineProvider.loadRecordsForPatient(widget.patient.id),
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              PatientInfoCard(patient: widget.patient),
              const SizedBox(height: 16),

              // สถานะล่าสุด
              if (latest != null)
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
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: UrineColorMap.getColor(latest.colorCode),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade400),
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
              const SizedBox(height: 20),

              const Text('ปริมาตรปัสสาวะรายชั่วโมง',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              UrineVolumeChart(records: chronological),

              const SizedBox(height: 24),
              const Text('สีปัสสาวะรายชั่วโมง',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              UrineColorRow(records: chronological),
            ],
          ),
        ),
      ),
    );
  }
}