import 'package:flutter/material.dart';
import '../models/station.dart';

class StationMarker extends StatelessWidget {
  final ChargingStation station;
  final bool showQueueCount;

  const StationMarker({
    super.key,
    required this.station,
    this.showQueueCount = false,
  });

  @override
  Widget build(BuildContext context) {
    print('StationMarker: Building marker for station ${station.id}');
    print('StationMarker: - waitingVehicles: ${station.waitingVehicles}');
    print('StationMarker: - isCharging: ${station.isCharging}');
    print('StationMarker: - position1: ${station.parkingSystem.queue.position1}');
    print('StationMarker: - position2: ${station.parkingSystem.queue.position2}');
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showQueueCount)
          Container(
            constraints: const BoxConstraints(maxWidth: 90),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Queue: ${station.waitingVehicles}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (station.waitingVehicles > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPositionIndicator(1, station.parkingSystem.queue.position1),
                      const SizedBox(width: 3),
                      _buildPositionIndicator(2, station.parkingSystem.queue.position2),
                    ],
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 3),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              station.imageAsset,
              width: 45,
              height: 45,
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: station.isCharging ? Colors.green : Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${station.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPositionIndicator(int position, bool isOccupied) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isOccupied ? Colors.red : Colors.green,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
    );
  }
}
