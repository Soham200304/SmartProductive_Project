import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundService {
  static void startForegroundTask() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Focus Timer Running',
      notificationText: 'Your focus session is active',
      callback: startCallback,
    );
  }

  static void stopForegroundTask() {
    FlutterForegroundTask.stopService();
  }

  static void startCallback(int remainingTime) {
    Timer.periodic(Duration(seconds: 1), (timer) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Focus Timer Running',
        notificationText: 'Remaining time: ${remainingTime}s',
      );
      remainingTime--; // Decrease the time
      if (remainingTime <= 0) {
        timer.cancel(); // Stop when the timer reaches 0
      }
    });
  }
}
