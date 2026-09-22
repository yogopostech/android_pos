import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

Future<void> showGiftCardBalanceDialog(
  BuildContext context, {
  required int balanceCents,
  String currencySymbol = '\$',
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => _GiftCardBalanceDialog(
      balanceCents: balanceCents,
      currencySymbol: currencySymbol,
    ),
  );
}

class _GiftCardBalanceDialog extends StatelessWidget {
  const _GiftCardBalanceDialog({
    required this.balanceCents,
    required this.currencySymbol,
  });

  final int balanceCents;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final amount = (balanceCents / 100).toStringAsFixed(2);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          decoration: BoxDecoration(
            color: StaticColors.blackLightColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xff4A4A4A), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 22,
                  icon: const Icon(Icons.close, color: Colors.white, size: 40),
                ),
              ),
              const Text(
                'Gift Card Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '$currencySymbol$amount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: _btn(
                      label: 'Print',
                      icon: Icons.print,
                      bg: const Color(0xff1E63E9),
                      // TODO: print logic pore
                      onTap: () => Navigator.of(context).pop('print'),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _btn(
                      label: 'No Print',
                      icon: Icons.do_not_disturb,
                      bg: StaticColors.orangeColor,
                      onTap: () => Navigator.of(context).pop('no_print'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn({
    required String label,
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
