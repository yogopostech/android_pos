// ignore_for_file: prefer_final_fields, unused_element, deprecated_member_use

/// Ingenico Tetra TSI — Base Dialog Widget
///
/// Shared UI: spinner → success/error animation → status text → log area.
/// Used by purchase, void, and refund dialogs.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../providers/elavon_provider.dart';

class ElavonBaseDialog extends ConsumerStatefulWidget {
  /// Called once when dialog opens. Must call the provider method
  /// (purchase/void/refund) and return the result.
  final Future<void> Function(WidgetRef ref) onExecute;

  /// Dialog title shown only in logs header
  final String title;

  const ElavonBaseDialog({
    super.key,
    required this.onExecute,
    this.title = 'Payment',
  });

  @override
  ConsumerState<ElavonBaseDialog> createState() => _ElavonBaseDialogState();
}

class _ElavonBaseDialogState extends ConsumerState<ElavonBaseDialog> {
  bool _showLogs = false;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onExecute(ref);
    });
  }

  void _close() => Navigator.pop(context);

  void _copyLogs() {
    final logs = ref.read(elavonPaymentProvider).logs;
    Clipboard.setData(ClipboardData(text: logs.join('\n')));
    PopupDialog.showSuccessDialog('Logs copied');
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(elavonPaymentProvider);
    final theme = Theme.of(context);
    const double size = 250;
    final isDone = !state.isBusy && state.phase != ElavonPhase.idle;

    // Auto-scroll
    if (_showLogs && state.logs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Center(
      child: SizedBox(
        width: 450,
        child: Material(
          elevation: 3,
          shadowColor: ConfigController.to.isLightTheme
              ? Colors.black12
              : const Color.fromARGB(255, 77, 76, 76),
          color: ConfigController.to.isLightTheme
              ? theme.canvasColor
              : StaticColors.cartColor,
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Close ──
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.topRight,
                  child: isDone
                      ? IconButton(
                          onPressed: _close,
                          icon: const Icon(Icons.close),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // ── Icon ──
              if (state.phase == ElavonPhase.approved)
                SizedBox(
                  width: size,
                  height: size,
                  child: Lottie.asset(
                    'assets/animations/success.json',
                    repeat: false,
                  ),
                ),
              if (state.phase == ElavonPhase.declined ||
                  state.phase == ElavonPhase.error)
                SizedBox(
                  width: size,
                  height: size,
                  child: Lottie.asset(
                    'assets/animations/error_3.json',
                    repeat: false,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(const [
                          '**',
                        ], value: StaticColors.redColor),
                      ],
                    ),
                  ),
                ),
              if (state.isBusy || state.phase == ElavonPhase.idle)
                SizedBox(
                  width: size,
                  height: size,
                  child: SpinKitFadingCircle(
                    color: ConfigController.to.isLightTheme
                        ? Colors.grey
                        : Colors.white,
                    size: size - 40,
                  ),
                ),

              // ── Status text ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  (state.message.isEmpty
                          ? _phaseLabel(state.phase)
                          : state.message)
                      .toUpperCase(),
                  style: theme.textTheme.headlineMedium,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // ── Log toggle ──
              // InkWell(
              //   onTap: () => setState(() => _showLogs = !_showLogs),
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 4,
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(
              //           _showLogs ? Icons.expand_less : Icons.expand_more,
              //           size: 18,
              //           color: Colors.grey,
              //         ),
              //         const SizedBox(width: 4),
              //         Text(
              //           _showLogs
              //               ? 'Hide Logs'
              //               : 'Show Logs (${state.logs.length})',
              //           style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              //         ),
              //         const Spacer(),
              //         if (_showLogs && state.logs.isNotEmpty)
              //           GestureDetector(
              //             onTap: _copyLogs,
              //             child: Icon(
              //               Icons.copy,
              //               size: 16,
              //               color: Colors.grey[500],
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),

              // // ── Logs ──
              // if (_showLogs)
              //   Container(
              //     height: 220,
              //     margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              //     padding: const EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFF1E1E1E),
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     child: state.logs.isEmpty
              //         ? Center(
              //             child: Text(
              //               'Logs will appear here',
              //               style: TextStyle(
              //                 color: Colors.grey[600],
              //                 fontSize: 12,
              //               ),
              //             ),
              //           )
              //         : ListView.builder(
              //             controller: _scrollCtrl,
              //             itemCount: state.logs.length,
              //             itemBuilder: (_, i) {
              //               final line = state.logs[i];
              //               return Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 1),
              //                 child: Text(
              //                   line,
              //                   style: TextStyle(
              //                     fontFamily: 'monospace',
              //                     fontSize: 11,
              //                     height: 1.4,
              //                     color: Color(elavonLogColor(line)),
              //                   ),
              //                 ),
              //               );
              //             },
              //           ),
              //   ),
              if (!_showLogs) const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseLabel(ElavonPhase phase) => switch (phase) {
    ElavonPhase.idle => 'Ready',
    ElavonPhase.connecting => 'Connecting to terminal',
    ElavonPhase.sending => 'Processing',
    ElavonPhase.waitingForCard => 'Processing',
    ElavonPhase.processing => 'Processing',
    ElavonPhase.approved => 'Approved',
    ElavonPhase.declined => 'Declined',
    ElavonPhase.error => 'Error',
  };
}
