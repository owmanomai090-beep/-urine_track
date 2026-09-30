import 'package:flutter/material.dart';
import '../utils/aki_assessment.dart';

Color akiStageColor(AkiStage s) {
  switch (s) {
    case AkiStage.u0:
      return const Color(0xFF2E7D32);
    case AkiStage.u1:
      return const Color(0xFFF9A825);
    case AkiStage.u2:
      return const Color(0xFFEF6C00);
    case AkiStage.u3:
      return const Color(0xFFC62828);
  }
}

String akiStageCode(AkiStage s) {
  switch (s) {
    case AkiStage.u0:
      return 'U0';
    case AkiStage.u1:
      return 'U1';
    case AkiStage.u2:
      return 'U2';
    case AkiStage.u3:
      return 'U3';
  }
}

/// ป้ายเล็กแสดงระยะ AKI (เทา "-" ถ้าข้อมูลยังไม่พอประเมิน)
class AkiBadge extends StatelessWidget {
  final AkiResult result;
  const AkiBadge({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ok = result.hasEnoughData;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ok ? akiStageColor(result.stage) : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ok ? akiStageCode(result.stage) : '-',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}