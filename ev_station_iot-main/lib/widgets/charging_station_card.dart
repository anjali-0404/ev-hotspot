import 'package:flutter/material.dart';
import '../models/station.dart';

class ChargingStationCard extends StatelessWidget {
  final ChargingStation station;

  const ChargingStationCard({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    print('ChargingStationCard: Rebuilding for station ${station.id}');
    print('ChargingStationCard: - waitingVehicles: ${station.waitingVehicles}');
    print('ChargingStationCard: - isCharging: ${station.isCharging}');
    print('ChargingStationCard: - queue totalCars: ${station.parkingSystem.queue.totalCars}');

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(station.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 22 : 18)),
            const SizedBox(height: 14),
            
            // Queue Information
            _buildQueueSection(isTablet),
            const SizedBox(height: 16),
            
            // Charging Station Status
            _buildChargingStationSection(isTablet),
            const SizedBox(height: 16),
            
            // Sensor Status
            _buildSensorSection(isTablet),
            const SizedBox(height: 16),
            
            // Statistics
            _buildStatisticsSection(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueSection(bool isTablet) {
    final queue = station.parkingSystem.queue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Queue Status', 
            style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isTablet ? 18 : 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(station.imageAsset,
                  width: isTablet ? 70 : 50,
                  height: isTablet ? 70 : 50,
                  fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Cars: ${queue.totalCars}',
                      style: const TextStyle(fontSize: 16)),
                  Text('Position 1: ${queue.position1 ? "Occupied" : "Available"}',
                      style: TextStyle(
                          color: queue.position1 ? Colors.red : Colors.green)),
                  Text('Position 2: ${queue.position2 ? "Occupied" : "Available"}',
                      style: TextStyle(
                          color: queue.position2 ? Colors.red : Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChargingStationSection(bool isTablet) {
    final chargingStation = station.parkingSystem.chargingStation;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Charging Station', 
            style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isTablet ? 18 : 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: isTablet ? 70 : 50,
              height: isTablet ? 70 : 50,
              decoration: BoxDecoration(
                color: chargingStation.occupied ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                chargingStation.occupied ? Icons.ev_station : Icons.ev_station_outlined,
                color: Colors.white,
                size: isTablet ? 35 : 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      chargingStation.occupied ? 'Currently Charging' : 'Available',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: chargingStation.occupied ? Colors.green : Colors.grey)),
                  if (chargingStation.carId != null)
                    Text('Car ID: ${chargingStation.carId}',
                        style: const TextStyle(color: Colors.grey)),
                  if (chargingStation.chargingStartTime != null)
                    Text('Started: ${_formatTime(chargingStation.chargingStartTime!)}',
                        style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chargingStation.occupied ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chargingStation.occupied ? 'Charging' : 'Available',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: chargingStation.occupied ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorSection(bool isTablet) {
    final sensors = station.parkingSystem.sensors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor Status', 
            style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isTablet ? 18 : 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSensorIndicator('IR 1', sensors.irSensor1, isTablet),
            const SizedBox(width: 8),
            _buildSensorIndicator('IR 2', sensors.irSensor2, isTablet),
            const SizedBox(width: 8),
            _buildSensorIndicator('IR 3', sensors.irSensor3, isTablet),
          ],
        ),
        if (sensors.lastUpdate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Last Update: ${_formatTime(sensors.lastUpdate!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildSensorIndicator(String label, bool isActive, bool isTablet) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.green : Colors.grey,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isActive ? Icons.sensors : Icons.sensors_off,
              color: isActive ? Colors.green : Colors.grey,
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(bool isTablet) {
    final statistics = station.parkingSystem.statistics;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Statistics', 
            style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isTablet ? 18 : 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Cars',
                '${statistics.totalCarsToday}',
                Icons.directions_car,
                Colors.blue,
                isTablet,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Avg Time',
                '${statistics.averageChargingTime.toStringAsFixed(1)}m',
                Icons.timer,
                Colors.orange,
                isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isTablet ? 24 : 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}