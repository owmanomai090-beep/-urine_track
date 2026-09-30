import 'package:flutter/material.dart';
import '../model/urine_record.dart';
import '../utils/aki_assessment.dart';

/// การ์ดสรุปการประเมินภาวะไตบาดเจ็บเฉียบพลัน (AKI) จากอัตราการขับปัสสาวะ
class AkiCard extends StatelessWidget {
  final List<UrineRecord> records;
  final double weightKg;

  const AkiCard({super.key, required this.records, required this.weightKg});

  static const _stageColor = {
    AkiStage.u0: Color(0xFF2E7D32),
    AkiStage.u1: Color(0xFFF9A825),
    AkiStage.u2: Color(0xFFEF6C00),
    AkiStage.u3: Color(0xFFC62828),
  };

  static const _stageCode = {
    AkiStage.u0: 'U0',
    AkiStage.u1: 'U1',
    AkiStage.u2: 'U2',
    AkiStage.u3: 'U3',
  };

  static const _stageTitle = {
    AkiStage.u0: 'ปกติ',
    AkiStage.u1: 'ไตบาดเจ็บเฉียบพลัน ระยะที่ 1',
    AkiStage.u2: 'ไตบาดเจ็บเฉียบพลัน ระยะที่ 2',
    AkiStage.u3: 'ไตบาดเจ็บเฉียบพลัน ระยะที่ 3',
  };

  String _detail(AkiResult r) {
    if (!r.hasEnoughData) {
      return 'ต้องมีข้อมูลต่อเนื่องอย่างน้อย 6 ชั่วโมงจึงจะประเมินได้ '
          '(ตอนนี้ ${r.continuousHours} ชม.)';
    }
    switch (r.stage) {
      case AkiStage.u0:
        return r.low05Hours > 0
            ? 'ต่ำกว่า 0.5 มล./กก./ชม. ต่อเนื่อง ${r.low05Hours} ชม. (เฝ้าระวัง)'
            : 'อัตราขับปัสสาวะปกติ';
      case AkiStage.u1:
      case AkiStage.u2:
        return 'ปัสสาวะน้อยกว่า 0.5 มล./กก./ชม. ต่อเนื่อง ${r.low05Hours} ชม.';
      case AkiStage.u3:
        return r.anuriaHours >= 12
            ? 'ไม่มีปัสสาวะต่อเนื่อง ${r.anuriaHours} ชม.'
            : 'ปัสสาวะน้อยกว่า 0.3 มล./กก./ชม. ต่อเนื่อง ${r.low03Hours} ชม.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = AkiAssessment.assess(records, weightKg);
    final color = r.hasEnoughData ? _stageColor[r.stage]! : Colors.grey;
    final code = r.hasEnoughData ? _stageCode[r.stage]! : '-';
    final title = r.hasEnoughData ? _stageTitle[r.stage]! : 'ยังประเมินไม่ได้';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('การประเมิน AKI (จากอัตราขับปัสสาวะ)',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_detail(r), style: const TextStyle(fontSize: 13.5)),
            if (r.latestRate != null) ...[
              const SizedBox(height: 6),
              Text(
                'ชั่วโมงล่าสุด ${r.latestRate!.toStringAsFixed(2)} มล./กก./ชม. '
                    '(น้ำหนัก ${weightKg.toStringAsFixed(0)} กก.)',
                style: const TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'ใช้ประกอบการพิจารณาเท่านั้น ไม่ใช่การวินิจฉัย',
              style: TextStyle(fontSize: 11.5, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}