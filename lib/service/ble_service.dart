import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constant.dart';
import 'package:flutter/foundation.dart';

class UrineReading {
  final int hour, volume, r, g, b;
  final DateTime receivedAt; // เพิ่ม: เวลาที่แอปรับข้อมูล ใช้กรอง "ของวันนี้"
  UrineReading(this.hour, this.volume, this.r, this.g, this.b)
      : receivedAt = DateTime.now();

  factory UrineReading.fromJson(Map<String, dynamic> j) => UrineReading(
    j['hour'] as int,
    j['volume'] as int,
    j['r'] as int,
    j['g'] as int,
    j['b'] as int,
  );
}

class BleService {
  static final BleService instance = BleService._();
  BleService._();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _char;
  StreamSubscription<List<int>>? _sub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  String _buffer = '';

  final Map<int, UrineReading> history = {};
  final _controller = StreamController<UrineReading>.broadcast();
  Stream<UrineReading> get readings => _controller.stream;

  bool get isConnected => _device?.isConnected ?? false;

  Future<bool> connect() async {
    if (isConnected && _char != null) return true;

    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // แก้: เดิม await for scanResults จะค้างตลอดไปถ้าไม่เจออุปกรณ์
    // (stream นี้ไม่ปิดเมื่อสแกนจบ) จึงใช้ firstWhere + timeout แทน
    // และกรองด้วย service UUID เพราะ platformName บางครั้งว่างตอนสแกน
    await FlutterBluePlus.startScan(
      withServices: [Guid(AppConstants.bleServiceUuid)],
      timeout: const Duration(seconds: 8),
    );
    BluetoothDevice? found;
    try {
      final results = await FlutterBluePlus.scanResults
          .firstWhere((l) => l.isNotEmpty)
          .timeout(const Duration(seconds: 8));
      found = results.first.device;
    } on TimeoutException {
      found = null;
    }
    await FlutterBluePlus.stopScan();
    if (found == null) {
      debugPrint('BLE: device not found');
      return false;
    }

    _device = found;
    await _device!.connect();

    // เมื่อหลุดการเชื่อมต่อ ให้ล้าง _char เพื่อให้ connect() รอบหน้าทำงานใหม่
    await _connSub?.cancel();
    _connSub = _device!.connectionState.listen((s) {
      if (s == BluetoothConnectionState.disconnected) {
        debugPrint('BLE: disconnected');
        _char = null;
        _buffer = '';
      }
    });

    try {
      await _device!.requestMtu(128);
    } catch (e) {
      debugPrint('BLE: requestMtu failed: $e');
    }

    final services = await _device!.discoverServices();
    for (final s in services) {
      if (s.uuid.toString().toLowerCase() == AppConstants.bleServiceUuid) {
        for (final c in s.characteristics) {
          if (c.uuid.toString().toLowerCase() ==
              AppConstants.bleCharacteristicUuid) {
            _char = c;
          }
        }
      }
    }
    if (_char == null) {
      debugPrint('BLE: characteristic not found');
      return false;
    }

    await _startNotify();
    return true;
  }

  Future<void> _startNotify() async {
    await _sub?.cancel();
    _buffer = '';
    await _char!.setNotifyValue(true);
    debugPrint('BLE: notify enabled, mtu=${_device!.mtuNow}');
    _sub = _char!.onValueReceived.listen(_onData);
  }

  // แก้: ต่อข้อความที่ถูกตัดเป็นชิ้นจนได้ JSON ครบก่อนค่อย decode
  // (กันกรณี requestMtu ไม่สำเร็จ แล้วได้ข้อมูลทีละ 20 ไบต์)
  void _onData(List<int> value) {
    if (value.isEmpty) return;
    final text = utf8.decode(value, allowMalformed: true);
    debugPrint('BLE rx (${value.length} bytes): $text');
    _buffer += text;

    while (true) {
      final start = _buffer.indexOf('{');
      final end = _buffer.indexOf('}');
      if (start == -1 || end == -1 || end < start) {
        if (start == -1) _buffer = '';
        break;
      }
      final jsonStr = _buffer.substring(start, end + 1);
      _buffer = _buffer.substring(end + 1);
      try {
        final r = UrineReading.fromJson(
            jsonDecode(jsonStr) as Map<String, dynamic>);
        history[r.hour] = r;
        _controller.add(r);
      } catch (e) {
        debugPrint('BLE parse error: $e ($jsonStr)');
      }
    }
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    await _connSub?.cancel();
    await _device?.disconnect();
    _char = null;
    _buffer = '';
  }
}