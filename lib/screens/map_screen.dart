import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/station_provider.dart';

class MapScreen extends StatefulWidget{
  const MapScreen({super.key});
  @override
  State<MapScreen> createState()=> _MapScreenState();
}

class _MapScreenState extends State<MapScreen>{
  final LatLng _defaultCenter= const LatLng(35.5785, -5.3684);

  @override
  void initState(){
    super.initState();
    Future.microtask((){
      Provider .of<StationProvider>(context, listen: false).loadNearbyStations(
        latitude: _defaultCenter.latitude,
        longtitude: _defaultCenter.longitude,
      );
    });
  }

  
}