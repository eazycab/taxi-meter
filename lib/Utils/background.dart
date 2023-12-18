import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundTasks {
  static var logger = Logger();
  static Timer? timer;
  static int seconds = 0;
  static late double carSpeed = 0.0;
  static StreamSubscription<Position>? positionStream;
  static StreamSubscription<Position>? positionStreamForDistance;
  static late StreamSubscription _getPositionSubscription;

  static void startTimer() {
    // If a timer is already running, cancel it
    if (timer != null) {
      timer!.cancel();
    }

    // Start a new timer that increments every second
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      seconds++;
    });
  }

  static void stopTimer() {
    /// commented out setStates because it resetting wait time to zero instead of freezing the time.

    if (timer != null) {
      timer!.cancel();
      // setState(() {
      //   seconds = 0;
      // });
      /// commented out setStates because it resetting wait time to zero instead of freezing the time.

      logger.w("Timer is working Stopped!");
    } else {
      if (kDebugMode) {
        logger.d("Timer is null. Cannot stop.");
      }
    }
  }

  static Future<void> calculateSpeed() async {
    // Set up the position stream listener

    _getPositionSubscription =
        Geolocator.getPositionStream().listen((position) {
      // carSpeed = position.speed;
      carSpeed = (position.speed) * 3.6; // Speed in km/h

      // If carSpeed is less than 1 km/h
      if (carSpeed < 1.0) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }
}
