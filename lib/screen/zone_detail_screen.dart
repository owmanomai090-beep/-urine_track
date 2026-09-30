import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/bed_zone.dart';
import '../model/patient.dart';
import '../provider/patient_provider.dart';
import '../provider/urine_data_provider.dart';
import '../utils/constant.dart';
import '../widgets/bed_card.dart';
import 'patient_detail_screen.dart';
import '../service/ble_service.dart';
import 'register_patient_screen.dart';

class ZoneDetailScreen extends StatefulWidget {
  final Zone zone;
  const ZoneDetailScreen({super.key, required this.zone});

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  /// โหลดผู้ป่วยล่าสุด แล้วคำนวณ AKI ของทุกเตียง
  Future<void> _refresh() async {
    final patientProvider = context.read<PatientProvider>();
    final urineProvider = context.read<UrineDataProvider>();
    await patientProvider.loadPatients();
    if (!mounted) return;
    await urineProvider.loadAkiForPatients(patientProvider.patients);
  }

  // เชื่อมต่อ ESP32
  Future<void> _testBle() async {
    if (_connecting) return;
    setState(() => _connecting = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('กำลังสแกนหา ESP32...')),
    );

    String msg;
    try {
      final ble = BleService.instance;
      final ok = await ble.connect();
      msg = ok
          ? 'เชื่อมต่อสำเร็จ: กำลังรับข้อมูล'
          : 'เชื่อมต่อไม่สำเร็จ (ไม่พบอุปกรณ์)';
    } catch (e) {
      msg = 'เกิดข้อผิดพลาด: $e';
    }

    if (!mounted) return;
    setState(() => _connecting = false);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final urineProvider = context.watch<UrineDataProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          'โซน ${widget.zone.name}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: _connecting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.bluetooth, color: Colors.white),
            onPressed: _testBle,
          ),
        ],
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
                aki: patient == null ? null : urineProvider.akiFor(patient.id),
                onTap: () async {
                  if (patient == null) {
                    // เตียงว่าง: เปิดหน้าลงทะเบียนผู้ป่วย
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterPatientScreen(
                          bedId: bedId,
                          zoneName: widget.zone.name,
                        ),
                      ),
                    );
                    if (mounted) _refresh();
                    return;
                  }
                  patientProvider.selectPatient(patient);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailScreen(patient: patient),
                    ),
                  );
                  // กลับมาแล้วคำนวณ AKI ใหม่ (อาจมีข้อมูลเพิ่มระหว่างอยู่หน้าผู้ป่วย)
                  if (mounted) _refresh();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}