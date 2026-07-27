import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

class OcmService{
  static const String _baseUrl = 'https://api.openchargemap.io/v3/poi/';
  Future<List<ChargingStation>> fetchNearbyStations({
    required double latitude,
    required double longtitude,
    double distanceKm= 15,
    int maxResults= 50,
  }) async{
    final url= Uri.parse(
       '$_baseUrl?output=json&latitude=$latitude&longitude=$longitude&distance=$distanceKm&maxresults=$maxResults',
    );
    final response= await http.get(url);
  }

}