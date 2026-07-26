class ChargingStation {
  final int id;
  final String name;
  final String address;
  final String town;
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
    final addressInfo= json['AdressInfo'] ?? {};
    final connections= json['Connections'] as List<dynamic>? ?? [];

    return ChargingStation(
      id: json['ID'],
      name: addressInfo['title'] ?? 'Unknown Station',
      address: addressInfo['AdressLine1'],
      town: addressInfo['Town']
      
    )
  }
}