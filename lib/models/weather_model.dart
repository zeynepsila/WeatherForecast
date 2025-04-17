class WeatherModel {
  final String city;
  final String country;
  final String condition;
  final String iconUrl;
  final double temperature;

  WeatherModel({
    required this.city,
    required this.country,
    required this.condition,
    required this.iconUrl,
    required this.temperature,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['location']['name'],
      country: json['location']['country'],
      condition: json['current']['condition']['text'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
      temperature: json['current']['temp_c'].toDouble(),
    );
  }
}
