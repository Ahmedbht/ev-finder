import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';
import '../config/api_config.dart';

class OcmService {
  static const String _baseUrl = 'https://api.openchargemap.io/v3/poi/';
  static const Map<String, String> _headers = {
    'User-Agent': 'ev-finder-flutter-app/1.0',
    'Accept': 'application/json',
  };

  Future<List<ChargingStation>> fetchNearbyStations({
    required double latitude,
    required double longitude,
    double distanceKm = 15,
    int maxResults = 50,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?output=json&latitude=$latitude&longitude=$longitude&distance=$distanceKm&maxresults=$maxResults&key=${ApiConfig.ocmApiKey}',
    );

    const transientStatusCodes = {500, 502, 503, 504};
    const maxAttempts = 3;
    http.Response? response;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => ChargingStation.fromJson(json)).toList();
      }

      debugPrint(
        'OCM request failed (attempt $attempt/$maxAttempts): '
        '${response.statusCode} ${response.reasonPhrase}\n'
        'Headers: ${response.headers}\n'
        'Body: ${response.body}',
      );

      final isTransient = transientStatusCodes.contains(response.statusCode);
      if (!isTransient || attempt == maxAttempts) {
        throw Exception(
          'Failed to fetch charging stations: ${response.statusCode}',
        );
      }

      await Future.delayed(Duration(seconds: attempt));
    }

    throw Exception(
      'Failed to fetch charging stations: ${response?.statusCode}',
    );
  }
}
