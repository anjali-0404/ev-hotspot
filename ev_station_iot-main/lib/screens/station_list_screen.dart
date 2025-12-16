import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stations_provider.dart';
import '../widgets/charging_station_card.dart';
import 'station_detail_screen.dart';

class StationListScreen extends StatelessWidget {
  const StationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Consumer<StationsProvider>(
      builder: (context, stationsProvider, child) {
        final stations = stationsProvider.stations;
        
        print('StationListScreen: Rebuilding with ${stations.length} stations');
        for (final station in stations) {
          print('StationListScreen: Station ${station.id} - waitingVehicles: ${station.waitingVehicles}, isCharging: ${station.isCharging}');
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          itemCount: stations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final station = stations[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationDetailScreen(station: station),
                  ),
                );
              },
              child: ChargingStationCard(
                station: station,
              ),
            );
          },
        );
      },
    );
  }
}