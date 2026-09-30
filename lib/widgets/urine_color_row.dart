import 'package:flutter/material.dart';
import '../model/urine_record.dart';
import '../utils/urine_color_map.dart';

class UrineColorRow extends StatelessWidget {
  final List<UrineRecord> records; // เรียงจาก เก่า -> ใหม่

  const UrineColorRow({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox(
        height: 70,
        child: Center(child: Text('ยังไม่มีข้อมูล')),
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: records.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final record = records[index];
          final color = UrineColorMap.getColor(record.colorCode);
          final isWarning = UrineColorMap.isWarning(record.colorCode);

          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWarning ? Colors.red : Colors.grey.shade400,
                    width: isWarning ? 2 : 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.timestamp.hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}