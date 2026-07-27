import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/station_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Default center point: Tétouan, Morocco
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
                          child: const Icon(
                            Icons.ev_station,
                            color: Colors.green,
                            size: 32,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
    );
  }
}