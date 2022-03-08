import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/weather.dart';
import 'package:http/http.dart' as http;

class CurrentWeatherPage extends StatefulWidget {
  @override
  _CurrentWeatherPageState createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot != null) {
              Object? _weather = snapshot.data;
              if (_weather == null) {
                return new CircularProgressIndicator();
              } else {
                return weatherContainer(_weather as Weather);
              }
            } else {
              return CircularProgressIndicator();
            }
          },
          future: getCurrentWeather(),
        ),
      ),
    );
  }

  Widget weatherContainer(Weather _weather) {
    return Column(
      children: <Widget>[
        Text("${_weather.cityName}"),
        Text("${_weather.temp}℃"),
        Text("${_weather.pressure}"),
        Text("${_weather.description}"),
        Text(
            "${Duration(milliseconds: _weather.sunrise!).toString().substring(2, 6)}"),
        Text(
            "${Duration(milliseconds: _weather.sunset!).toString().substring(2, 6)}"),
        Text("${new DateTime.now().hour}:${new DateTime.now().minute}"),
      ],
    );
  }
}

Future<Weather> getCurrentWeather() async {
  Weather weather = Weather();
  String city = "Gliwice,PL";
  String apiKey = "c5f5c7bce47d973286349e55618ffac1";
  var url =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    weather = Weather.fromJson(jsonDecode(response.body));
  } else {
    // TODO: throw error
  }

  return weather;
}
