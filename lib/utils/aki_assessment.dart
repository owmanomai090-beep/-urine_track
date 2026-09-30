import '../model/urine_record.dart';

/// ระยะตามตารางที่ 1: U0 ปกติ, U1 ระยะ 1, U2 ระยะ 2, U3 ระยะ 3
enum AkiStage { u0, u1, u2, u3 }

class AkiResult {
  final AkiStage stage;

  /// มีข้อมูลต่อเนื่องพอให้ประเมินหรือไม่ (อย่างน้อย 6 ชั่วโมง)
  final bool hasEnoughData;

  /// จำนวนชั่วโมงที่มีข้อมูลต่อเนื่อง นับย้อนจากชั่วโมงล่าสุด
  final int continuousHours;

  /// อัตราขับปัสสาวะของชั่วโมงล่าสุด (มล./กก./ชม.)
  final double? latestRate;

  /// จำนวนชั่วโมงต่อเนื่อง (นับย้อนจากล่าสุด) ที่ต่ำกว่า 0.5 / ต่ำกว่า 0.3 / ไม่มีปัสสาวะ
  final int low05Hours;
  final int low03Hours;
  final int anuriaHours;

  const AkiResult({
    required this.stage,
    required this.hasEnoughData,
    required this.continuousHours,
    required this.latestRate,
    required this.low05Hours,
    required this.low03Hours,
    required this.anuriaHours,
  });

  static const empty = AkiResult(
    stage: AkiStage.u0,
    hasEnoughData: false,
    continuousHours: 0,
    latestRate: null,
    low05Hours: 0,
    low03Hours: 0,
    anuriaHours: 0,
  );
}

class AkiAssessment {
  /// Urine output (mL/kg/hr) = ปริมาตรปัสสาวะ (mL) / (น้ำหนัก (kg) x เวลา (hr))
  /// ที่นี่ 1 record = ปริมาตรของ 1 ชั่วโมง จึงหารด้วยน้ำหนักอย่างเดียว
  static double rate(double volumeMl, double weightKg) => volumeMl / weightKg;

  static const double _mild = 0.5;
  static const double _severe = 0.3;

  static AkiResult assess(List<UrineRecord> records, double weightKg) {
    if (records.isEmpty || weightKg <= 0) return AkiResult.empty;

    // รวมเป็นชั่วโมงละ 1 ค่า (ค่าล่าสุดของชั่วโมงนั้น)
    final Map<DateTime, UrineRecord> buckets = {};
    for (final r in records) {
      final t = r.timestamp;
      final key = DateTime(t.year, t.month, t.day, t.hour);
      final cur = buckets[key];
      if (cur == null || t.isAfter(cur.timestamp)) buckets[key] = r;
    }

    // เรียงใหม่ -> เก่า แล้วต่อโซ่ชั่วโมงที่ติดกัน หยุดเมื่อมีชั่วโมงขาด
    final keys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
    final chain = <UrineRecord>[buckets[keys.first]!];
    for (int i = 1; i < keys.length; i++) {
      final expected = keys[i - 1].subtract(const Duration(hours: 1));
      if (keys[i] != expected) break;
      chain.add(buckets[keys[i]]!);
    }

    int run(bool Function(UrineRecord r) test) {
      int n = 0;
      for (final r in chain) {
        if (!test(r)) break;
        n++;
      }
      return n;
    }

    final low05 = run((r) => rate(r.volumeMl, weightKg) < _mild);
    final low03 = run((r) => rate(r.volumeMl, weightKg) < _severe);
    final anuria = run((r) => r.volumeMl <= 0);

    AkiStage stage;
    if (low03 >= 24 || anuria >= 12) {
      stage = AkiStage.u3;
    } else if (low05 >= 12) {
      stage = AkiStage.u2;
    } else if (low05 >= 6) {
      stage = AkiStage.u1;
    } else {
      stage = AkiStage.u0;
    }

    return AkiResult(
      stage: stage,
      hasEnoughData: chain.length >= 6,
      continuousHours: chain.length,
      latestRate: rate(chain.first.volumeMl, weightKg),
      low05Hours: low05,
      low03Hours: low03,
      anuriaHours: anuria,
    );
  }
}