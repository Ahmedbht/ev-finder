import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

class OcmService {
  static const String _baseUrl = 'https://api.openchargemap.io/v3/poi/';

  Future<List<ChargingStation>> fetchNearbyStations({
    required double latitude,
    required double longitude,
    double distanceKm = 15,
    int maxResults = 50,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?output=json&latitude=$latitude&longitude=$longitude&distance=$distanceKm&maxresults=$maxResults',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ChargingStation.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch charging stations: ${response.statusCode}',
      );
    }
  }
}
