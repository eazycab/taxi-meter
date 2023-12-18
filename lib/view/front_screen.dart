import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:taxi_meter/Utils/Horizontal%20Cards.dart';
import 'package:taxi_meter/Utils/dialogBox.dart';
import '../Utils/changefare.dart';
import '../Utils/provider.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class FrontScreen extends StatefulWidget {
  const FrontScreen({super.key});

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  //audio player
  void playSound(String url) async {
    AssetsAudioPlayer.newPlayer().open(Audio(url), autoStart: true);
  }

  bool isFareActive = false; // For Default Fare

  StreamController<double> _fareController = StreamController<double>();
  // Declare a periodic timer
  Timer? fareUpdateTimer;
  // Declare a default fare value

  var logger = Logger();

//Text to Speech Instance
  FlutterTts flutterTts = FlutterTts();

  var totalPrice;

  bool ignorePointer = false;

  late StreamSubscription _getPositionSubscription;

  late double carSpeed = 0.0;
  //covered distance variable
  double coveredDistance = 0.0;
  double? mydDefaultFare;

  Position? previousPosition;

  /// to know car speed
  bool isCalculatingSpeed = false;

  /// to reset car speed to zero

  double totalFare = 30;
  double ratePerKilometer = 2;

  // ------------------- calculate waiting time when the car stationary
  Timer? waitTimer;
  Duration waitDuration = const Duration(seconds: 0);

  int seconds = 0;
  Timer? timer;

