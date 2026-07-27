import 'package:flutter/material.dart';
import '../models/charging_station.dart';
import '../services/ocm_service.dart';

class StationProvider extends ChangeNotifier{
  final OcmService _service= OcmService();

  List<ChargingStation> stations=[];
  bool isLoading= false;
  String? errorMessage;

  Future<void> loadnearbyStations({
    required double latitude,
    required double longtitude,
  }) async{
    isLoading=true;
    errorMessage=null;
    notifyListeners();

    try{
      stations =await _service.fetchNearbyStations(
        latitude:latitude,
        longtitude:longtitude,
      );
    }
    catch(e){
      errorMessage = e.toString();
    }
    isLoading=false;
    notifyListeners();
  }
}