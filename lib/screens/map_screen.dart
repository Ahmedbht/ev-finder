import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/station_provider.dart';
import '../models/charging_station.dart';
import '../services/favorites_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _defaultCenter = const LatLng(35.5785, -5.3684);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StationProvider>(context, listen: false).loadNearbyStations(
        latitude: _defaultCenter.latitude,
        longitude: _defaultCenter.longitude,
      );
    });
  }

  void _showStationDetails(ChargingStation station) {
    final favoritesService = FavoritesService();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<bool>(
              future: favoritesService.isFavorite(station.id),
              builder: (context, snapshot) {
                final isFav = snapshot.data ?? false;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              station.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () async {
                              await favoritesService.toggleFavorite(station.id);
                              setModalState(() {}); // refresh this bottom sheet's content
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (station.address != null)
                        Text("${station.address}, ${station.town ?? ''}"),
                      const SizedBox(height: 12),
                      Text("Connectors: ${station.connectorTypes.join(', ')}"),
                      const SizedBox(height: 4),
                      Text("Charging points: ${station.numberOfPoints}"),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationProvider = Provider.of<StationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("EV Charging Stations")),
      body: stationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : stationProvider.errorMessage != null
              ? Center(child: Text("Error: ${stationProvider.errorMessage}"))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.ev_finder',
                    ),
                    MarkerLayer(
                      markers: stationProvider.stations.map((station) {
                        return Marker(
                          point: LatLng(station.latitude, station.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showStationDetails(station),
                            child: const Icon(
                              Icons.ev_station,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
    );
  }
}