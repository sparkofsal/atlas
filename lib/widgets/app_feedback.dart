import 'package:flutter/material.dart';

class AppFeedback {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }
}