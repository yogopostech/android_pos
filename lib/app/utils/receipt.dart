// ignore_for_file: unused_field, prefer_initializing_formals

import 'dart:typed_data';
import 'dart:math' as math;

import 'package:yogo_pos/app/services/base/preferences.dart';

/// Universal Thermal Receipt Builder
/// Supports both ESC/POS and Star printers with automatic command translation
class Receipt {
  final List<int> _commands = [];
  final int width;
  final PrinterType printerType;

  // Current state tracking
  bool _isPageMode = false;
  int _currentCodePage = 0;

  // Dirty-state tracking — only send commands when state actually changes
  Align _dirtyAlign = Align.left;
  FontType _dirtyFont = FontType.fontA;
  int _dirtySize = 1;
  FontWeight _dirtyWeight = FontWeight.normal;
  TextDecoration _dirtyDecor = TextDecoration.none;
  bool _dirtyInvert = false;

  Receipt({this.width = 48, PrinterType? printerType})
    : printerType = printerType ?? Preferences.printerType;

  Uint8List get bytes => Uint8List.fromList(_commands);

  void _initialize() {
    _commands.addAll([0x1B, 0x40]); // ESC @ - Initialize printer
    if (printerType == PrinterType.star) {
      _commands.addAll([0x1B, 0x1D, 0x61, 0x01]); // Select Star Line Mode
    }
    // Reset dirty state to match printer defaults
    _dirtyAlign = Align.left;
    _dirtyFont = FontType.fontA;
    _dirtySize = 1;
    _dirtyWeight = FontWeight.normal;
    _dirtyDecor = TextDecoration.none;
    _dirtyInvert = false;
  }

  /// Font B character width ratio: Font A is 12 dots, Font B is 9 dots
  /// So Font B fits 4/3 as many characters in the same dot width.
  /// Using integer arithmetic (× 4 ~/ 3) avoids floating-point drift.
  int _fontBWidth(int fontAWidth) => fontAWidth * 4 ~/ 3;

  // ============================================================
  // TEXT FORMATTING
  // ============================================================

  /// Print text with comprehensive formatting options
  Receipt text(
    String text, {
    Align align = Align.left,
    int fontSize = 1,
    FontType fontType = FontType.fontA,
    FontWeight fontWeight = FontWeight.normal,
    TextDecoration decoration = TextDecoration.none,
    bool inverted = false,
    CharacterSet charset = CharacterSet.usa,
    int maxLines = 999,
    TextOverflow overflow = TextOverflow.truncate,
    int lMargin = 0,
    int rMargin = 0,
  }) {
    _setAlign(align);
    _setFontType(fontType);
    _setFontSize(fontSize);
    _setFontWeight(fontWeight);
    _setDecoration(decoration);
    _setInverted(inverted);

    // Font B is narrower, so more chars fit per line
    final baseWidth = fontType == FontType.fontB ? _fontBWidth(width) : width;
    final effectiveWidth = (baseWidth ~/ fontSize) - lMargin - rMargin;
    final wrappedLines = _wrapText(text, effectiveWidth);

    List<String> finalLines;
    if (wrappedLines.length > maxLines) {
      finalLines = wrappedLines.sublist(0, maxLines);
      if (overflow == TextOverflow.ellipsis && finalLines.isNotEmpty) {
        final lastLine = finalLines.last;
        if (lastLine.length >= 3) {
          finalLines[finalLines.length - 1] =
              '${lastLine.substring(0, lastLine.length - 3)}...';
        }
      }
    } else {
      finalLines = wrappedLines;
    }

    final leftPad = ' ' * lMargin;
    final rightPad = ' ' * rMargin;

    for (var line in finalLines) {
      _commands.addAll('$leftPad$line$rightPad'.codeUnits);
      _commands.add(0x0A);
    }

    _resetStyles();
    return this;
  }

  List<String> _wrapText(String text, int maxWidth) {
    final lines = <String>[];
    final paragraphs = text.split('\n');

    for (var paragraph in paragraphs) {
      if (paragraph.isEmpty) {
        lines.add('');
        continue;
      }

      final words = paragraph.split(' ');
      String currentLine = '';

      for (var word in words) {
        if (word.length > maxWidth) {
          if (currentLine.isNotEmpty) {
            lines.add(currentLine.trim());
            currentLine = '';
          }
          for (int i = 0; i < word.length; i += maxWidth) {
            final end = (i + maxWidth < word.length)
                ? i + maxWidth
                : word.length;
            lines.add(word.substring(i, end));
          }
          continue;
        }

        final testLine = currentLine.isEmpty ? word : '$currentLine $word';
        if (testLine.length <= maxWidth) {
          currentLine = testLine;
        } else {
          if (currentLine.isNotEmpty) {
            lines.add(currentLine);
          }
          currentLine = word;
        }
      }

      if (currentLine.isNotEmpty) {
        lines.add(currentLine);
      }
    }

    return lines;
  }

  // ============================================================
  // ROW AND COLUMN METHODS
  // ============================================================

