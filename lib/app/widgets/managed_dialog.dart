import 'package:flutter/material.dart';

class ManagedDialog {
  final GlobalKey _key = GlobalKey();
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  /// Opens the dialog. The [builder] receives the dialog's own [BuildContext].
  Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) async {
    if (_isOpen) {
      debugPrint('[ManagedDialog] already open — ignoring show()');
      return null;
    }

    _isOpen = true;

    final result = await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (ctx) => KeyedSubtree(
        key: _key,
        child: builder(ctx),
      ),
    );

    _isOpen = false;
    return result;
  }

  /// Closes this specific dialog (no-op if already closed).
  void close<T>([T? result]) {
    if (!_isOpen) {
      debugPrint('[ManagedDialog] not open — ignoring close()');
      return;
    }

    final ctx = _key.currentContext;
    if (ctx == null) {
      debugPrint('[ManagedDialog] currentContext is null — cannot close');
      _isOpen = false;
      return;
    }

    final nav = Navigator.maybeOf(ctx);
    if (nav == null) {
      debugPrint('[ManagedDialog] no Navigator found — cannot close');
      _isOpen = false;
      return;
    }

    if (nav.canPop()) {
      nav.pop(result);
    } else {
      debugPrint('[ManagedDialog] nothing to pop');
    }
  }

  /// Closes every dialog / route on top of the first non-popup route.
  void closeAll(BuildContext context) {
    Navigator.of(context).popUntil((route) => route is! PopupRoute);
  }
}