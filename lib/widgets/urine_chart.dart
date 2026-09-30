import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/urine_record.dart';
import '../provider/urine_data_provider.dart';
import '../utils/urine_color_map.dart';

/// เลือก record ล่าสุดของแต่ละชั่วโมง (ไม่สนลำดับของ list)
/// ใช้ร่วมกันทั้งกราฟและยอดสรุป เพื่อไม่ให้นับ record ซ้ำในชั่วโมงเดียวกัน
Map<int, UrineRecord> latestPerHour(Iterable<UrineRecord> records) {
  final Map<int, UrineRecord> byHour = {};
  for (final r in records) {
    final h = r.timestamp.hour;
    final cur = byHour[h];
    if (cur == null || r.timestamp.isAfter(cur.timestamp)) {
      byHour[h] = r;
    }
  }
  return byHour;
}

/// หน้ารายละเอียดผู้ป่วย: แสดงข้อมูลของ "วันนี้" จาก UrineDataProvider
class UrineChart extends StatelessWidget {
  const UrineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final records = context.watch<UrineDataProvider>().records;
    final now = DateTime.now();
    final today = records.where((r) =>
    r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day);
    return UrineHourlyChart(
      records: today.toList(),
      emptyText: 'ยังไม่มีข้อมูลของวันนี้',
    );
  }
}

/// กราฟเส้นเดียว: ความสูง = ปริมาตร (มล.), สีเส้น/จุด = สีปัสสาวะ (colorCode)
/// รับ records ของวันเดียว (ลำดับใดก็ได้) แล้วรวมเป็นชั่วโมงละ 1 จุดเอง
class UrineHourlyChart extends StatelessWidget {
  final List<UrineRecord> records;
  final String latestLabel;
  final String emptyText;

  const UrineHourlyChart({
    super.key,
    required this.records,
    this.latestLabel = 'ล่าสุด',
    this.emptyText = 'ยังไม่มีข้อมูล',
  });

  static const double _lowVolume = 10; // ต่ำกว่าหรือเท่ากับนี้ = ผิดปกติ

  @override
  Widget build(BuildContext context) {
    final byHour = latestPerHour(records);
    final points = byHour.values.toList()
      ..sort((a, b) => a.timestamp.hour.compareTo(b.timestamp.hour));
    final latest = points.isEmpty ? null : points.last;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE3E8EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'ปริมาตรและสีปัสสาวะ 24 ชั่วโมง',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 14),
              child: Text(
                latest == null
                    ? emptyText
                    : '$latestLabel ชม.${latest.timestamp.hour}: '
                    '${latest.volumeMl.toStringAsFixed(0)} มล. · '
                    '${UrineColorMap.getLabel(latest.colorCode)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
            SizedBox(
              height: 240,
              child: points.isEmpty
                  ? Center(
                  child: Text(emptyText,
                      style: const TextStyle(color: Colors.black38)))
                  : LineChart(_buildChart(points, byHour)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('ใส',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 6),
                for (int code = 1; code <= 8; code++)
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: UrineColorMap.getColor(code),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26, width: 0.8),
                      ),
                    ),
                  ),
                const SizedBox(width: 3),
                const Text('เข้ม',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const Spacer(),
                Container(
                  width: 14,
                  height: 0,
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFFE57373), width: 1.5)),
                  ),
                ),
                const SizedBox(width: 5),
                const Text('เกณฑ์ต่ำ',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart(
      List<UrineRecord> points, Map<int, UrineRecord> byHour) {
    final spots = points
        .map((r) => FlSpot(r.timestamp.hour.toDouble(), r.volumeMl))
        .toList();

    final maxVol =
    points.map((r) => r.volumeMl).reduce((a, b) => a > b ? a : b);
    final maxY = maxVol <= 40 ? 50.0 : ((maxVol / 10).ceil() + 1) * 10.0;

    final minX = spots.first.x;
    final maxX = spots.last.x;
    List<Color> colors =
    points.map((r) => UrineColorMap.getColor(r.colorCode)).toList();
    List<double> stops = points
        .map((r) =>
    maxX == minX ? 0.0 : (r.timestamp.hour - minX) / (maxX - minX))
        .toList();
    if (colors.length == 1) {
      colors = [colors.first, colors.first];
      stops = [0.0, 1.0];
    }

    return LineChartData(
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (_) =>
        const FlLine(color: Color(0xFFEEF1F4), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
          y: _lowVolume,
          color: const Color(0xFFE57373),
          strokeWidth: 1.2,
          dashArray: [5, 4],
        ),
      ]),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          axisNameSize: 16,
          axisNameWidget: const Text('มล.',
              style: TextStyle(fontSize: 11, color: Colors.black45)),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 10,
            getTitlesWidget: (v, meta) => Text(v.toInt().toString(),
                style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameSize: 16,
          axisNameWidget: const Text('ชั่วโมง',
              style: TextStyle(fontSize: 11, color: Colors.black45)),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: (v, meta) {
              final h = v.toInt();
              // แสดงเว้นช่วงทุก 3 ชั่วโมง กันตัวเลขซ้อนกัน
              if (h % 3 != 0 && h != 23) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('$h',
                    style:
                    const TextStyle(fontSize: 11, color: Colors.black45)),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touched) => touched.map((t) {
            final r = byHour[t.x.toInt()];
            if (r == null) return null;
            return LineTooltipItem(
              'ชม.${r.timestamp.hour}\n'
                  '${r.volumeMl.toStringAsFixed(0)} มล.\n'
                  '${UrineColorMap.getLabel(r.colorCode)}',
              const TextStyle(color: Colors.white, fontSize: 12),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        // เงาเส้นบาง ๆ ให้สีอ่อนมองเห็นบนพื้นขาว
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.22,
          preventCurveOverShooting: true,
          barWidth: 6.5,
          color: const Color(0x1F000000),
          dotData: const FlDotData(show: false),
        ),
        // เส้นหลัก: สีไล่ตามสีปัสสาวะแต่ละชั่วโมง
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.22,
          preventCurveOverShooting: true,
          barWidth: 4,
          isStrokeCapRound: true,
          gradient: LinearGradient(colors: colors, stops: stops),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              final r = byHour[spot.x.toInt()];
              final low = spot.y <= _lowVolume;
              return FlDotCirclePainter(
                radius: 5,
                color: r == null
                    ? Colors.grey
                    : UrineColorMap.getColor(r.colorCode),
                strokeWidth: low ? 2.2 : 1.6,
                strokeColor: low ? const Color(0xFFE57373) : Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: colors.map((c) => c.withOpacity(0.28)).toList(),
              stops: stops,
            ),
          ),
        ),
      ],
    );
  }
}