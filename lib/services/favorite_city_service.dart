import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCityService {
  static const String _key = 'favoriteCities';

  /// Favori şehirleri getir
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Yeni şehir ekle
  Future<void> addFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    if (!current.contains(city)) {
      current.add(city);
      await prefs.setStringList(_key, current);
    }
  }

  /// Favori şehirden sil
  Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove(city);
    await prefs.setStringList(_key, current);
  }

  /// Tüm favorileri temizle (isteğe bağlı)
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
