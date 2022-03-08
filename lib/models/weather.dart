class Weather {
  final String? cityName;
  final double? temp;
  final int? pressure;
  final String? description;
  final int? sunrise;
  final int? sunset;

  Weather(
      {this.cityName,
      this.temp,
      this.pressure,
      this.description,
      this.sunrise,
      this.sunset});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temp: json['main']['temp'].toDouble(),
      pressure: json['main']['pressure'].toInt(),
      description: json['weather'][0]['description'],
      sunrise: json['sys']['sunrise'].toInt(),
      sunset: json['sys']['sunset'].toInt(),
    );
  }
}
