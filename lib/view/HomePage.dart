import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isStarted = false; // Variable to track the state (start or stop)

  double? carSpeed;

  void toggleStartStop() {
    setState(() {
      isStarted = !isStarted; // Toggle the state
    });
  }

  @override
  void initState() {
    super.initState();

    // Set up the position stream listener
    Geolocator.getPositionStream().listen((position) {
      setState(() {
        carSpeed = position.speed;
      });
    });
  }

  Future<void> startTaximeter() async {
    isTaximeterRunning = true;
    previousPosition = await Geolocator.getLastKnownPosition();
  }

  Future<void> stopTaximeter() async {
    isTaximeterRunning = false;
    Position? currentPosition = await Geolocator.getLastKnownPosition();
    if (previousPosition != null && currentPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        previousPosition!.latitude,
        previousPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );
      totalDistance += distanceInMeters / 1000; // Convert to kilometers
    }
  }

  double totalDistance = 0.0;
  double totalTime = 0.0;
  double fare = 0.0;
  double waitingCharges = 0.0;

  Position? previousPosition;
  bool isTaximeterRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black12,
        title: const Text(
          'App Fare Calculator',
          style: TextStyle(
            fontSize: 22,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.visible,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Center the Row horizontally
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    toggleStartStop();
                    if (!isTaximeterRunning) {
                      startTaximeter();
                      // getCarSpeed();
                    } else {
                      stopTaximeter();
                    }
                  },
                  child: Text(isStarted ? 'Stop' : 'Start'),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Align labels to the right
                children: <Widget>[
                  Text('Fare:'),
                  Text('${totalDistance.toStringAsFixed(2)} km'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Distance:'),
                  Text('Your Distance Value'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Wait Time:'),
                  Text('Your Wait Time Value'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Speed:'),
                  // Text('${carSpeed ?? 0}'),
                  Text(
                      'Current Speed: ${(carSpeed! * 3.6).toStringAsFixed(
                          2)} km/h'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
