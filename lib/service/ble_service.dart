import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constant.dart';

class UrineReading {
  final int hour, volume, r, g, b;
  UrineReading(this.hour, this.volume, this.r, this.g, this.b);

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

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
    BluetoothDevice? found;
    await for (final results in FlutterBluePlus.scanResults) {
      for (final r in results) {
        if (r.device.platformName
            .startsWith(AppConstants.bleDeviceNamePrefix)) {
          found = r.device;
          break;
        }
      }
      if (found != null) break;
    }
    await FlutterBluePlus.stopScan();
    if (found == null) return false;

    _device = found;
    await _device!.connect();
    try {
      await _device!.requestMtu(128);
    } catch (_) {}

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
    if (_char == null) return false;

    await _startNotify();
    return true;
  }

  Future<void> _startNotify() async {
    await _sub?.cancel();
    await _char!.setNotifyValue(true);
    _sub = _char!.onValueReceived.listen((value) {
      try {
        final map = jsonDecode(utf8.decode(value)) as Map<String, dynamic>;
        final r = UrineReading.fromJson(map);
        history[r.hour] = r;
        _controller.add(r);
      } catch (_) {}
    });
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    await _device?.disconnect();
    _char = null;
  }
}