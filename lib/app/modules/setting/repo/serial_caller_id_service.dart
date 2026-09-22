// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'serial_caller_id_parser.dart';

// class SerialCallerIdService extends GetxService {
//   SerialPort? _port;
//   SerialPortReader? _reader;
//   StreamSubscription? _subscription;
//   Timer? _reconnectTimer;
//   Timer? _healthTimer;

//   final isListening = false.obs;
//   final statusMessage = 'Not connected'.obs;
//   final availablePorts = <String>[].obs;

//   // Save করা port settings — reconnect এর জন্য
//   String? _savedPort;
//   int _savedBaud = 9600;

//   // Controllers subscribe করবে এখানে
//   final _callStream = StreamController<CallerIdData>.broadcast();
//   Stream<CallerIdData> get callStream => _callStream.stream;

//   // Raw data stream — Settings screen debug monitor এর জন্য
//   final _rawStream = StreamController<String>.broadcast();
//   Stream<String> get rawStream => _rawStream.stream;

//   String _buffer = '';

//   Future<SerialCallerIdService> init() async {
//     refreshPorts();
//     _startHealthCheck();
//     return this;
//   }

//   void refreshPorts() {
//     availablePorts.value = SerialPort.availablePorts;
//     print('[Serial] Available ports: ${availablePorts.value}');
//   }

//   Future<bool> connect({
//     required String portName,
//     int baudRate = 9600,
//   }) async {
//     if (isListening.value) await disconnect();

//     _savedPort = portName;
//     _savedBaud = baudRate;

//     try {
//       _port = SerialPort(portName);

//       final config = SerialPortConfig();
//       config.baudRate = baudRate;
//       config.bits = 8;
//       config.stopBits = 1;
//       config.parity = SerialPortParity.none;
//       config.setFlowControl(SerialPortFlowControl.none);

//       if (!_port!.openRead()) {
//         final err = SerialPort.lastError?.message ?? 'Unknown error';
//         statusMessage.value = 'Cannot open $portName: $err';
//         print('[Serial] ✗ $portName: $err');
//         return false;
//       }

//       _port!.config = config;
//       _reader = SerialPortReader(_port!);
//       _startReading();

//       isListening.value = true;
//       statusMessage.value = 'Connected — $portName @ $baudRate baud';
//       print('[Serial] ✓ Connected: $portName @ $baudRate');
//       return true;
//     } catch (e) {
//       statusMessage.value = 'Error: $e';
//       print('[Serial] ✗ Exception: $e');
//       return false;
//     }
//   }

//   void _startReading() {
//     _subscription = _reader!.stream.listen(
//       _onData,
//       onError: (e) {
//         print('[Serial] Read error: $e');
//         isListening.value = false;
//         statusMessage.value = 'Read error — will retry...';
//         _scheduleReconnect();
//       },
//       onDone: () {
//         print('[Serial] Port closed');
//         isListening.value = false;
//         statusMessage.value = 'Disconnected';
//       },
//     );
//   }

// //   void _onData(Uint8List data) {
// //   final chunk = String.fromCharCodes(data);
// //   _buffer += chunk;

// //   print('[Serial] Buffer: $_buffer');

// //   // NAME field আসলেই complete ধরো
// //   if (_buffer.contains('NAME')) {
// //     final raw = _buffer.trim();
// //     _buffer = '';
// //     if (raw.isEmpty) return;
// //     print('[Serial] Full message:\n$raw');
// //     _rawStream.add(raw);
// //     final parsed = SerialCallerIdParser.parse(raw);
// //     if (parsed != null) {
// //       print('[Serial] ✓ Phone: ${parsed.phoneNumber}');
// //       _callStream.add(parsed);
// //     }
// //   }
// // }
// void _onData(Uint8List data) {
//   final chunk = String.fromCharCodes(data);
//   _buffer += chunk;

//   // Whozz Calling? sends one complete record per line ending with CR/LF
//   if (_buffer.contains('\n') || _buffer.contains('\r')) {
//     final lines = _buffer.split(RegExp(r'[\r\n]+'));
//     _buffer = lines.last; // incomplete line রাখো

//     for (final line in lines) {
//       final raw = line.trim();
//       if (raw.isEmpty) continue;

//       print('[Serial] Line: $raw');
//       _rawStream.add(raw);

//       final parsed = SerialCallerIdParser.parse(raw);
//       if (parsed != null && parsed.isInboundStart) {
//         print('[Serial] ✓ Phone: ${parsed.phoneNumber}');
//         _callStream.add(parsed);
//       }
//     }
//   }
// }

//   // void _onData(Uint8List data) {
//   //   final chunk = String.fromCharCodes(data);
//   //   _buffer += chunk;

//   //   print(
//   //     '[Serial] Chunk: ${chunk.replaceAll('\r', '\\r').replaceAll('\n', '\\n')}',
//   //   );

//   //   // Message complete কিনা check করো
//   //   // CallerID device সাধারণত blank line দিয়ে message শেষ করে
//   //   final isComplete = _buffer.contains('\n\n') ||
//   //       _buffer.contains('\r\n\r\n') ||
//   //       (_buffer.contains('NAME') && _buffer.contains('NMBR')) ||
//   //       (_buffer.contains('NMBR') &&
//   //           !_buffer.trimRight().endsWith('NMBR'));

//   //   if (isComplete) {
//   //     final raw = _buffer.trim();
//   //     _buffer = '';

//   //     if (raw.isEmpty) return;

//   //     print('[Serial] Full message:\n$raw');
//   //     _rawStream.add(raw); // debug monitor এ দেখাবে

//   //     final parsed = SerialCallerIdParser.parse(raw);
//   //     if (parsed != null) {
//   //       print(
//   //         '[Serial] ✓ Parsed → Phone: ${parsed.phoneNumber}, Name: ${parsed.callerName}',
//   //       );
//   //       _callStream.add(parsed);
//   //     } else {
//   //       print('[Serial] Could not parse — check raw data in monitor');
//   //     }
//   //   }
//   // }

//   void _scheduleReconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 5), () {
//       if (_savedPort != null && !isListening.value) {
//         print('[Serial] Attempting reconnect to $_savedPort...');
//         connect(portName: _savedPort!, baudRate: _savedBaud);
//       }
//     });
//   }

//   void _startHealthCheck() {
//     _healthTimer = Timer.periodic(const Duration(minutes: 2), (_) {
//       if (_savedPort != null && !isListening.value) {
//         print('[Serial] Health check — reconnecting...');
//         connect(portName: _savedPort!, baudRate: _savedBaud);
//       }
//     });
//   }
//   // Test এর জন্য — hardware ছাড়াই call simulate করা যাবে
// void injectTestCall(CallerIdData data) {
//   print('[Serial] ⚡ Test call injected: ${data.phoneNumber}');
//   _rawStream.add('TEST PACKET\nNMBR = ${data.phoneNumber}\nNAME = ${data.callerName}');
//   _callStream.add(data);
// }

//   Future<void> disconnect() async {
//     _reconnectTimer?.cancel();
//     await _subscription?.cancel();
//     _subscription = null;
//     _reader?.close();
//     _reader = null;
//     _port?.close();
//     _port?.dispose();
//     _port = null;
//     _buffer = '';
//     isListening.value = false;
//     statusMessage.value = 'Disconnected';
//     print('[Serial] Disconnected');
//   }

//   @override
//   void onClose() {
//     _healthTimer?.cancel();
//     disconnect();
//     _callStream.close();
//     _rawStream.close();
//     super.onClose();
//   }
// }