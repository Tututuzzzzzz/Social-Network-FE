import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> appSnackBar(
  BuildContext context,
  Color color,
  String label,
) {
  return ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(label), backgroundColor: color));
}
