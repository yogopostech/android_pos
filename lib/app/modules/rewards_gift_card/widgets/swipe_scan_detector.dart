import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CardInputType { swipe, scan }

class SwipeScanResult {
  final String cardNumber;
  final CardInputType type;
  final String raw;
  const SwipeScanResult({
    required this.cardNumber,
    required this.type,
    required this.raw,
  });
}

/// Barcode-scanner (HID keyboard) capture via a hidden, always-focused field.
/// Scan input goes ONLY here (card), never into other fields. Manual entry in
/// other fields works by tapping them (which pauses this capture).
class SwipeScanDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<SwipeScanResult> onDetected;

  const SwipeScanDetector({
    super.key,
    required this.child,
    required this.onDetected,
  });

  @override
  State<SwipeScanDetector> createState() => SwipeScanDetectorState();
}

class SwipeScanDetectorState extends State<SwipeScanDetector> {
  final FocusNode _hiddenFocus = FocusNode(debugLabel: 'ScanCapture');
  final TextEditingController _hiddenCtrl = TextEditingController();

  Timer? _timeout;
  bool _paused = false;

  static const int _minLength = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _grab());
  }
  //

  void _grab() {
    if (mounted && !_paused) _hiddenFocus.requestFocus();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _hiddenFocus.dispose();
    _hiddenCtrl.dispose();
    super.dispose();
  }

  /// User tapped a manual field (e.g. amount) -> stop scan capture.
  void pause() => _paused = true;

  /// Make scan capture active again and re-grab the hidden field.
  void resume() {
    _paused = false;
    _hiddenCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _grab());
  }

  void refocus() => resume();

  void _onChanged(String value) {
    // Scanner streams chars fast, then sends Enter. Finalize on Enter or a
    // short silence (some scanners omit Enter).
    _timeout?.cancel();
    _timeout = Timer(const Duration(milliseconds: 200), _finalize);
  }

  void _onSubmitted(String value) => _finalize();

  void _finalize() {
    _timeout?.cancel();
    final raw = _hiddenCtrl.text;
    _hiddenCtrl.clear();
    if (raw.length < _minLength) {
      if (!_paused) _grab();
      return;
    }
    final cardNumber = raw.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    if (cardNumber.isEmpty) {
      if (!_paused) _grab();
      return;
    }
    widget.onDetected(
      SwipeScanResult(cardNumber: cardNumber, type: CardInputType.scan, raw: raw),
    );
    // Stay scan-ready for the next card.
    if (!_paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _grab());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: -1000,
          top: -1000,
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0,
            child: TextField(
              focusNode: _hiddenFocus,
              controller: _hiddenCtrl,
              autofocus: true,
              showCursor: false,
              enableInteractiveSelection: false,
              onChanged: _onChanged,
              onSubmitted: _onSubmitted,
            ),
          ),
        ),
      ],
    );
  }
 
}






// ... swipe_scan_detector.dart er baki sob code (SwipeScanDetector class etc.)

// ⬇️ File er ekdom SHESHE ei class ta add koro:

/// Fast (scanner) keystroke block kore, slow (manual) typing allow kore.
/// Amount er moto manual field e boshao -> scan char amount e dhukbe na.
/// Manual field (amount) e scanner input block kore.
/// Scanner ekbare fast burst e type kore -> block. Manual slow typing -> allow.
class BlockFastInputFormatter extends TextInputFormatter {
  DateTime? _lastKey;
  final int fastGapMs;

  BlockFastInputFormatter({this.fastGapMs = 40});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Delete/clear -> allow, timing reset.
    if (newValue.text.length <= oldValue.text.length) {
      _lastKey = null;
      return newValue;
    }

    // Ekbare 1+ char (paste/scan chunk) -> block.
    if (newValue.text.length - oldValue.text.length > 1) {
      return oldValue;
    }

    final now = DateTime.now();
    final gap = _lastKey == null
        ? 9999
        : now.difference(_lastKey!).inMilliseconds;
    _lastKey = now;

    // Fast char (scan) -> puro field clear (first digit soho, kichu thakbe na).
    if (gap < fastGapMs) {
      _lastKey = null;
      return const TextEditingValue(text: '');
    }

    // Slow char (manual) -> allow.
    return newValue;
  }
}


/// Manual field e 15+ DIGIT dhukle = scan (card). Field clear kore,
/// digits gula onScanned callback e pathay (card field e boshanor jonno).
class ScanRedirectFormatter extends TextInputFormatter {
  final int threshold;
  final void Function(String digits) onScanned;

  ScanRedirectFormatter({this.threshold = 15, required this.onScanned});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sudhu DIGIT count (name er alphabet count hobe na)
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= threshold) {
      // 15+ digit = scan -> card e pathaই, ei field khali
      onScanned(digits);
      return const TextEditingValue(text: '');
    }
    return newValue;
  }
}