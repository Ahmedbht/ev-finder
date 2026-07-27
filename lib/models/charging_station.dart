class ChargingStation {
  final int id;
  final String name;
  final String? address;
  final String? town;
  final double latitude;
  final double longitude;
  final List<String> connectorTypes;
  final int numberOfPoints;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.town,
    required this.latitude,
    required this.longitude,
    required this.connectorTypes,
    required this.numberOfPoints,
  });

  factory ChargingStation.fromJson(Map<String, dynamic>json){
    final addressInfo= json['AddressInfo'] ?? {};
    final connections= json['Connections'] as List<dynamic>? ?? [];

    return ChargingStation(
      id: json['ID'],
      name: addressInfo['Title'] ?? 'Unknown Station',
      address: addressInfo['AddressLine1'] ?? 'Unknown Address',
      town: addressInfo['Town'] ?? 'Unknown Town',
      latitude: (addressInfo['Latitude'] ?? 0).toDouble(),
      longitude: (addressInfo['Longitude'] ?? 0).toDouble(),
      connectorTypes: connections.map((c) => (c['ConnectionType']?['Title'] ?? 'Unknown') as String).toSet().toList(),
      numberOfPoints: connections.length,
    );
  }
}