import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitPulsingGrid(
      color: Theme.of(context).primaryColor,
      size: 48,
    );
  }
}
