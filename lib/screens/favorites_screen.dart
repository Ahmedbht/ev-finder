import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/station_provider.dart';
import '../services/favorites_service.dart';
import '../models/charging_station.dart';
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<int> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoritesService.getFavoriteIds();
    setState(() {
      _favoriteIds = ids;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stationProvider = Provider.of<StationProvider>(context);

    // Match favorite IDs against the full list of stations already loaded
    final List<ChargingStation> favoriteStations = stationProvider.stations
        .where((station) => _favoriteIds.contains(station.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: favoriteStations.isEmpty
          ? const Center(child: Text("No favorite stations yet"))
          : ListView.builder(
              itemCount: favoriteStations.length,
              itemBuilder: (context, index) {
                final station = favoriteStations[index];
                return ListTile(
                  leading: const Icon(Icons.ev_station, color: Colors.green),
                  title: Text(station.name),
                  subtitle: Text(station.address ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: () async {
                      await _favoritesService.toggleFavorite(station.id);
                      _loadFavorites(); // refresh the list after removing
                    },
                  ),
                );
              },
            ),
    );
  }
}