import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';

class WeatherService {
  final String apiKey = 'c056e111b9c64dcea58112711251704';
  final String baseUrl = 'http://api.weatherapi.com/v1';

  // 🌤 ŞEHİR ADIYLA HAVA DURUMU ALMA
  Future<WeatherModel> fetchWeather(String cityName) async {
    final url = Uri.parse('$baseUrl/current.json?key=$apiKey&q=$cityName&lang=tr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return WeatherModel.fromJson(jsonData);
    } else {
      throw Exception('Hava durumu alınamadı');
    }
  }

  // 📍 ENLEM & BOYLAM İLE HAVA DURUMU ALMA
  Future<WeatherModel> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse('$baseUrl/current.json?key=$apiKey&q=$lat,$lon&lang=tr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return WeatherModel.fromJson(jsonData);
    } else {
      throw Exception('Konuma göre hava durumu alınamadı');
    }
  }


  //Bu fonksiyon API’den gelen 3 günlük forecastday listesini alır
  Future<List<WeatherForecast>> fetchForecast(String cityName) async {
    final url = Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$cityName&days=3&lang=tr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> forecastList = jsonData['forecast']['forecastday'];

      return forecastList
          .map((dayData) => WeatherForecast.fromJson(dayData))
          .toList();
    } else {
      throw Exception('Tahmin verisi alınamadı');
    }
  }

}
