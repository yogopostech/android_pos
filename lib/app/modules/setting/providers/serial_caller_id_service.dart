// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'package:yogo_pos/app/modules/setting/repo/serial_caller_id_parser.dart';

// part 'serial_caller_id_service.g.dart';

// class CallerIdServiceState {
//   final bool isListening;
//   final String statusMessage;
//   final List<String> availablePorts;
//   final bool isDialogOpen;

//   const CallerIdServiceState({
//     this.isListening = false,
//     this.statusMessage = 'Not connected',
//     this.availablePorts = const [],
//     this.isDialogOpen = false,
//   });

//   CallerIdServiceState copyWith({
//     bool? isListening,
//     String? statusMessage,
//     List<String>? availablePorts,
//     bool? isDialogOpen,
//   }) => CallerIdServiceState(
//     isListening: isListening ?? this.isListening,
//     statusMessage: statusMessage ?? this.statusMessage,
//     availablePorts: availablePorts ?? this.availablePorts,
//     isDialogOpen: isDialogOpen ?? this.isDialogOpen,
//   );
// }

// @Riverpod(keepAlive: true)
// class SerialCallerIdService extends _$SerialCallerIdService {
//   SerialPort? _port;
//   SerialPortReader? _reader;
//   StreamSubscription? _subscription;
//   Timer? _reconnectTimer;
//   Timer? _healthTimer;

//   String? _savedPort;
//   int _savedBaud = 9600;
//   String _buffer = '';

//   final _callController = StreamController<CallerIdData>.broadcast();
//   final _rawController = StreamController<String>.broadcast();

//   Stream<CallerIdData> get callStream => _callController.stream;
//   Stream<String> get rawStream => _rawController.stream;

//   @override
//   CallerIdServiceState build() {
//     ref.onDispose(_onDispose);
//     _startHealthCheck();
//     return CallerIdServiceState(availablePorts: SerialPort.availablePorts);
//   }

//   void refreshPorts() {
//     state = state.copyWith(availablePorts: SerialPort.availablePorts);
//   }

//   void setDialogOpen(bool value) {
//     state = state.copyWith(isDialogOpen: value);
//   }

//   Future<bool> connect({required String portName, int baudRate = 9600}) async {
//     if (state.isListening) await disconnect();

//     _savedPort = portName;
//     _savedBaud = baudRate;

//     const maxRetries = 5;
//     const retryDelay = Duration(seconds: 2);

//     for (int attempt = 1; attempt <= maxRetries; attempt++) {
//       try {
//         _port = SerialPort(portName);

//         final config = SerialPortConfig()
//           ..baudRate = baudRate
//           ..bits = 8
//           ..stopBits = 1
//           ..parity = SerialPortParity.none;
//         config.setFlowControl(SerialPortFlowControl.none);

//         if (!_port!.openRead()) {
//           final err = SerialPort.lastError?.message ?? 'Unknown error';
//           if (attempt < maxRetries) {
//             state = state.copyWith(
//               statusMessage: 'Retrying ($attempt/$maxRetries)...',
//             );
//             _port?.dispose();
//             _port = null;
//             await Future.delayed(retryDelay);
//             continue;
//           }
//           state = state.copyWith(statusMessage: 'Cannot open $portName: $err');
//           return false;
//         }

//         _port!.config = config;
//         _reader = SerialPortReader(_port!);
//         _startReading();

//         state = state.copyWith(
//           isListening: true,
//           statusMessage: 'Connected — $portName @ $baudRate baud',
//         );
//         return true;
//       } catch (e) {
//         if (attempt < maxRetries) {
//           _port?.dispose();
//           _port = null;
//           await Future.delayed(retryDelay);
//           continue;
//         }
//         state = state.copyWith(statusMessage: 'Error: $e');
//         return false;
//       }
//     }
//     return false;
//   }

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
//     state = state.copyWith(isListening: false, statusMessage: 'Disconnected');
//   }

//   void injectTestCall(CallerIdData data) {
//     _rawController.add(
//       'TEST\nNMBR = ${data.phoneNumber}\nNAME = ${data.callerName}',
//     );
//     _callController.add(data);
//   }

//   void _startReading() {
//     _subscription = _reader!.stream.listen(
//       _onData,
//       onError: (_) {
//         state = state.copyWith(
//           isListening: false,
//           statusMessage: 'Read error — will retry...',
//         );
//         _scheduleReconnect();
//       },
//       onDone: () {
//         state = state.copyWith(
//           isListening: false,
//           statusMessage: 'Disconnected',
//         );
//       },
//     );
//   }

//   void _onData(Uint8List data) {
//     _buffer += String.fromCharCodes(data);

//     if (!_buffer.contains('\n') && !_buffer.contains('\r')) return;

//     final lines = _buffer.split(RegExp(r'[\r\n]+'));
//     _buffer = lines.last;

//     for (final line in lines) {
//       final raw = line.trim();
//       if (raw.isEmpty) continue;
//       _rawController.add(raw);
//       final parsed = SerialCallerIdParser.parse(raw);
//       if (parsed != null && parsed.isInboundStart) {
//         _callController.add(parsed);
//       }
//     }
//   }

//   void _scheduleReconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 5), () {
//       if (_savedPort != null && !state.isListening) {
//         connect(portName: _savedPort!, baudRate: _savedBaud);
//       }
//     });
//   }

//   void _startHealthCheck() {
//     _healthTimer = Timer.periodic(const Duration(minutes: 2), (_) {
//       if (_savedPort != null && !state.isListening) {
//         connect(portName: _savedPort!, baudRate: _savedBaud);
//       }
//     });
//   }

//   void _onDispose() {
//     _healthTimer?.cancel();
//     disconnect();
//     _callController.close();
//     _rawController.close();
//   }
// }
