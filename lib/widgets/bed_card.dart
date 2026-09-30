import 'package:flutter/material.dart';
import '../model/patient.dart';
import '../utils/aki_assessment.dart';
import '../utils/constant.dart';
import 'aki_badge.dart';

class BedCard extends StatelessWidget {
  final String bedId;      // เช่น "5a"
  final Patient? patient;  // null = เตียงว่าง
  final AkiResult? aki;    // ผลประเมิน AKI (null = ยังไม่มีผล)
  final VoidCallback onTap;

  const BedCard({
    super.key,
    required this.bedId,
    required this.patient,
    required this.onTap,
    this.aki,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOccupied = patient != null;
    final bool alert = isOccupied &&
        aki != null &&
        aki!.hasEnoughData &&
        aki!.stage != AkiStage.u0;
    final Color alertColor =
    alert ? akiStageColor(aki!.stage) : AppConstants.primaryColor;

    return Card(
      elevation: 2,
      color: isOccupied ? AppConstants.bedCardColor : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: alert
              ? alertColor
              : isOccupied
              ? AppConstants.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.shade300,
          width: alert ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isOccupied
                          ? AppConstants.primaryColor
                          : Colors.grey.shade400,
                      child: Text(
                        bedId.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isOccupied ? patient!.name : 'เตียงว่าง',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        isOccupied ? FontWeight.w600 : FontWeight.normal,
                        color: isOccupied ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    if (isOccupied) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${patient!.age} ปี',
                        style:
                        const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // ป้าย AKI มุมขวาบน (วางทับ ไม่ดันเนื้อหาจนล้น)
            if (isOccupied && aki != null)
              Positioned(
                top: 6,
                right: 6,
                child: AkiBadge(result: aki!),
              ),
          ],
        ),
      ),
    );
  }
}