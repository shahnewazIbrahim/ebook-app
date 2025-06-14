import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showUnderMaintenanceSnackbar() {
  Get.snackbar(
    "ℹ️ Under Maintenance",
    "Please wait for the next update.",
    backgroundColor: Colors.blue.shade100,
    colorText: Colors.black87,
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 4),
    icon: const Icon(Icons.info_outline, color: Colors.blue, size: 28),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    borderRadius: 12,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shouldIconPulse: false,
  );
}
