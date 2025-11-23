import 'package:flutter/material.dart';
import 'package:koji/constants/app_color.dart';
import 'package:toastification/toastification.dart';

class ToastMessageHelper {
  /// Show a toast message. If `context` is provided and Toastification isn't
  /// initialized, a SnackBar will be used as a fallback. If no context is
  /// available, the message will be printed to the console.
  static void showToastMessage(
    String message, {
    String title = 'Success',
    BuildContext? context,
  }) {
    // Determine toast type and icon based on title
    ToastificationType type = ToastificationType.success;
    Icon icon = const Icon(Icons.check, color: Colors.white);

    switch (title.toLowerCase()) {
      case 'warning':
      case 'caution':
      case 'attention':
        type = ToastificationType.warning;
        icon = const Icon(Icons.warning, color: Colors.black);
        break;
      case 'error':
      case 'failed':
        type = ToastificationType.error;
        icon = const Icon(Icons.error, color: Colors.white);
        break;
      case 'info':
        type = ToastificationType.info;
        icon = const Icon(Icons.info, color: Colors.white);
        break;
      default:
        type = ToastificationType.success;
        icon = const Icon(Icons.check, color: Colors.black);
    }

    try {
      toastification.show(
        type: type,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        description: RichText(
          text: TextSpan(
            text: message,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        alignment: Alignment.topRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        icon: icon,
        showIcon: true,
        primaryColor: AppColor.primaryColor,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          ),
        ],
        showProgressBar: true,
        closeButton: ToastCloseButton(
          showType: CloseButtonShowType.onHover,
          buttonBuilder: (context, onClose) {
            return OutlinedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Close'),
            );
          },
        ),
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
        callbacks: ToastificationCallbacks(
          onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
          onCloseButtonTap: (toastItem) =>
              print('Toast ${toastItem.id} close button tapped'),
          onAutoCompleteCompleted: (toastItem) =>
              print('Toast ${toastItem.id} auto complete completed'),
          onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
        ),
      );
    } catch (e) {
      // If Toastification isn't initialized (common in integration tests or if
      // the app hasn't been wrapped), fall back to a SnackBar when we have a
      // BuildContext, or print to console otherwise.
      debugPrint('Toastification not available: $e');
      if (context != null) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title: $message'),
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (e2) {
          debugPrint('Failed to show SnackBar fallback: $e2');
        }
      } else {
        // last-resort fallback
        debugPrint('$title: $message');
      }
    }
  }
}
