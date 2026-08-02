import 'package:shared_preferences/shared_preferences.dart';
class FavoritesService{
  static const String _key = 'favorite_station_ids';
  Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    return saved.map((id) => int.parse(id)).toList();
  }

  Future<void> toggleFavorite(int stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    final idStr = stationId.toString();

    if (saved.contains(idStr)){
      saved.remove(idStr);
    } else {
      saved.add(idStr);
    }
    await prefs.setStringList(_key, saved);
  }

  Future<bool> isFavorite(int stationId) async {
    final ids = await getFavoriteIds();
    return ids.contains(stationId);
  }
}