// ------------------- calculate waiting time when the car stationary

  @override
  void initState() {
    startFareUpdateTimer();
    super.initState();
    _fareController = StreamController<double>();
  }

  @override
  void dispose() {
    // _fareController.close();

    ///--------------------------

    // Stop listening to location changes when the widget is disposed
    _getPositionSubscription.cancel();

    // Cancel the timer when the widget is disposed
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<UserNotifier>(context).getFare().then((value) {
      totalFare = value;
    });
  }

  void calculateDistance() {
    setState(() {
      previousPosition = null; // Reset previous position
    });

    positionStreamForDistance =
        Geolocator.getPositionStream().listen((Position position) {
      if (previousPosition != null) {
        double distance = Geolocator.distanceBetween(
          previousPosition!.latitude,
          previousPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // Convert distance from meters to kilometers
        double distanceInKms = distance / 1000;

        setState(() {
          coveredDistance += distanceInKms;
        });
      }

      previousPosition = position;
    });
  }

  //for getting real time car speed with best accuracy
/*
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );*/

  StreamSubscription<Position>? positionStream;
  StreamSubscription<Position>? positionStreamForDistance;

  // carSpeed Function
  Future<void> calculateSpeed() async {
    // Set up the position stream listener

    _getPositionSubscription =
        Geolocator.getPositionStream().listen((position) {
      setState(() {
        // carSpeed = position.speed;
        carSpeed = (position.speed) * 3.6; // Speed in km/h
      });
      // If carSpeed is less than 1 km/h
      if (carSpeed < 1.0) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }

  void stopTimerOnStopButton() {
    if (!isCalculatingSpeed) {
      if (timer != null) {
        timer!.cancel();
      }
    }
  }

  void disposePositionStream() {
    positionStream?.cancel();
    positionStream = null;
  }

  /// ----------------------------------- WAIT TIME

  void startTimer() {
    // If a timer is already running, cancel it
    if (timer != null) {
      timer!.cancel();
    }

    // Start a new timer that increments every second
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    /// commented out setStates because it resetting wait time to zero instead of freezing the time.

    if (timer != null) {
      timer!.cancel();

      /// commented out setStates because it resetting wait time to zero instead of freezing the time.

      logger.w("Timer is working Stopped!");
    } else {
      if (kDebugMode) {
        logger.d("Timer is null. Cannot stop.");
      }
    }
  }

  ///------------------------------ -------------------------------------

  void stopSpeed() {
    if (carSpeed <= 1 || carSpeed > 1) {
      setState(() {
        _getPositionSubscription.cancel();
        carSpeed = 0.0;
        _getPositionSubscription.cancel();
      });
      if (kDebugMode) {
        print('Car is already stopped.');
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: InkWell(
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangeFareScreen(),
                ),
              );
              // Check if result is not null, and update the fare value
              if (result != null) {
                updateFareController(result);
              }
            },
            child: const Icon(
              Icons.save_as_outlined,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: const Text(
            'App Fare Calculator',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Gilroy-ExtraBold',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              //Fare
              /*  !isFareActive */
              StreamBuilder<double>(
                stream: _fareController.stream,
                builder: (context, snapshot) {
                  if (kDebugMode) {
                    print("Stream Updated: ${snapshot.data}");
                  }
                  double totalFares = snapshot.data ?? totalFare;
                  return cardBar(
                      context, 'Fare', '\$ ${totalFares.toStringAsFixed(2)}');
                },
              ),
              // : cardBar(context, 'Fare', '\$ ${totalFare.toStringAsFixed(2)}'),

              //Distance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  cardBar(context, 'Distance',
                      '${coveredDistance.toStringAsFixed(2)} km'),
                ],
              ),
              //Wait Time
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cardBar(
                        context,
                        'Wait Time        ',
                        (seconds < 60)
                            ? '$seconds Seconds'
                            : '${(seconds / 60).floor()}   Minutes  ${(seconds % 60)} Seconds'),
                  ],
                ),
              ),
              //Speed
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  cardBar(context, 'Speed',
                      '${(carSpeed.toStringAsFixed(2))} km/h'),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.2,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: isCalculatingSpeed
                      ? ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isCalculatingSpeed = false;
                              stopTimerOnStopButton();
                              speak('App fare calculator stopped');

                              stopFareUpdateTimer();
                              stopSpeed();

                              _getPositionSubscription.cancel();
                              CustomDialogBox.dialogBox(context, totalPrice);

                              ///
                              Future.delayed(const Duration(seconds: 2))
                                  .then((value) {
                                speak(
                                    "Total fare ${totalPrice.toStringAsFixed(2)} dollars");
                              });

                              coveredDistance = 0.0;
                              previousPosition =
                                  null; // Reset previous position
                              seconds = 0;
                              positionStreamForDistance!.cancel();
                              _fareController.close();

                              /*   getFair();
                              isFareActive = true;*/
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'STOP',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.06,
                            ),
                          ),
                        )
                      : IgnorePointer(
                          ignoring: ignorePointer,
                          child: ElevatedButton(
                            onPressed: () {
                              toggleTaximeter();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              'START',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.06,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void toggleTaximeter() {
    setState(() {
      if (!isCalculatingSpeed) {
        calculateSpeed();
        calculateDistance();
        startFareUpdateTimer();
        isCalculatingSpeed = true;
        speak('App fare calculator started');
      }
    });
  }

  void updateFareController(double newFare) {
    _fareController.add(newFare);
  }

  double calculateFare({
    required double baseRate,
    required double perKilometerRate,
    required double distanceCovered,
    required Duration waitTime,
  }) {
    double waitTimeRatePerSecond =
        1 / 60; // 1$ per minute converted to cents per second

    // Calculate fare based on distance
    double distanceFare = baseRate + (perKilometerRate * distanceCovered);

    // Calculate wait time in seconds
    int waitTimeInSeconds = waitTime.inSeconds;

    // Calculate fare based on wait time
    double waitTimeFare = waitTimeRatePerSecond * waitTimeInSeconds;

    // Calculate total fare
    double totalFare = distanceFare + waitTimeFare;
    // _fareController.add(totalFare);
    updateFareController(totalFare);
    totalPrice = totalFare;
    return totalPrice;
  }

  // Function to start the periodic timer
  void startFareUpdateTimer() {
    if (kDebugMode) print("Starting Timer");

    _fareController =
        StreamController<double>(); // Reinitialize the StreamController
    const Duration updateInterval = Duration(seconds: 1);

    fareUpdateTimer = Timer.periodic(updateInterval, (timer) {
      calculateFare(
        baseRate: totalFare,
        perKilometerRate: ratePerKilometer,
        distanceCovered: coveredDistance,
        waitTime: Duration(seconds: seconds),
      );
    });
  }

  // Function to stop the periodic timer
  void stopFareUpdateTimer() {
    if (kDebugMode) print("Stopping Timer");
    setState(() {
      fareUpdateTimer?.cancel();
    });
    setState(() {
      _fareController.add(totalFare);
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US"); // Change to the desired language
    await flutterTts.setPitch(1.0); // Adjust pitch (1.0 is the default)
    await flutterTts
        .setSpeechRate(0.5); // Adjust speech rate (1.0 is the default)
    await flutterTts.speak(text);
  }

  ///---------------TOTAL FARE ------------------------------

}
