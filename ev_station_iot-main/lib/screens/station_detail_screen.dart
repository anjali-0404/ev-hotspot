import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/stations_provider.dart';

class StationDetailScreen extends StatelessWidget {
  final ChargingStation station;

  const StationDetailScreen({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    final stationsProvider = Provider.of<StationsProvider>(context);
    final currentStation = stationsProvider.getStationById(station.id) ?? station;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentStation.name} Details'),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station Header
            _buildStationHeader(currentStation),
            const SizedBox(height: 24),
            
            // Queue Management
            _buildQueueManagementSection(context, currentStation, stationsProvider),
            const SizedBox(height: 24),
            
            // Charging Station Control
            _buildChargingControlSection(context, currentStation, stationsProvider),
            const SizedBox(height: 24),
            
            // Sensor Status
            _buildSensorStatusSection(currentStation),
            const SizedBox(height: 24),
            
            // Statistics
            _buildStatisticsSection(currentStation),
          ],
        ),
      ),
    );
  }

  Widget _buildStationHeader(ChargingStation station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                station.imageAsset,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${station.location.latitude.toStringAsFixed(4)}, ${station.location.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: station.isCharging ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      station.isCharging ? 'Currently Charging' : 'Available',
                      style: TextStyle(
                        color: station.isCharging ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueManagementSection(BuildContext context, ChargingStation station, StationsProvider provider) {
    final queue = station.parkingSystem.queue;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Queue Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${queue.totalCars}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Queue Positions
            Row(
              children: [
                Expanded(
                  child: _buildQueuePositionCard(
                    'Position 1',
                    queue.position1,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQueuePositionCard(
                    'Position 2',
                    queue.position2,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Queue Actions
            Consumer<StationsProvider>(
              builder: (context, provider, child) {
                final userStatus = provider.userBookingStatus;
                final canBook = userStatus?['canBook'] ?? false;
                final hasBooking = userStatus?['hasBooking'] ?? false;
                
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canBook ? () async {
                          final success = await provider.bookCar();
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to book car')),
                            );
                          }
                        } : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Book Car'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: hasBooking ? () async {
                          final success = await provider.unbookCar();
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to unbook car')),
                            );
                          }
                        } : null,
                        icon: const Icon(Icons.remove),
                        label: const Text('Unbook Car'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueuePositionCard(String title, bool isOccupied, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOccupied ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOccupied ? color : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isOccupied ? Icons.directions_car : Icons.directions_car_outlined,
            color: isOccupied ? color : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOccupied ? color : Colors.grey,
            ),
          ),
          Text(
            isOccupied ? 'Occupied' : 'Available',
            style: TextStyle(
              color: isOccupied ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingControlSection(BuildContext context, ChargingStation station, StationsProvider provider) {
    final chargingStation = station.parkingSystem.chargingStation;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Charging Station Control',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Current Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: chargingStation.occupied ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: chargingStation.occupied ? Colors.green : Colors.grey,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        chargingStation.occupied ? Icons.ev_station : Icons.ev_station_outlined,
                        color: chargingStation.occupied ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chargingStation.occupied ? 'Currently Charging' : 'Station Available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: chargingStation.occupied ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (chargingStation.carId != null) ...[
                    const SizedBox(height: 8),
                    Text('Car ID: ${chargingStation.carId}'),
                  ],
                  if (chargingStation.chargingStartTime != null) ...[
                    const SizedBox(height: 8),
                    Text('Started: ${_formatDateTime(chargingStation.chargingStartTime!)}'),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !chargingStation.occupied 
                        ? () => _showStartChargingDialog(context, provider)
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Charging'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: chargingStation.occupied 
                        ? () => provider.stopCharging()
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Charging'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorStatusSection(ChargingStation station) {
    final sensors = station.parkingSystem.sensors;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSensorCard('IR Sensor 1', sensors.irSensor1, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSensorCard('IR Sensor 2', sensors.irSensor2, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSensorCard('IR Sensor 3', sensors.irSensor3, Colors.orange),
                ),
              ],
            ),
            
            if (sensors.lastUpdate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Last Update: ${_formatDateTime(sensors.lastUpdate!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.grey,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isActive ? Icons.sensors : Icons.sensors_off,
            color: isActive ? color : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey,
            ),
          ),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ChargingStation station) {
    final statistics = station.parkingSystem.statistics;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Cars',
                    '${statistics.totalCarsToday}',
                    Icons.directions_car,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Charging Time',
                    '${statistics.averageChargingTime.toStringAsFixed(1)}m',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            if (statistics.lastReset != null) ...[
              const SizedBox(height: 16),
              Text(
                'Last Reset: ${_formatDateTime(statistics.lastReset!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartChargingDialog(BuildContext context, StationsProvider provider) {
    final carIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Charging'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Car ID:'),
            const SizedBox(height: 8),
            TextField(
              controller: carIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., CAR001',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (carIdController.text.isNotEmpty) {
                provider.startCharging(carIdController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}