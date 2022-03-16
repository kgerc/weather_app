import 'dart:convert';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/location.dart';
import 'extensions.dart';

import 'models/weather.dart';
import 'package:http/http.dart' as http;

class CurrentWeatherPage extends StatefulWidget {
  List<Location> locations;
  CurrentWeatherPage(this.locations);
  @override
  _CurrentWeatherPageState createState() =>
      _CurrentWeatherPageState(this.locations);
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  List<Location> locations;
  Location location;
  late Weather _weather;
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "gliwice";
  bool _isViewForOldPeople = false;

  _CurrentWeatherPageState(List<Location> locations)
      : this.locations = locations,
        this.location = locations[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
            leading: _isSearching ? const BackButton() : Container(),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            actions: _buildActions(),
            title: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: TextField(
                    controller: _searchQueryController,
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      ),
                      hintText: "Znajdź lokalizacje...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                    onSubmitted: (query) => updateSearchQuery(query),
                  ),
                ))),
        body: ListView(
          children: <Widget>[
            currentWeatherViews(this.location, this.context),
            _isViewForOldPeople
                ? SizedBox.shrink()
                : forecastViewHourly(this.location, this.context),
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    padding: const EdgeInsets.only(
                        left: 15, top: 25, bottom: 25, right: 15),
                    margin: const EdgeInsets.only(
                        left: 15, top: 15, bottom: 15, right: 15),
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
                            child: Wrap(
                          direction: Axis.horizontal,
                          spacing: 10.0,
                          children: [
                            Container(
                                child: Text(
                              "Data i obecny czas:",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.grey),
                            )),
                            Container(
                                child: Text(
                              DateFormat('dd.MM.yyyy HH:mm:ss')
                                  .format(DateTime.now()),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              textAlign: TextAlign.left,
                            ))
                          ],
                        )),
                      ],
                    ),
                  );
                }),
          ],
        ));
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }
    return <Widget>[
      PopupMenuButton(
        onSelected: (bool val) {
          setState(() {
            _isViewForOldPeople = !_isViewForOldPeople;
          });
        },
        icon: Icon(
          Icons.more_vert,
          color: Colors.black,
        ),
        itemBuilder: (_) => [
          PopupMenuItem(
            textStyle: TextStyle(color: Colors.black, fontSize: 16.0),
            child: _isViewForOldPeople
                ? Text('Widok domyślny')
                : Text('Widok dla osób starszych'),
            value: false,
          ),
        ],
      ),
    ];
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      locations = <Location>[Location(city: newQuery)];
      location = locations[0];
      print(locations[0].city);
      //_clearSearchQuery();
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  Widget currentWeatherViews(Location location, BuildContext context) {
    Weather _weather;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _weather = snapshot.data as Weather;
          if (_weather == null) {
            return Text("Error getting weather");
          } else {
            return Column(children: [
              //cityBar(location, context),
              weatherContainer(_weather),
              weatherDetailContainer(_weather),
            ]);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
      future: getCurrentWeather(location.city!),
    );
  }

  Widget forecastViewHourly(Location location, BuildContext context) {
    Forecast _forecast;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _forecast = snapshot.data as Forecast;
          if (_forecast == null) {
            return Text("Error getting weather");
          } else {
            return hourlyBoxes(_forecast);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
      future: getForecast(location),
    );
  }

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
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "${_weather.cityName}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 40,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    child: Text(
                      "${_weather.temp?.toStringAsFixed(1)}℃",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(0),
                    child: Text(
                      "Odczuwalna: ${_weather.feelsLike?.toStringAsFixed(1)}℃",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getWeatherIcon(_weather.icon!),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Text(
                      "${_weather.description?.capitalizeFirstOfEach}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Text(
                      "W:${getClockInUtc(_weather.sunrise!)} Z:${getClockInUtc(_weather.sunset!)}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              )),
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
  return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0),
      height: 150.0,
      child: ListView.builder(
          padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 8),
          scrollDirection: Axis.horizontal,
          itemCount: _forecast.hourly.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                padding: const EdgeInsets.only(
                    left: 10, top: 15, bottom: 15, right: 10),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 1), // changes position of shadow
                      )
                    ]),
                child: Column(children: [
                  Text(
                    "${_forecast.hourly[index].temp?.toStringAsFixed(1)}°C",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.black),
                  ),
                  getWeatherIcon(_forecast.hourly[index].icon!),
                  Text(
                    "${getClockInUtc(_forecast.hourly[index].dt!)}",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ]));
          }));
}

Widget cityBar(Location location, BuildContext context) {
  return AppBar(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      getCurrentWeather(location.city!);
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {},
                  ),
                  hintText: 'Znajdź lokalizacje..',
                  border: InputBorder.none),
            ),
          )));
}

Future<Weather> getCurrentWeather(String locationName) async {
  Weather weather = Weather();
  String city = locationName;
  String apiKey = "c5f5c7bce47d973286349e55618ffac1";
  var url =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&lang=pl&appid=$apiKey&units=metric";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    weather = Weather.fromJson(jsonDecode(response.body));
  } else {
    throw new Exception("failed to retrieve current weather data");
  }

  return weather;
}

Future<Forecast> getForecast(Location location) async {
  Forecast forecast = new Forecast(daily: [], hourly: []);
  String apiKey = "c5f5c7bce47d973286349e55618ffac1";
  String city = location.city!;
  var locationDetailsUrl =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&lang=pl&appid=$apiKey&units=metric";
  final locationDetails = await http.get(Uri.parse(locationDetailsUrl));
  final locationDetaisDecoded = jsonDecode(locationDetails.body);
  String lat = locationDetaisDecoded['coord']['lat'].toString();
  String lon = locationDetaisDecoded['coord']['lon'].toString();
  var url =
      "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    forecast = Forecast.fromJson(jsonDecode(response.body));
  } else {
    throw new Exception("failed to retrieve forecast data");
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