  /// Two-column row
  Receipt row({
    required String left,
    required String right,
    int fontSize = 1,
    FontType fontType = FontType.fontA,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    _setFontType(fontType);
    _setFontSize(fontSize);
    _setFontWeight(fontWeight);

    final baseWidth = fontType == FontType.fontB ? _fontBWidth(width) : width;
    final effectiveWidth = baseWidth ~/ fontSize;
    final space = effectiveWidth - left.length - right.length;

    if (space > 0) {
      _commands.addAll(left.codeUnits);
      _commands.addAll((' ' * space).codeUnits);
      _commands.addAll(right.codeUnits);
    } else {
      final halfWidth = effectiveWidth ~/ 2;
      _commands.addAll(
        left.substring(0, math.min(left.length, halfWidth)).codeUnits,
      );
      _commands.addAll(
        right.substring(0, math.min(right.length, halfWidth)).codeUnits,
      );
    }

    _commands.add(0x0A);
    _resetStyles();
    return this;
  }

  /// Flexible multi-column row
  Receipt flexRow({required List<Col> children}) {
    int fixedTotal = 0;
    int flexCount = 0;

    for (var col in children) {
      if (col.width != null) {
        fixedTotal += col.width!;
      } else {
        flexCount++;
      }
    }

    final flexWidth = flexCount > 0 ? (width - fixedTotal) ~/ flexCount : 0;

    final columnLines = <List<String>>[];
    int maxLines = 0;

    for (var col in children) {
      final colWidth = col.width ?? flexWidth;
      final baseColWidth = col.fontType == FontType.fontB
          ? _fontBWidth(colWidth)
          : colWidth;
      final effectiveColWidth = baseColWidth ~/ col.fontSize;
      var lines = _wrapText(col.text, effectiveColWidth);

      if (lines.length > col.maxLines) {
        lines = lines.sublist(0, col.maxLines);
        if (col.overflow == TextOverflow.ellipsis && lines.isNotEmpty) {
          final lastLine = lines.last;
          if (lastLine.length >= 3) {
            lines[lines.length - 1] =
                '${lastLine.substring(0, lastLine.length - 3)}...';
          }
        }
      }

      columnLines.add(lines);
      if (lines.length > maxLines) {
        maxLines = lines.length;
      }
    }

    for (int lineIndex = 0; lineIndex < maxLines; lineIndex++) {
      for (int colIndex = 0; colIndex < children.length; colIndex++) {
        final col = children[colIndex];
        final colWidth = col.width ?? flexWidth;
        final lines = columnLines[colIndex];

        _setFontType(col.fontType);
        _setFontSize(col.fontSize);
        _setFontWeight(col.fontWeight);
        _setDecoration(col.decoration);
        _setInverted(col.inverted);

        final lineText = lineIndex < lines.length ? lines[lineIndex] : '';
        final baseColWidth = col.fontType == FontType.fontB
            ? _fontBWidth(colWidth)
            : colWidth;
        final effectiveColWidth = baseColWidth ~/ col.fontSize;
        final text = _formatColumn(
          lineText,
          effectiveColWidth,
          col.align,
          inverted: col.inverted,
        );
        _commands.addAll(text.codeUnits);

        _resetStyles();
      }
      _commands.add(0x0A);
    }

    return this;
  }

  String _formatColumn(
    String text,
    int colWidth,
    Align align, {
    bool inverted = false,
  }) {
    if (inverted) {
      text = ' $text ';
    }

    if (text.length >= colWidth) {
      return text.substring(0, colWidth);
    }

    switch (align) {
      case Align.left:
        return text.padRight(colWidth);
      case Align.center:
        final leftPad = (colWidth - text.length) ~/ 2;
        final rightPad = colWidth - text.length - leftPad;
        return ' ' * leftPad + text + ' ' * rightPad;
      case Align.right:
        return text.padLeft(colWidth);
    }
  }

  /// Item row (Qty, Name, Price)
  Receipt item({
    required String qty,
    required String name,
    required String price,
    int fontSize = 1,
    FontType fontType = FontType.fontA,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    _setFontType(fontType);
    _setFontSize(fontSize);
    _setFontWeight(fontWeight);

    final baseWidth = fontType == FontType.fontB ? _fontBWidth(width) : width;
    final effectiveWidth = baseWidth ~/ fontSize;

    final qtyWidth = 5;
    final priceWidth = 10;
    final nameWidth = effectiveWidth - qtyWidth - priceWidth;

    final qtyPart = qty.padRight(qtyWidth);
    final namePart = name.length > nameWidth
        ? name.substring(0, nameWidth)
        : name.padRight(nameWidth);
    final pricePart = price.padLeft(priceWidth);

    _commands.addAll(qtyPart.codeUnits);
    _commands.addAll(namePart.codeUnits);
    _commands.addAll(pricePart.codeUnits);
    _commands.add(0x0A);

    _resetStyles();
    return this;
  }

  /// Money row with currency formatting
  Receipt money({
    required String label,
    required double amount,
    String currency = '\$',
    int fontSize = 1,
    FontType fontType = FontType.fontA,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return row(
      left: label,
      right: '$currency${amount.toStringAsFixed(2)}',
      fontSize: fontSize,
      fontType: fontType,
      fontWeight: fontWeight,
    );
  }

  // ============================================================
  // SEPARATORS AND LINES
  // ============================================================

  Receipt separator({String char = '='}) {
    _commands.addAll((char * width).codeUnits);
    _commands.add(0x0A);
    return this;
  }

  Receipt dotted() => separator(char: '.');
  Receipt dashed() => separator(char: '-');
  Receipt divider() => separator(char: '_');
  Receipt doubleLine() => separator(char: '=');
  Receipt stars() => separator(char: '*');
  Receipt hashes() => separator(char: '#');

  Receipt pattern(String pattern) {
    final repeated = (pattern * (width ~/ pattern.length + 1)).substring(
      0,
      width,
    );
    _commands.addAll(repeated.codeUnits);
    _commands.add(0x0A);
    return this;
  }

  /// Draw a box around text
  Receipt box(String text, {BoxStyle style = BoxStyle.single}) {
    final chars = _getBoxChars(style);
    final innerWidth = width - 4;
    final lines = _wrapText(text, innerWidth);

    // Top border
    _commands.addAll(
      (chars['tl']! + chars['h']! * (width - 2) + chars['tr']!).codeUnits,
    );
    _commands.add(0x0A);

    // Content lines
    for (var line in lines) {
      final padded = line.padRight(innerWidth);
      _commands.addAll(('${chars['v']!} $padded ${chars['v']!}').codeUnits);
      _commands.add(0x0A);
    }

    // Bottom border
    _commands.addAll(
      (chars['bl']! + chars['h']! * (width - 2) + chars['br']!).codeUnits,
    );
    _commands.add(0x0A);

    return this;
  }

  Map<String, String> _getBoxChars(BoxStyle style) {
    switch (style) {
      case BoxStyle.single:
        return {'tl': '┌', 'tr': '┐', 'bl': '└', 'br': '┘', 'h': '─', 'v': '│'};
      case BoxStyle.double:
        return {'tl': '╔', 'tr': '╗', 'bl': '╚', 'br': '╝', 'h': '═', 'v': '║'};
      case BoxStyle.rounded:
        return {'tl': '╭', 'tr': '╮', 'bl': '╰', 'br': '╯', 'h': '─', 'v': '│'};
      case BoxStyle.bold:
        return {'tl': '┏', 'tr': '┓', 'bl': '┗', 'br': '┛', 'h': '━', 'v': '┃'};
      case BoxStyle.ascii:
        return {'tl': '+', 'tr': '+', 'bl': '+', 'br': '+', 'h': '-', 'v': '|'};
    }
  }

  // ============================================================
  // SPACING CONTROLS
  // ============================================================

  Receipt space([int lines = 1]) {
    for (int i = 0; i < lines; i++) {
      _commands.add(0x0A);
    }
    return this;
  }

  Receipt halfSpace() {
    _commands.add(0x0A);
    return this;
  }

  /// Minimal spacing with precise dot control
  Receipt microSpace([int dots = 15]) {
    _commands.addAll([0x1B, 0x4A, dots.clamp(5, 255)]); // ESC J n - feed n dots
    return this;
  }

  /// Quarter line spacing
  Receipt quarterSpace() {
    _commands.addAll([0x1B, 0x4A, 0x0A]); // Feed 10 dots
    return this;
  }

  /// Tiny spacing with line feed
  Receipt tinySpace() {
    if (printerType == PrinterType.star) {
      _commands.addAll([0x1B, 0x7A, 0x01]); // Set 1 dot line spacing
      _commands.add(0x0A);
      _commands.addAll([0x1B, 0x32]); // Reset to default
    } else {
      _commands.addAll([0x1B, 0x33, 0x08]); // Set line spacing to 8 dots
      _commands.add(0x0A);
      _commands.addAll([0x1B, 0x32]); // Reset to default line spacing
    }
    return this;
  }

  /// Custom line spacing (in dots)
  Receipt setLineSpacing(int dots) {
    _commands.addAll([0x1B, 0x33, dots.clamp(0, 255)]); // ESC 3 n
    return this;
  }

  /// Reset to default line spacing
  Receipt resetLineSpacing() {
    _commands.addAll([0x1B, 0x32]); // ESC 2
    return this;
  }

  Receipt emptyLine() => space(1);
  Receipt br() => space(1);

  // ============================================================
  // TEXT STYLE SHORTCUTS
  // ============================================================

  Receipt header(
    String text, {
    int fontSize = 2,
    FontType fontType = FontType.fontA,
  }) {
    return this.text(
      text,
      align: Align.center,
      fontSize: fontSize,
      fontType: fontType,
      fontWeight: FontWeight.bold,
    );
  }

  Receipt title(String text, {FontType fontType = FontType.fontA}) {
    return this.text(
      text,
      align: Align.center,
      fontWeight: FontWeight.bold,
      fontType: fontType,
    );
  }

  Receipt center(
    String text, {
    int fontSize = 1,
    FontType fontType = FontType.fontA,
  }) {
    return this.text(
      text,
      align: Align.center,
      fontSize: fontSize,
      fontType: fontType,
    );
  }

  Receipt bold(
    String text, {
    Align align = Align.left,
    FontType fontType = FontType.fontA,
  }) {
    return this.text(
      text,
      fontWeight: FontWeight.bold,
      align: align,
      fontType: fontType,
    );
  }

  Receipt underlined(
    String text, {
    Align align = Align.left,
    FontType fontType = FontType.fontA,
  }) {
    return this.text(
      text,
      decoration: TextDecoration.underline,
      align: align,
      fontType: fontType,
    );
  }

  Receipt large(
    String text, {
    Align align = Align.left,
    int fontSize = 2,
    FontType fontType = FontType.fontA,
  }) {
    return this.text(
      text,
      fontSize: fontSize,
      align: align,
      fontType: fontType,
    );
  }

  /// Medium-sized text using Font B × 2 (between normal and large)
  Receipt medium(
    String text, {
    Align align = Align.left,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return this.text(
      text,
      fontSize: 2,
      fontType: FontType.fontB,
      align: align,
      fontWeight: fontWeight,
    );
  }

  Receipt line(String text) => this.text(text);
  Receipt right(
    String text, {
    int fontSize = 1,
    FontType fontType = FontType.fontA,
  }) => this.text(
    text,
    align: Align.right,
    fontSize: fontSize,
    fontType: fontType,
  );
  Receipt left(
    String text, {
    int fontSize = 1,
    FontType fontType = FontType.fontA,
  }) => this.text(
    text,
    align: Align.left,
    fontSize: fontSize,
    fontType: fontType,
  );

  Receipt inverted(
    String text, {
    Align align = Align.left,
    int fontSize = 1,
    FontType fontType = FontType.fontA,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return this.text(
      text,
      align: align,
      fontSize: fontSize,
      fontType: fontType,
      fontWeight: fontWeight,
      inverted: true,
    );
  }

  // ============================================================
  // PAPER CONTROL
  // ============================================================

  /// Feed paper n lines
  Receipt feed([int lines = 1]) {
    for (int i = 0; i < lines; i++) {
      _commands.add(0x0A);
    }
    return this;
  }

  /// Feed n dots precisely
  Receipt feedDots(int dots) {
    _commands.addAll([0x1B, 0x4A, dots.clamp(0, 255)]); // ESC J n
    return this;
  }

  /// Reverse feed (if supported)
  Receipt reverseFeed(int dots) {
    _commands.addAll([0x1B, 0x4B, dots.clamp(0, 255)]); // ESC K n
    return this;
  }

  /// Full cut with feed
  Receipt cut({int feedLines = 3}) {
    for (int i = 0; i < feedLines; i++) {
      _commands.add(0x0A);
    }
    if (printerType == PrinterType.star) {
      _commands.addAll([0x1B, 0x64, 0x02]); // ESC d 2
    } else {
      _commands.addAll([0x1D, 0x56, 0x00]); // GS V 0
    }
    return this;
  }

  // Receipt cut({int feedLines = 3}) {
  //   if (printerType == PrinterType.star) {
  //     // Guarantee the last content clears the blade (min 5 lines ~= 19mm).
  //     final lines = feedLines < 5 ? 5 : feedLines;
  //     for (int i = 0; i < lines; i++) {
  //       _commands.add(0x0A);
  //     }
  //     // ESC d 3 = feed-to-cut + partial cut. Widely supported on old Star.
  //     // Chaile full cut er jonno 0x02 use koro (ESC d 2).
  //     _commands.addAll([0x1B, 0x64, 0x03]);
  //   } else {
  //     for (int i = 0; i < feedLines; i++) {
  //       _commands.add(0x0A);
  //     }
  //     // GS V 66 n = feed n dots + full cut (GS V 0 er cheye reliable).
  //     _commands.addAll([0x1D, 0x56, 0x42, 0x00]);
  //   }
  //   return this;
  // }

  /// Partial cut with feed
  Receipt partialCut({int feedLines = 3}) {
    for (int i = 0; i < feedLines; i++) {
      _commands.add(0x0A);
    }
    if (printerType == PrinterType.star) {
      _commands.addAll([0x1B, 0x64, 0x03]); // ESC d 3
    } else {
      _commands.addAll([0x1D, 0x56, 0x01]); // GS V 1
    }
    return this;
  }

  /// Cut without feed
  Receipt cutNow({bool partial = false}) {
    if (printerType == PrinterType.star) {
      _commands.addAll([0x1B, 0x64, partial ? 0x03 : 0x02]);
    } else {
      _commands.addAll([0x1D, 0x56, partial ? 0x01 : 0x00]);
    }
    return this;
  }

  Receipt cutPaper({int feedLines = 3}) => cut(feedLines: feedLines);

  // ============================================================
  // HARDWARE CONTROLS
  // ============================================================

  /// Buzzer/Beeper control
  Receipt beep({int count = 1, int duration = 3}) {
    if (printerType == PrinterType.star) {
      for (int i = 0; i < count.clamp(1, 10); i++) {
        _commands.addAll([0x1B, 0x07]); // ESC BEL
        if (i < count - 1) {
          for (int j = 0; j < duration; j++) {
            _commands.add(0x00);
          }
        }
      }
    } else {
      final beepCount = count.clamp(1, 10);
      final beepDuration = duration.clamp(1, 9);
      _commands.addAll([0x1B, 0x42, beepCount, beepDuration]);
    }
    return this;
  }

  Receipt beepOnce() => beep(count: 1, duration: 3);
  Receipt beepSuccess() => beep(count: 2, duration: 2);
  Receipt beepError() => beep(count: 1, duration: 9);
  Receipt beepAlert() => beep(count: 3, duration: 5);

  /// Buzzer pattern (Star specific)
  Receipt buzzer({BuzzerPattern pattern = BuzzerPattern.standard}) {
    if (printerType != PrinterType.star) {
      return beep();
    }

    switch (pattern) {
      case BuzzerPattern.standard:
        _commands.addAll([0x07]);
        break;
      case BuzzerPattern.twoBeeps:
        _commands.addAll([0x07]);
        _commands.addAll(List.filled(10, 0x00));
        _commands.addAll([0x07]);
        break;
      case BuzzerPattern.threeBeeps:
        _commands.addAll([0x07]);
        _commands.addAll(List.filled(10, 0x00));
        _commands.addAll([0x07]);
        _commands.addAll(List.filled(10, 0x00));
        _commands.addAll([0x07]);
        break;
    }
    return this;
  }

  /// Cash drawer control
  Receipt drawer({DrawerPin pin = DrawerPin.pin2}) {
    if (printerType == PrinterType.star) {
      final pinValue = pin == DrawerPin.pin2 ? 0x00 : 0x01;
      _commands.addAll([0x07]);
      _commands.addAll([0x1B, 0x14, pinValue, 0x01, 0x01]);
    } else {
      _commands.addAll([0x1B, 0x70, 0x00, 0x19, 0xFA]);
    }
    return this;
  }

  Receipt openDrawer({DrawerPin pin = DrawerPin.pin2}) => drawer(pin: pin);
  Receipt cashDrawer() => drawer();

  /// Pulse drawer with timing control
  Receipt pulseDrawer({
    int onTime = 100,
    int offTime = 200,
    DrawerPin pin = DrawerPin.pin2,
  }) {
    if (printerType == PrinterType.star) {
      final pinValue = pin == DrawerPin.pin2 ? 0x00 : 0x01;
      final t1 = (onTime / 2).clamp(1, 255).toInt();
      final t2 = (offTime / 2).clamp(1, 255).toInt();
      _commands.addAll([0x1B, 0x14, pinValue, t1, t2]);
    } else {
      _commands.addAll([0x1B, 0x70, 0x00, onTime.clamp(1, 255), 0xFA]);
    }
    return this;
  }

  // ============================================================
  // BARCODES - COMPREHENSIVE SUPPORT
  // ============================================================

  /// QR Code with full options
  Receipt qr(
    String data, {
    Align align = Align.center,
    int size = 6,
    QRErrorCorrection errorCorrection = QRErrorCorrection.levelM,
  }) {
    _setAlign(align);

    if (printerType == PrinterType.star) {
      // Star QR Code commands
      _commands.addAll([0x1B, 0x1D, 0x79, 0x53, 0x30, size.clamp(1, 8)]);
      _commands.addAll([0x1B, 0x1D, 0x79, 0x44, 0x31, 0x00]);

      final ecLevel = {
        QRErrorCorrection.levelL: 0x00,
        QRErrorCorrection.levelM: 0x01,
        QRErrorCorrection.levelQ: 0x02,
        QRErrorCorrection.levelH: 0x03,
      }[errorCorrection]!;
      _commands.addAll([0x1B, 0x1D, 0x79, 0x45, ecLevel, 0x00]);

      final dataBytes = data.codeUnits;
      final len = dataBytes.length;
      final pL = len % 256;
      final pH = len ~/ 256;
      _commands.addAll([0x1B, 0x1D, 0x79, 0x44, 0x30, 0x00, pL, pH]);
      _commands.addAll(dataBytes);
      _commands.addAll([0x1B, 0x1D, 0x79, 0x50]);
    } else {
      // ESC/POS QR Code commands
      _commands.addAll([0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00]);
      _commands.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, size]);

      final dataLength = data.length + 3;
      final pL = dataLength % 256;
      final pH = dataLength ~/ 256;
      _commands.addAll([0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30]);
      _commands.addAll(data.codeUnits);
      _commands.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
    }

    _setAlign(Align.left);
    return this;
  }

  Receipt qrCode(String data, {Align align = Align.center, int size = 6}) {
    return qr(data, align: align, size: size);
  }

  /// Generic barcode method
  Receipt barcode(
    String data, {
    BarcodeType type = BarcodeType.code39,
    Align align = Align.center,
    int height = 80,
    BarcodeTextPosition textPosition = BarcodeTextPosition.below,
    int width = 2,
  }) {
    _setAlign(align);

    // Set barcode height
    _commands.addAll([0x1D, 0x68, height.clamp(1, 255)]);

    // Set text position
    final textPos = {
      BarcodeTextPosition.none: 0x00,
      BarcodeTextPosition.above: 0x01,
      BarcodeTextPosition.below: 0x02,
      BarcodeTextPosition.both: 0x03,
    }[textPosition]!;
    _commands.addAll([0x1D, 0x48, textPos]);

    // Set width
    _commands.addAll([0x1D, 0x77, width.clamp(2, 6)]);

    // Select barcode type and print
    final typeCode = _getBarcodeTypeCode(type);
    _commands.addAll([0x1D, 0x6B, typeCode, data.length]);
    _commands.addAll(data.codeUnits);
    _commands.add(0x0A);

    _setAlign(Align.left);
    return this;
  }

  int _getBarcodeTypeCode(BarcodeType type) {
    switch (type) {
      case BarcodeType.upca:
        return 0x00;
      case BarcodeType.upce:
        return 0x01;
      case BarcodeType.ean13:
        return 0x02;
      case BarcodeType.ean8:
        return 0x03;
      case BarcodeType.code39:
        return 0x04;
      case BarcodeType.itf:
        return 0x05;
      case BarcodeType.codabar:
        return 0x06;
      case BarcodeType.code93:
        return 0x48;
      case BarcodeType.code128:
        return 0x49;
    }
  }

  // Specific barcode shortcuts
  Receipt barcodeEAN13(String data, {Align align = Align.center}) =>
      barcode(data, type: BarcodeType.ean13, align: align);

  Receipt barcodeCODE39(String data, {Align align = Align.center}) =>
      barcode(data, type: BarcodeType.code39, align: align);

  Receipt barcodeCODE128(String data, {Align align = Align.center}) =>
      barcode(data, type: BarcodeType.code128, align: align);

  Receipt barcodeUPCA(String data, {Align align = Align.center}) =>
      barcode(data, type: BarcodeType.upca, align: align);

  // ============================================================
  // GRAPHICS AND IMAGES
  // ============================================================

  /// Print logo from NV memory
  Receipt logo({int logoNumber = 1, Align align = Align.center}) {
    _setAlign(align);
    _commands.addAll([0x1C, 0x70, logoNumber.clamp(1, 255), 0x00]);
    _setAlign(Align.left);
    return this;
  }

  /// Print raster bitmap image
  Receipt rasterImage({
    required Uint8List imageBytes,
    required int widthBytes,
    required int heightPixels,
    Align align = Align.center,
    RasterMode mode = RasterMode.normal,
  }) {
    _setAlign(align);

    final modeValue = {
      RasterMode.normal: 0x00,
      RasterMode.doubleWidth: 0x01,
      RasterMode.doubleHeight: 0x02,
      RasterMode.quadruple: 0x03,
    }[mode]!;

    _commands.addAll([0x1D, 0x76, 0x30, modeValue]);
    _commands.addAll([widthBytes % 256, widthBytes ~/ 256]);
    _commands.addAll([heightPixels % 256, heightPixels ~/ 256]);
    _commands.addAll(imageBytes);

    _setAlign(Align.left);
    return this;
  }

  /// Print downloaded bit image (NV Graphics)
  Receipt downloadedImage({
    int imageNumber = 1,
    Align align = Align.center,
    ImageMode mode = ImageMode.normal,
  }) {
    _setAlign(align);

    final modeValue = {
      ImageMode.normal: 0x00,
      ImageMode.doubleWidth: 0x01,
      ImageMode.doubleHeight: 0x02,
      ImageMode.quadruple: 0x03,
    }[mode]!;

    _commands.addAll([0x1C, 0x70, imageNumber.clamp(1, 255), modeValue]);

    _setAlign(Align.left);
    return this;
  }

  // ============================================================
  // PAGE MODE (Advanced Layout) - Star Printers
  // ============================================================

  /// Enter page mode
  Receipt enterPageMode() {
    _commands.addAll([0x1B, 0x4C]); // ESC L - Page mode
    _isPageMode = true;
    return this;
  }

  /// Exit page mode (return to standard mode)
  Receipt exitPageMode() {
    _commands.addAll([0x1B, 0x53]); // ESC S - Standard mode
    _isPageMode = false;
    return this;
  }

  /// Set print area in page mode
  Receipt setPageArea({
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    _commands.addAll([
      0x1B,
      0x57,
      x % 256,
      x ~/ 256,
      y % 256,
      y ~/ 256,
      width % 256,
      width ~/ 256,
      height % 256,
      height ~/ 256,
    ]);
    return this;
  }

  /// Set print direction in page mode
  Receipt setPageDirection(PageDirection direction) {
    final dirValue = {
      PageDirection.leftToRight: 0x00,
      PageDirection.bottomToTop: 0x01,
      PageDirection.rightToLeft: 0x02,
      PageDirection.topToBottom: 0x03,
    }[direction]!;
    _commands.addAll([0x1B, 0x54, dirValue]);
    return this;
  }

  /// Set absolute vertical position in page mode
  Receipt setPageVerticalPosition(int position) {
    _commands.addAll([0x1D, 0x24, position % 256, position ~/ 256]);
    return this;
  }

  /// Print page (executes all page mode commands)
  Receipt printPage() {
    _commands.addAll([0x0C]);
    _isPageMode = false;
    return this;
  }

  // ============================================================
  // CHARACTER SETS AND CODE PAGES
  // ============================================================

  /// Select character set
  Receipt selectCharacterSet(CharacterSet charset) {
    final charsetValue = {
      CharacterSet.usa: 0x00,
      CharacterSet.france: 0x01,
      CharacterSet.germany: 0x02,
      CharacterSet.uk: 0x03,
      CharacterSet.denmark: 0x04,
      CharacterSet.sweden: 0x05,
      CharacterSet.italy: 0x06,
      CharacterSet.spain: 0x07,
      CharacterSet.japan: 0x08,
      CharacterSet.norway: 0x09,
      CharacterSet.denmark2: 0x0A,
    }[charset]!;
    _commands.addAll([0x1B, 0x52, charsetValue]);
    return this;
  }

  /// Select code page
  Receipt selectCodePage(CodePage codepage) {
    final pageValue = {
      CodePage.cp437: 0x00,
      CodePage.cp850: 0x02,
      CodePage.cp852: 0x05,
      CodePage.cp858: 0x13,
      CodePage.cp866: 0x11,
      CodePage.cp1252: 0x10,
      CodePage.cp932: 0x01,
    }[codepage]!;

    if (printerType == PrinterType.star) {
      _commands.addAll([0x1B, 0x1D, 0x74, pageValue]);
    } else {
      _commands.addAll([0x1B, 0x74, pageValue]);
    }
    _currentCodePage = pageValue;
    return this;
  }

  // ============================================================
  // TABLE HELPERS
  // ============================================================

  Receipt table({
    required List<Col> headers,
    required List<List<String>> rows,
    bool showBorders = false,
  }) {
    if (showBorders) {
      separator(char: '=');
    }

    final headerCols = headers
        .map(
          (h) => Col(
            text: h.text,
            width: h.width,
            align: h.align,
            fontSize: h.fontSize,
            fontType: h.fontType,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        )
        .toList();

    flexRow(children: headerCols);
    separator();

    for (var rowData in rows) {
      final rowCols = <Col>[];
      for (int i = 0; i < headers.length; i++) {
        final header = headers[i];
        final cellData = i < rowData.length ? rowData[i] : '';
        rowCols.add(
          Col(
            text: cellData,
            width: header.width,
            align: header.align,
            fontSize: header.fontSize,
            fontType: header.fontType,
          ),
        );
      }
      flexRow(children: rowCols);
    }

    if (showBorders) {
      separator(char: '=');
    }

    return this;
  }

  // ============================================================
  // ADVANCED FEATURES
  // ============================================================

  /// Set print density (darkness)
  Receipt setPrintDensity(int level) {
    _commands.addAll([0x1D, 0x7C, level.clamp(0, 8)]);
    return this;
  }

  /// Set print speed
  Receipt setPrintSpeed(int speed) {
    _commands.addAll([0x1D, 0x84, speed.clamp(0, 9)]);
    return this;
  }

  /// Enable/disable auto status back
  Receipt setAutoStatusBack(bool enabled) {
    _commands.addAll([0x1D, 0x61, enabled ? 0xFF : 0x00]);
    return this;
  }

  /// Request printer status
  Receipt requestStatus() {
    _commands.addAll([0x1B, 0x76]);
    return this;
  }

  /// Set upside-down printing
  Receipt setUpsideDown(bool enabled) {
    _commands.addAll([0x1B, 0x7B, enabled ? 0x01 : 0x00]);
    return this;
  }

  /// Set right-side character spacing
  Receipt setCharacterSpacing(int dots) {
    _commands.addAll([0x1B, 0x20, dots.clamp(0, 255)]);
    return this;
  }

  // ============================================================
  // RESET AND INIT
  // ============================================================

  Receipt init() {
    _commands.clear();
    _initialize();
    return this;
  }

  Receipt reset() => init();

  /// Clear buffer without reinitializing
  Receipt clearBuffer() {
    _commands.clear();
    return this;
  }

  // ============================================================
  // INTERNAL HELPER METHODS — DIRTY-STATE OPTIMIZED
  // ============================================================

  void _setAlign(Align align) {
    if (_dirtyAlign == align) return;
    _dirtyAlign = align;
    if (printerType == PrinterType.star) {
      final alignValue = {
        Align.left: 0x00,
        Align.center: 0x01,
        Align.right: 0x02,
      }[align]!;
      _commands.addAll([0x1B, 0x1D, 0x61, alignValue]);
    } else {
      final alignValue = {
        Align.left: 0x00,
        Align.center: 0x01,
        Align.right: 0x02,
      }[align]!;
      _commands.addAll([0x1B, 0x61, alignValue]);
    }
  }

  /// Select Font A (12×24) or Font B (9×17)
  void _setFontType(FontType fontType) {
    if (_dirtyFont == fontType) return;
    _dirtyFont = fontType;
    if (printerType == PrinterType.star) {
      // Star: ESC RS F n — 0x00 = Font A, 0x01 = Font B
      _commands.addAll([
        0x1B,
        0x1E,
        0x46,
        fontType == FontType.fontB ? 0x01 : 0x00,
      ]);
    } else {
      // ESC/POS: ESC M n — 0x00 = Font A, 0x01 = Font B
      _commands.addAll([0x1B, 0x4D, fontType == FontType.fontB ? 0x01 : 0x00]);
    }
  }

  void _setFontSize(int size) {
    if (_dirtySize == size) return;
    _dirtySize = size;
    if (printerType == PrinterType.star) {
      final s = size.clamp(1, 8) - 1;
      _commands.addAll([0x1B, 0x69, s, s]);
    } else {
      final s = size.clamp(1, 6) - 1;
      final value = (s << 4) | s;
      _commands.addAll([0x1D, 0x21, value]);
    }
  }

  void _setFontWeight(FontWeight weight) {
    if (_dirtyWeight == weight) return;
    _dirtyWeight = weight;
    if (printerType == PrinterType.star) {
      if (weight == FontWeight.bold) {
        _commands.addAll([0x1B, 0x45]);
      } else {
        _commands.addAll([0x1B, 0x46]);
      }
    } else {
      _commands.addAll([0x1B, 0x45, weight == FontWeight.bold ? 0x01 : 0x00]);
    }
  }

  void _setDecoration(TextDecoration decoration) {
    if (_dirtyDecor == decoration) return;
    _dirtyDecor = decoration;
    if (decoration == TextDecoration.underline) {
      _commands.addAll([0x1B, 0x2D, 0x01]);
    } else {
      _commands.addAll([0x1B, 0x2D, 0x00]);
    }
  }

  void _setInverted(bool enabled) {
    if (_dirtyInvert == enabled) return;
    _dirtyInvert = enabled;
    if (printerType == PrinterType.star) {
      if (enabled) {
        _commands.addAll([0x1B, 0x34]);
      } else {
        _commands.addAll([0x1B, 0x35]);
      }
    } else {
      _commands.addAll([0x1D, 0x42, enabled ? 0x01 : 0x00]);
    }
  }

  /// Only reset styles that were actually changed from defaults
  void _resetStyles() {
    if (_dirtyAlign != Align.left) {
      _dirtyAlign = Align.left;
      if (printerType == PrinterType.star) {
        _commands.addAll([0x1B, 0x1D, 0x61, 0x00]);
      } else {
        _commands.addAll([0x1B, 0x61, 0x00]);
      }
    }

    if (_dirtySize != 1) {
      _dirtySize = 1;
      if (printerType == PrinterType.star) {
        _commands.addAll([0x1B, 0x69, 0x00, 0x00]);
      } else {
        _commands.addAll([0x1D, 0x21, 0x00]);
      }
    }

    if (_dirtyWeight != FontWeight.normal) {
      _dirtyWeight = FontWeight.normal;
      if (printerType == PrinterType.star) {
        _commands.addAll([0x1B, 0x46]);
      } else {
        _commands.addAll([0x1B, 0x45, 0x00]);
      }
    }

    if (_dirtyDecor != TextDecoration.none) {
      _dirtyDecor = TextDecoration.none;
      _commands.addAll([0x1B, 0x2D, 0x00]);
    }

    if (_dirtyInvert) {
      _dirtyInvert = false;
      if (printerType == PrinterType.star) {
        _commands.addAll([0x1B, 0x35]);
      } else {
        _commands.addAll([0x1D, 0x42, 0x00]);
      }
    }

    if (_dirtyFont != FontType.fontA) {
      _dirtyFont = FontType.fontA;
      if (printerType == PrinterType.star) {
        _commands.addAll([0x1B, 0x1E, 0x46, 0x00]);
      } else {
        _commands.addAll([0x1B, 0x4D, 0x00]);
      }
    }
  }

  /// Add raw ESC/POS commands
  Receipt raw(List<int> commands) {
    _commands.addAll(commands);
    return this;
  }

  /// Add raw byte
  Receipt rawByte(int byte) {
    _commands.add(byte);
    return this;
  }
}

// ============================================================
// COLUMN CLASS
// ============================================================

class Col {
  final String text;
  final int? width;
  final Align align;
  final int fontSize;
  final FontType fontType;
  final FontWeight fontWeight;
  final TextDecoration decoration;
  final int maxLines;
  final TextOverflow overflow;
  final bool inverted;

  Col({
    required this.text,
    this.width,
    this.align = Align.left,
    this.fontSize = 1,
    this.fontType = FontType.fontA,
    this.fontWeight = FontWeight.normal,
    this.decoration = TextDecoration.none,
    this.maxLines = 999,
    this.overflow = TextOverflow.truncate,
    this.inverted = false,
  });

  Col.fixed(
    this.text, {
    required int width,
    this.align = Align.left,
    this.fontSize = 1,
    this.fontType = FontType.fontA,
    this.fontWeight = FontWeight.normal,
    this.decoration = TextDecoration.none,
    this.maxLines = 999,
    this.overflow = TextOverflow.truncate,
    this.inverted = false,
  }) : width = width;

  Col.flex(
    this.text, {
    this.align = Align.left,
    this.fontSize = 1,
    this.fontType = FontType.fontA,
    this.fontWeight = FontWeight.normal,
    this.decoration = TextDecoration.none,
    this.maxLines = 999,
    this.overflow = TextOverflow.truncate,
    this.inverted = false,
  }) : width = null;
}

// ============================================================
// ENUMS
// ============================================================

enum PrinterType {
  escpos('EPSON'),
  star('STAR');

  final String label;
  const PrinterType(this.label);
}

enum Align { left, center, right }

/// Font A (12×24 dots, default) or Font B (9×17 dots, smaller/narrower)
/// Use Font B × 2 for a "medium" size between normal and large
enum FontType {
  fontA, // 12×24 — standard, ~48 chars per line on 80mm paper
  fontB, // 9×17  — compact, ~64 chars per line on 80mm paper
}

enum FontWeight { normal, bold }

enum TextDecoration { none, underline }

enum TextOverflow { truncate, ellipsis, clip }

enum BoxStyle { single, double, rounded, bold, ascii }

enum BarcodeType {
  upca,
  upce,
  ean13,
  ean8,
  code39,
  itf,
  codabar,
  code93,
  code128,
}

enum QRErrorCorrection {
  levelL, // 7% recovery
  levelM, // 15% recovery
  levelQ, // 25% recovery
  levelH, // 30% recovery
}

enum BarcodeTextPosition { none, above, below, both }

enum RasterMode { normal, doubleWidth, doubleHeight, quadruple }

enum ImageMode { normal, doubleWidth, doubleHeight, quadruple }

enum PageDirection { leftToRight, bottomToTop, rightToLeft, topToBottom }

enum CharacterSet {
  usa,
  france,
  germany,
  uk,
  denmark,
  sweden,
  italy,
  spain,
  japan,
  norway,
  denmark2,
}

enum CodePage {
  cp437, // USA, Standard Europe
  cp850, // Multilingual
  cp852, // Latin 2
  cp858, // Euro
  cp866, // Cyrillic
  cp1252, // Windows Latin 1
  cp932, // Japanese
}

enum BuzzerPattern { standard, twoBeeps, threeBeeps }

enum DrawerPin {
  pin2('Pin 2'),
  pin5('Pin 5');

  final String label;
  const DrawerPin(this.label);
}
