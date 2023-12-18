import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:taxi_meter/view/front_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'Utils/Permisson.dart';
import 'Utils/background.dart';
import 'Utils/provider.dart';

/*@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    BackgroundTasks.calculateSpeed();
    Logger().e("Background task is running!");

    try {
      //add code execution

    } catch (err) {
      Logger().e(err
          .toString()); // Logger flutter package, prints error on the debug console
      throw Exception(err);
    }

    return Future.value(true);
  });
}*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /* Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerOneOffTask(
    "1",
    "simpleTask",
    initialDelay: Duration(seconds: 1),
  );*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Request location permissions before building the app UI
    requestLocationPermission(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserNotifier>(
            create: (context) => UserNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Fare Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: const InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Color(0xFF7EC349)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Color(0xFF7EC349)),
            ),
          ),
        ),
        home: const FrontScreen(),
      ),
    );
  }
}
