import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[LOG] $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ERROR] $message');
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[WARN] $message');
    }
  }
}
