import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/bed_zone.dart';
import '../model/patient.dart';
import '../provider/patient_provider.dart';
import '../utils/constant.dart';
import '../widgets/bed_card.dart';
import 'patient_detail_screen.dart';

class ZoneDetailScreen extends StatefulWidget {
  final Zone zone;
  const ZoneDetailScreen({super.key, required this.zone});

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลผู้ป่วยล่าสุดทุกครั้งที่เข้าหน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          'โซน ${widget.zone.name}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: GridView.builder(
            itemCount: widget.zone.bedIds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final String bedId = widget.zone.bedIds[index];
              final Patient? patient =
              patientProvider.getPatientByBedId(bedId);

              return BedCard(
                bedId: bedId,
                patient: patient,
                onTap: () {
                  if (patient == null) {
                    // เตียงว่าง — ยังไม่มีข้อมูลผู้ป่วย
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เตียงนี้ยังไม่มีผู้ป่วย')),
                    );
                    return;
                  }
                  patientProvider.selectPatient(patient);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailScreen(patient: patient),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}