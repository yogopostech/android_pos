import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoaderOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return; // Prevent multiple

    ThemeData theme = Theme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          ignoring: true, // allow clicks outside loader
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Loader box
              SizedBox(
                width: 120,
                height: 120,
                child: Material(
                  elevation: 2,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: SpinKitRing(
                    color: theme.primaryColor,
                    size: 53,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}