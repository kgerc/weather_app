class Weather {
  final String? cityName;
  final double? temp;
  final double? feelsLike;
  final double? wind;
  final int? pressure;
  final String? description;
  final int? sunrise;
  final int? sunset;
  final String? icon;
  final double? humidity;

  Weather(
      {this.cityName,
      this.temp,
      this.feelsLike,
      this.pressure,
      this.description,
      this.sunrise,
      this.sunset,
      this.icon,
      this.wind,
      this.humidity});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temp: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      pressure: json['main']['pressure'].toInt(),
      description: json['weather'][0]['description'],
      sunrise: json['sys']['sunrise'].toInt(),
      sunset: json['sys']['sunset'].toInt(),
      wind: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'].toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}
