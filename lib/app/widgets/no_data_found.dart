import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "No Data Found",
      style: TextStyle(color: Colors.black),
    );
  }
}
