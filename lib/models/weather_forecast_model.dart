class WeatherForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String iconUrl;

  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.iconUrl,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'].toDouble(),
      minTemp: json['day']['mintemp_c'].toDouble(),
      condition: json['day']['condition']['text'],
      iconUrl: 'https:${json['day']['condition']['icon']}',
    );
  }
}
