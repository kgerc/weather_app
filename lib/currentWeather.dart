import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/location.dart';
import 'extensions.dart';

import 'models/weather.dart';
import 'package:http/http.dart' as http;

class CurrentWeatherPage extends StatefulWidget {
  final List<Location> locations;
  const CurrentWeatherPage(this.locations);
  @override
  _CurrentWeatherPageState createState() =>
      _CurrentWeatherPageState(this.locations);
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  final List<Location> locations;
  final Location location;
  late Weather _weather;

  _CurrentWeatherPageState(List<Location> locations)
      : this.locations = locations,
        this.location = locations[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: ListView(
          children: <Widget>[
            currentWeatherViews(this.locations, this.location, this.context),
            //forecastViewHourly(this.locations),
          ],
        ));
  }

  Widget currentWeatherViews(
      List<Location> locations, Location location, BuildContext context) {
    Weather _weather;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _weather = snapshot.data as Weather;
          if (_weather == null) {
            return Text("Error getting weather");
          } else {
            return Column(children: [
              cityBar(location),
              weatherContainer(_weather),
              weatherDetailContainer(_weather),
            ]);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
      future: getCurrentWeather(location),
    );
  }

  // Widget forcastViewsHourly(Location location) {
  // }

  // Widget forcastViewsDaily(Location location) {
  // }

  Widget weatherContainer(Weather _weather) {
    initializeDateFormatting('pl-PL');
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.all(15.0),
          height: 160.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.indigoAccent),
        ),
        ClipPath(
            clipper: Clipper(),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.all(15.0),
              height: 160.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.indigoAccent[400]),
            )),
        Container(
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.all(15.0),
          height: 160.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // TODO: Dodaj ikone tutaj
                  getWeatherIcon(_weather.icon!),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Text(
                      "${_weather.description?.capitalizeFirstOfEach}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Text(
                      "W:${getClockInUtc(_weather.sunrise!)} Z:${getClockInUtc(_weather.sunset!)}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                ],
              )),
              Column(
                children: [
                  Container(
                    child: Text(
                      "${_weather.temp?.toStringAsFixed(1)}℃",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 50,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(0),
                    child: Text(
                      "Odczuwalna: ${_weather.feelsLike?.toStringAsFixed(1)}℃",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

Widget weatherDetailContainer(Weather _weather) {
  return Container(
    padding: const EdgeInsets.only(left: 15, top: 25, bottom: 25, right: 15),
    margin: const EdgeInsets.only(left: 15, top: 5, bottom: 15, right: 15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          )
        ]),
    child: Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Container(
                child: Text(
              "Wiatr",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey),
            )),
            Container(
                child: Text(
              "${_weather.wind} km/h",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black),
            ))
          ],
        )),
        Expanded(
            child: Column(
          children: [
            Container(
                child: Text(
              "Wilgotność",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey),
            )),
            Container(
                child: Text(
              "${_weather.humidity?.toInt()}%",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black),
            ))
          ],
        )),
        Expanded(
            child: Column(
          children: [
            Container(
                child: Text(
              "Ciśnienie",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey),
            )),
            Container(
                child: Text(
              "${_weather.pressure} hPa",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black),
            ))
          ],
        )),
      ],
    ),
  );
}

Widget hourlyBoxes(Forecast _forecast) {
  return Container();
}

Widget dailyBoxes(Forecast _forecast) {
  return Container();
}

Widget cityBar(Location location) {
  return Container(
      padding: const EdgeInsets.only(left: 20, top: 15, bottom: 15, right: 20),
      margin:
          const EdgeInsets.only(top: 35, left: 15.0, bottom: 15.0, right: 15.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(60)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            )
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '${location.city?.capitalizeFirstOfEach}, ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(
                    text: '${location.country?.capitalizeFirstOfEach}',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black,
            size: 24.0,
            semanticLabel: 'Zmień lokalizacje',
          ),
        ],
      ));
}

Future<Weather> getCurrentWeather(Location location) async {
  Weather weather = Weather();
  String city = location.city!;
  String apiKey = "c5f5c7bce47d973286349e55618ffac1";
  var url =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&lang=pl&appid=$apiKey&units=metric";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    weather = Weather.fromJson(jsonDecode(response.body));
  } else {
    // TODO: throw error
  }

  return weather;
}

Future<Forecast> getForecast(Location location) async {
  Forecast forecast = Forecast();
  String apiKey = "c5f5c7bce47d973286349e55618ffac1";
  String lat = location.lat!;
  String lon = location.lon!;
  var url =
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&lang=pl&appid=$apiKey&units=metric";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    forecast = Forecast.fromJson(jsonDecode(response.body));
  }
  return forecast;
}

String getClockInUtc(int timeSinceEpochInSec) {
  final time = DateTime.fromMillisecondsSinceEpoch(timeSinceEpochInSec * 1000,
      isUtc: false);
  return '${DateFormat.jm("pl").format(time)}';
}

Image getWeatherIcon(String _icon) {
  String path = 'assets/icons/';
  String imageExtension = '.png';
  return Image.asset(
    path + _icon + imageExtension,
    width: 70,
    height: 70,
  );
}

Image getWeatherIconSmall(String _icon) {
  String path = 'assets/icons/';
  String imageExtension = '.png';
  return Image.asset(
    path + _icon + imageExtension,
    width: 40,
    height: 40,
  );
}

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height - 20);

    path.quadraticBezierTo((size.width / 6) * 1, (size.height / 2) + 15,
        (size.width / 3) * 1, size.height - 30);
    path.quadraticBezierTo((size.width / 2) * 1, (size.height + 0),
        (size.width / 3) * 2, (size.height / 4) * 3);
    path.quadraticBezierTo((size.width / 6) * 5, (size.height / 2) - 20,
        size.width, size.height - 60);

    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(Clipper oldClipper) => false;
}

String getTimeFromTimestamp(int timestamp) {
  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = new DateFormat('h:mm a');
  return formatter.format(date);
}

String getDateFromTimestamp(int timestamp) {
  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = new DateFormat('E');
  return formatter.format(date);
}
// Text("${_weather.cityName}"),
// Text("${_weather.temp?.toStringAsFixed(1)}℃"),
// Text("${_weather.pressure}"),
// Text("${_weather.description}"),
// Text("${getClockInUtc(_weather.sunrise!)}"),
// Text("${getClockInUtc(_weather.sunset!)}"),
// Text("${DateFormat.jm("pl").format(DateTime.now())}"),
