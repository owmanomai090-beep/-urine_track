import 'package:flutter/material.dart';
import '../model/patient.dart';
import '../utils/constant.dart';

class BedCard extends StatelessWidget {
  final String bedId;      // เช่น "5a"
  final Patient? patient;  // null = เตียงว่าง
  final VoidCallback onTap;

  const BedCard({
    super.key,
    required this.bedId,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOccupied = patient != null;

    return Card(
      elevation: 2,
      color: isOccupied ? AppConstants.bedCardColor : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: isOccupied
              ? AppConstants.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                  fontWeight: isOccupied ? FontWeight.w600 : FontWeight.normal,
                  color: isOccupied ? Colors.black87 : Colors.grey,
                ),
              ),
              if (isOccupied) ...[
                const SizedBox(height: 2),
                Text(
                  '${patient!.age} ปี',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}