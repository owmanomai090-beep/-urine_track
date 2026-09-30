import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/patient.dart';
import '../provider/urine_data_provider.dart';
import '../utils/constant.dart';
import '../utils/urine_color_map.dart';
import '../widgets/urine_chart.dart';

class HistoryScreen extends StatefulWidget {
  final Patient patient;
  const HistoryScreen({super.key, required this.patient});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDay(_selectedDate));
  }

  void _loadDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day, 0, 0, 0);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    context.read<UrineDataProvider>().loadRecordsByDateRange(
      widget.patient.id,
      start,
      end,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadDay(picked);
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    final urineProvider = context.watch<UrineDataProvider>();
    // ข้อมูลช่วงเวลาถูกโหลดมาเรียง ASC (เก่า -> ใหม่) จาก db_service
    final records = urineProvider.records;

    // รวมเป็นชั่วโมงละ 1 ค่า (ค่าล่าสุดของชั่วโมงนั้น) กันนับซ้ำ
    final hourly = latestPerHour(records);
    final totalVolume =
    hourly.values.fold<double>(0, (sum, r) => sum + r.volumeMl);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'ประวัติ - เตียง ${widget.patient.bedId.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // เลือกวันที่
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today,
                      color: AppConstants.primaryColor),
                  title: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 16),

              // สรุปยอดของวันนั้น (นับรายชั่วโมง)
              Row(
                children: [
                  Expanded(
                    child: _SummaryBox(
                      label: 'ปริมาตรรวม',
                      value: '${totalVolume.toStringAsFixed(0)} มล.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryBox(
                      label: 'ชั่วโมงที่มีข้อมูล',
                      value: '${hourly.length} ชม.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: records.isEmpty
                    ? const Center(child: Text('ไม่มีข้อมูลในวันที่เลือก'))
                    : ListView(
                  children: [
                    UrineHourlyChart(
                      records: records,
                      latestLabel: 'ชั่วโมงสุดท้าย',
                    ),
                    const SizedBox(height: 24),
                    const Text('รายละเอียดทั้งหมด',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...records.reversed.map(
                          (r) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: UrineColorMap.getColor(r.colorCode),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.shade400),
                            ),
                          ),
                          title: Text(
                            '${r.timestamp.hour.toString().padLeft(2, '0')}:${r.timestamp.minute.toString().padLeft(2, '0')} น.',
                          ),
                          subtitle:
                          Text(UrineColorMap.getLabel(r.colorCode)),
                          trailing: Text(
                            '${r.volumeMl.toStringAsFixed(0)} มล.',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}