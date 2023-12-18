import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission(BuildContext context) async {
  final status = await Permission.location.request();
  if (status.isDenied) {
    // Handle the case where the user denied location permissions.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
              'Please grant location permission in the device settings to use this app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
