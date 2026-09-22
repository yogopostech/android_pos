import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/services/models/printer_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/network_printer.dart';
import 'package:yogo_pos/app/utils/receipt.dart' hide FontWeight,TextOverflow;
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class PrintUtils {
  static const int _defaultPort = 9100;

  /// Sends raw ESC/POS or Star bytes to a network printer.
  ///
  /// [printer] accepts any of:
  ///   * `192.168.1.50`            → port 9100
  ///   * `192.168.1.50:9101`       → explicit port
  ///   * an encoded [PrinterModel] (JSON, see [PrinterModel.encode])
  ///
  /// Returns `true` only when the bytes reached the printer. On failure the
  /// job is kept and the "Printer Not Connected" dialog lets the user retry
  /// it. This never waits for the dialog — callers get `false` immediately.
  Future<bool> directPrint({
    required Uint8List data,
    required String printer,
    String? docName,
    bool isShowMessage = false,
    bool showErrorDialog = true,
  }) async {
    try {
      await _send(data: data, printer: printer, docName: docName);
      if (isShowMessage) PopupDialog.showSuccessDialog('Print Sent');
      return true;
    } on PrinterException catch (e) {
      _onFailure(
        _FailedPrintJob(
          data: data,
          printer: printer,
          docName: docName,
          error: e,
        ),
        showErrorDialog: showErrorDialog,
      );
      return false;
    } catch (e, s) {
      kLogger.e('directPrint unexpected error', error: e, stackTrace: s);
      _onFailure(
        _FailedPrintJob(
          data: data,
          printer: printer,
          docName: docName,
          error: PrinterException(
            PrinterErrorType.unknown,
            'Unexpected print error',
            e,
          ),
        ),
        showErrorDialog: showErrorDialog,
      );
      return false;
    }
  }

  Future<bool> openDrawer() => _openDrawerWithPin(Preferences.drawerPin);

  Future<bool> openDrawer1() => _openDrawerWithPin(DrawerPin.pin2);

  Future<bool> openDrawer2() => _openDrawerWithPin(DrawerPin.pin5);

  Future<bool> _openDrawerWithPin(DrawerPin pin) async {
    try {
      debugPrint('Open drawer: ${pin.label}');
      final receipt = Receipt()
        ..init()
        ..drawer(pin: pin);

      return await directPrint(
        data: receipt.bytes,
        docName: 'Cash Drawer',
        printer: Preferences.counterPrinter,
      );
    } catch (e) {
      PopupDialog.showErrorMessage(e.toString());
      kLogger.e(e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Sending
  // ---------------------------------------------------------------------------

  /// Throws [PrinterException] on failure.
  static Future<void> _send({
    required Uint8List data,
    required String printer,
    String? docName,
  }) async {
    final target = _resolveTarget(printer);
    if (target == null) {
      throw const PrinterException(
        PrinterErrorType.notConfigured,
        'Printer IP address is not configured',
      );
    }
    debugPrint('🖨️ ${docName ?? 'Print'} → ${target.host}:${target.port}');
    await NetworkPrinter(ip: target.host, port: target.port).print(data);
  }

  /// Turns whatever is stored for the printer into host + port.
  /// Returns null when no host is configured.
  static ({String host, int port})? _resolveTarget(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    // Encoded PrinterModel (JSON).
    final model = PrinterModel.decode(value);
    if (model != null) {
      if (!model.isConfigured) return null;
      return (host: model.host, port: model.port);
    }

    // "host:port" (IPv4 / hostname only — a bare IPv6 has several colons).
    final parts = value.split(':');
    if (parts.length == 2) {
      final host = parts[0].trim();
      final port = int.tryParse(parts[1].trim());
      if (host.isNotEmpty && port != null && port > 0 && port < 65536) {
        return (host: host, port: port);
      }
    }

    return (host: value, port: _defaultPort);
  }

  /// Label for the dialog — never the raw JSON of a PrinterModel.
  static String _displayName(String printer) {
    final t = _resolveTarget(printer);
    if (t == null) return 'No printer selected';
    return t.port == _defaultPort ? t.host : '${t.host}:${t.port}';
  }

  // ---------------------------------------------------------------------------
  // Failed jobs + error dialog
  // ---------------------------------------------------------------------------

  /// Failed prints waiting for Retry / Discard. Shared by every PrintUtils().
  static final RxList<_FailedPrintJob> _failedJobs = <_FailedPrintJob>[].obs;
  static final RxBool _isRetrying = false.obs;

  /// Keeps memory bounded if a printer stays offline for a long time.
  static const int _maxPendingJobs = 20;

  static bool _isDialogOpen = false;
  static int _dialogId = 0;
  static BuildContext? _dialogContext;

  static void _onFailure(_FailedPrintJob job, {required bool showErrorDialog}) {
    kLogger.e(
      'Print failed [${_displayName(job.printer)}] '
      '${job.docName ?? ''}: ${job.error}',
    );
    if (!showErrorDialog) return;

    _failedJobs.add(job);
    if (_failedJobs.length > _maxPendingJobs) _failedJobs.removeAt(0);

    // If the dialog is already up, the new job just appears in it.
    if (!_isDialogOpen) _showErrorDialog();
  }

  static Future<void> _retryAll() async {
    if (_isRetrying.value) return;
    _isRetrying.value = true;
    try {
      // Copy: the list changes while we iterate.
      for (final job in List<_FailedPrintJob>.of(_failedJobs)) {
        if (!job.error.type.isRetryable) continue;
        try {
          await _send(data: job.data, printer: job.printer, docName: job.docName);
          _failedJobs.remove(job);
        } on PrinterException catch (e) {
          _replace(job, job.copyWith(error: e));
        } catch (e) {
          _replace(
            job,
            job.copyWith(
              error: PrinterException(
                PrinterErrorType.unknown,
                'Unexpected print error',
                e,
              ),
            ),
          );
        }
      }
    } finally {
      _isRetrying.value = false;
    }

    if (_failedJobs.isEmpty) {
      _closeDialog();
      PopupDialog.showSuccessDialog('Print Sent');
    }
  }

  static void _replace(_FailedPrintJob oldJob, _FailedPrintJob newJob) {
    final i = _failedJobs.indexOf(oldJob);
    if (i != -1) _failedJobs[i] = newJob;
  }

  static void _discardAll() {
    _failedJobs.clear();
    _closeDialog();
  }

  /// Pops OUR dialog only. `Get.back()` would close whatever route is on top,
  /// e.g. a payment dialog opened after the print failed.
  static void _closeDialog() {
    final ctx = _dialogContext;
    _isDialogOpen = false;
    _dialogContext = null;
    if (ctx == null || !ctx.mounted) return;

    final route = ModalRoute.of(ctx);
    if (route == null) return;
    final navigator = Navigator.of(ctx);
    if (route.isCurrent) {
      navigator.pop();
    } else {
      // Another dialog is on top of ours — remove ours without touching it.
      navigator.removeRoute(route);
    }
  }

  static void _showErrorDialog() {
    _isDialogOpen = true;
    final id = ++_dialogId;

    Get.dialog(
      Builder(
        builder: (context) {
          if (id == _dialogId) _dialogContext = context;
          return const _PrinterErrorDialog();
        },
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      // Ignore if a newer dialog was opened while this one was closing.
      if (id != _dialogId) return;
      _isDialogOpen = false;
      _dialogContext = null;
      // Closed by Esc / system back: jobs stay pending and show up again
      // with the next failure. Nothing is lost silently.
    });
  }
}

class _FailedPrintJob {
  final Uint8List data;
  final String printer;
  final String? docName;
  final PrinterException error;

  const _FailedPrintJob({
    required this.data,
    required this.printer,
    required this.docName,
    required this.error,
  });

  _FailedPrintJob copyWith({PrinterException? error}) => _FailedPrintJob(
    data: data,
    printer: printer,
    docName: docName,
    error: error ?? this.error,
  );
}

class _PrinterErrorDialog extends StatelessWidget {
  const _PrinterErrorDialog();

  @override
  Widget build(BuildContext context) {
    final errorColor = Get.theme.colorScheme.error;

    return Dialog(
      backgroundColor: ConfigController.to.isLightTheme
          ? Get.theme.canvasColor
          : StaticColors.cartColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 550,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Obx(() {
            final jobs = PrintUtils._failedJobs;
            final retrying = PrintUtils._isRetrying.value;
            if (jobs.isEmpty) return const SizedBox.shrink();

            final latest = jobs.last;
            final canRetry = jobs.any((j) => j.error.type.isRetryable);
            final printers = jobs
                .map((j) => PrintUtils._displayName(j.printer))
                .toSet()
                .join(', ');

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.print_disabled_rounded, size: 40, color: errorColor),
                const SizedBox(height: 14),
                Text(
                  latest.error.type.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"$printers"',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                Text(
                  latest.error.type.hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 10),
                Text(
                  latest.error.details,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: errorColor.withValues(alpha: 0.7),
                  ),
                ),
                if (jobs.length > 1) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${jobs.length} prints waiting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: errorColor,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: retrying ? null : PrintUtils._discardAll,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade400,
                          side: BorderSide(color: Colors.grey.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(canRetry ? 'Discard' : 'Close'),
                      ),
                    ),
                    if (canRetry) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: retrying ? null : PrintUtils._retryAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StaticColors.blueColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: StaticColors.blueColor
                                .withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: retrying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  jobs.length > 1
                                      ? 'Retry All (${jobs.length})'
                                      : 'Retry',
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
