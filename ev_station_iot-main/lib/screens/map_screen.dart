import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/stations_provider.dart';
import '../widgets/station_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StationsProvider>(
      builder: (context, stationsProvider, child) {
        final stations = stationsProvider.stations;
        
        print('MapScreen: Rebuilding with ${stations.length} stations');
        for (final station in stations) {
          print('MapScreen: Station ${station.id} - waitingVehicles: ${station.waitingVehicles}, isCharging: ${station.isCharging}');
        }

        return SizedBox.expand(
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(22.5406, 72.9279), // Center between Anand and Karamsad, Gujarat
              zoom: 12, // Slightly zoomed out to show both locations
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.evchargingapp',
              ),
              MarkerLayer(
                markers: [
                  for (final station in stations)
                    Marker(
                      point: station.location,
                      width: 100,
                      height: 100,
                      child: StationMarker(
                        station: station,
                        showQueueCount: true,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
