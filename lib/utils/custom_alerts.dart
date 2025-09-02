import 'package:flutter/material.dart';

class CustomAlerts {
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void toastSuccess(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  static void toastError(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  static void toastInfo(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.blue);
  }

  static void toastWarning(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.orange);
  }
}