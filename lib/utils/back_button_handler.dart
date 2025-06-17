import 'package:flutter/material.dart';

class BackButtonHandler {
  static DateTime? _lastBackPressed;

  static Future<bool> handleBackPress(BuildContext context) async {
    final now = DateTime.now();
    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  static Widget wrapWithBackHandler(BuildContext context, Widget child) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await handleBackPress(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
