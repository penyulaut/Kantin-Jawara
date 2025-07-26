import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';

enum SnackbarType { success, error, info }

class CustomSnackbar {
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
    bool showIcon = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppTheme.successColor,
      colorText: AppTheme.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: AppTheme.successColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      icon: showIcon
          ? const Icon(Icons.check_circle, color: AppTheme.white, size: 24)
          : null,
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
    bool showIcon = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppTheme.errorColor,
      colorText: AppTheme.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: AppTheme.errorColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      icon: showIcon
          ? const Icon(Icons.error_outline, color: AppTheme.white, size: 24)
          : null,
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
    bool showIcon = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppTheme.infoColor,
      colorText: AppTheme.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: AppTheme.infoColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      icon: showIcon
          ? const Icon(Icons.info_outline, color: AppTheme.white, size: 24)
          : null,
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
    bool showIcon = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: AppTheme.warningColor,
      colorText: AppTheme.royalBlueDark,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: AppTheme.warningColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      icon: showIcon
          ? const Icon(
              Icons.warning_outlined,
              color: AppTheme.royalBlueDark,
              size: 24,
            )
          : null,
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void show({
    required SnackbarType type,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
    bool showIcon = true,
  }) {
    switch (type) {
      case SnackbarType.success:
        showSuccess(
          title: title,
          message: message,
          duration: duration,
          position: position,
          showIcon: showIcon,
        );
        break;
      case SnackbarType.error:
        showError(
          title: title,
          message: message,
          duration: duration,
          position: position,
          showIcon: showIcon,
        );
        break;
      case SnackbarType.info:
        showInfo(
          title: title,
          message: message,
          duration: duration,
          position: position,
          showIcon: showIcon,
        );
        break;
    }
  }

  static void success(String message) {
    showSuccess(title: 'Success', message: message);
  }

  static void error(String message) {
    showError(title: 'Error', message: message);
  }

  static void info(String message) {
    showInfo(title: 'Info', message: message);
  }

  static void warning(String message) {
    showWarning(title: 'Warning', message: message);
  }
}
