
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

Future<void> showGiftCardResultDialog(
  BuildContext context, {
  required bool success,
  required String message,
}) {
  return showDialog(
    context: context,
    // barrierDismissible: success,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => _GiftCardResultDialog(success: success, message: message),
  );
}

class _GiftCardResultDialog extends StatelessWidget {
  const _GiftCardResultDialog({required this.success, required this.message});

  final bool success;
  final String message;

  static const Color _errorRed = Color(0xffE53935);

  String _sentenceCase(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return success ? _buildSuccess(context) : _buildError(context);
  }

  // ---- SUCCESS (unchanged) ----
  Widget _buildSuccess(BuildContext context) {
    final Color accent = StaticColors.greenColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760),
        child: Container(
          padding: EdgeInsets.fromLTRB(48, 20, 48, 30),
          decoration: BoxDecoration(
            color: StaticColors.blackLightColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xff4A4A4A), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36),
              Text(
                _sentenceCase(message),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 44),
              SizedBox(
                width: 240,
                height: 84,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- ERROR (close button fixed to top-right corner) ----
  Widget _buildError(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 44),
          decoration: BoxDecoration(
            color: StaticColors.blackLightColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xff4A4A4A), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Top-right close (X) — exact corner ----
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero, // ← default padding remove
                  constraints: const BoxConstraints(), // ← default size remove
                  splashRadius: 20, // ← ripple size control
                  icon: Icon(Icons.close, color: Colors.white, size: 45),
                ),
              ),
              SizedBox(height: 8),

              // ---- White "Error !" badge ----
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: StaticColors.redColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 35),

              // ---- Message ----
              Text(
                _sentenceCase(message),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
