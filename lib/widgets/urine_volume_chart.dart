import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/urine_record.dart';

class UrineVolumeChart extends StatelessWidget {
  final List<UrineRecord> records; // ควรเรียงจาก เก่า -> ใหม่ ก่อนส่งเข้ามา

  const UrineVolumeChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('ยังไม่มีข้อมูล')),
      );
    }

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < records.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: records[i].volumeMl,
              color: Colors.lightBlue,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 36),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= records.length) {
                    return const SizedBox.shrink();
                  }
                  final ts = records[index].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${ts.hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)} มล.',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}