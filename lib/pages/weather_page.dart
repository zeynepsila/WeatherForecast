import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/favorite_city_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController();
  final _weatherService = WeatherService();
  final FavoriteCityService _favoriteService = FavoriteCityService();

  WeatherModel? _weather;
  List<WeatherForecast>? _forecast;
  List<String> _favoriteCities = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getWeatherByLocation();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final favorites = await _favoriteService.getFavorites();
    setState(() {
      _favoriteCities = favorites;
    });
  }

  void _getWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final city = _cityController.text.trim();
      final weather = await _weatherService.fetchWeather(city);
      final forecast = await _weatherService.fetchForecast(city);

      setState(() {
        _weather = weather;
        _forecast = forecast;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _weather = null;
        _forecast = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _determinePosition();
      final query = '${position.latitude},${position.longitude}';
      final weather = await _weatherService.fetchWeatherByLocation(position.latitude, position.longitude);
      final forecast = await _weatherService.fetchForecast(query);

      setState(() {
        _weather = weather;
        _forecast = forecast;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _weather = null;
        _forecast = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri açık değil.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Widget _buildWeatherInfo() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    } else if (_errorMessage != null) {
      return Text(_errorMessage!, style: const TextStyle(color: Colors.red));
    } else if (_weather == null) {
      return Text(
        'Bir şehir girin veya konumdan veri alın.',
        style: GoogleFonts.quicksand(color: Colors.white),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_weather!.city}, ${_weather!.country}',
            style: GoogleFonts.quicksand(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Image.network(_weather!.iconUrl, width: 100),
          const SizedBox(height: 12),
          Text(
            '${_weather!.temperature}°C',
            style: GoogleFonts.quicksand(
              fontSize: 50,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _weather!.condition,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (_weather != null) {
                await _favoriteService.addFavorite(_weather!.city);
                _loadFavorites();
              }
            },
            icon: const Icon(Icons.star_border),
            label: const Text("Şehri Favorilere Ekle"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.amber[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textStyle: GoogleFonts.quicksand(fontSize: 16),
            ),
          ),
        ],
      );
    }
  }
  bool _isNightTime() {
    final now = DateTime.now().hour;
    return now < 6 || now >= 18;
  }

  Widget _buildForecast() {
    if (_forecast == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _forecast!.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final day = _forecast![index];
            final parsedDate = DateTime.parse(day.date);
            final dayName = DateFormat.EEEE('tr_TR').format(parsedDate);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              width: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.quicksand(
                      color: Colors.blueGrey[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Image.network(day.iconUrl, width: 40),
                  Text(
                    '${day.maxTemp.toInt()}° / ${day.minTemp.toInt()}°',
                    style: GoogleFonts.quicksand(color: Colors.blueGrey[800], fontSize: 14),
                  ),
                  Text(
                    utf8.decode(day.condition.codeUnits),
                    style: GoogleFonts.quicksand(color: Colors.blueGrey[700], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: _isNightTime()
              ? const LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : const LinearGradient(
            colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Hava Durumu',
                      style: GoogleFonts.quicksand(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildWeatherInfo(),
                  _buildForecast(),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _cityController,
                    style: GoogleFonts.quicksand(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Şehir girin...',
                      hintStyle: GoogleFonts.quicksand(color: Colors.white.withOpacity(0.85)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.location_city, color: Colors.white.withOpacity(0.9)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _getWeather,
                    icon: const Icon(Icons.search),
                    label: const Text("Hava Durumunu Getir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: GoogleFonts.quicksand(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_favoriteCities.isNotEmpty) ...[
                    Text(
                      "Favori Şehirler",
                      style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _favoriteCities.map((city) {
                        return GestureDetector(
                          onTap: () {
                            _cityController.text = city;
                            _getWeather();
                          },
                          child: Chip(
                            label: Text(city),
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: GoogleFonts.quicksand(color: Colors.blueGrey[900]),
                            deleteIcon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                            onDeleted: () async {
                              await _favoriteService.removeFavorite(city);
                              _loadFavorites();
                            },
                          ),
                        );
                      }).toList(),
                    )

                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
