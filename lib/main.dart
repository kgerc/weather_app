import 'package:flutter/material.dart';
import 'package:weather_app/weather.dart';

import 'models/location.dart';

void main() {
  runApp(const MyApp());
}

List<Location> locations = [
  new Location(city: "gliwice", country: "poland", lat: "50.298", lon: "18.677")
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrentWeatherPage(locations),
    );
  }
}
