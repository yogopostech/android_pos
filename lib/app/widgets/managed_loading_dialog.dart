import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class ManagedLoadingDialog {
  ManagedLoadingDialog._();
  static final ManagedLoadingDialog _instance = ManagedLoadingDialog._();
  factory ManagedLoadingDialog() => _instance;

  final GlobalKey _key = GlobalKey();
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void show() {
    if (_isOpen) {
      debugPrint('[ManagedLoadingDialog] already open');
      return;
    }

    final context = Get.context;
    if (context == null) {
      debugPrint('[ManagedLoadingDialog] Get.context is null');
      return;
    }

    final theme = Theme.of(context);
    _isOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeyedSubtree(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Material(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: SpinKitRing(
                    color: theme.primaryColor,
                    size: 53,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() => _isOpen = false);
  }

  void close() {
    if (!_isOpen) {
      debugPrint('[ManagedLoadingDialog] not open');
      return;
    }

    final ctx = _key.currentContext;
    if (ctx == null) {
      debugPrint('[ManagedLoadingDialog] currentContext is null');
      _isOpen = false;
      return;
    }

    final nav = Navigator.maybeOf(ctx);
    if (nav == null) {
      debugPrint('[ManagedLoadingDialog] no Navigator found');
      _isOpen = false;
      return;
    }

    if (nav.canPop()) {
      nav.pop();
    } else {
      debugPrint('[ManagedLoadingDialog] nothing to pop');
      _isOpen = false;
    }
  }
}