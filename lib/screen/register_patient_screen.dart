import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/patient.dart';
import '../provider/patient_provider.dart';
import '../utils/constant.dart';

/// หน้าลงทะเบียนผู้ป่วย (กรอกครั้งเดียว) เปิดจากเตียงว่างในหน้าโซน
class RegisterPatientScreen extends StatefulWidget {
  final String bedId;
  final String zoneName;
  const RegisterPatientScreen({
    super.key,
    required this.bedId,
    required this.zoneName,
  });

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  String _gender = 'ชาย';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'กรุณากรอกข้อมูล' : null;

  String? _number(String? v, {double min = 0, double max = 999}) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกข้อมูล';
    final n = double.tryParse(v.trim());
    if (n == null) return 'กรอกเป็นตัวเลข';
    if (n <= min || n > max) return 'ค่าไม่อยู่ในช่วงที่เป็นไปได้';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final patient = Patient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      gender: _gender,
      weight: double.parse(_weight.text.trim()),
      height: double.parse(_height.text.trim()),
      bedId: widget.bedId,
      zone: widget.zoneName,
    );

    final provider = context.read<PatientProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await provider.addPatient(patient);
      messenger.showSnackBar(
        SnackBar(content: Text('ลงทะเบียน ${patient.name} เตียง ${widget.bedId} แล้ว')),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
    }
  }

  InputDecoration _dec(String label, {String? suffix}) => InputDecoration(
    labelText: label,
    suffixText: suffix,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD5DDE3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD5DDE3)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ลงทะเบียนผู้ป่วย',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              Text(
                'โซน ${widget.zoneName} · เตียง ${widget.bedId}',
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: _dec('ชื่อ-นามสกุล'),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _age,
                      decoration: _dec('อายุ', suffix: 'ปี'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final e = _number(v, max: 130);
                        if (e != null) return e;
                        return int.tryParse(v!.trim()) == null
                            ? 'กรอกเป็นจำนวนเต็ม'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _dec('เพศ'),
                      items: const [
                        DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
                        DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'ชาย'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weight,
                      decoration: _dec('น้ำหนัก', suffix: 'กก.'),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (v) => _number(v, max: 400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _height,
                      decoration: _dec('ส่วนสูง', suffix: 'ซม.'),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => _number(v, max: 260),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('บันทึกผู้ป่วย'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}