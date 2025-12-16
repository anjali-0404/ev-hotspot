import 'package:latlong2/latlong.dart';

class ChargingStation {
  final int id;
  final String name;
  final LatLng location;
  final String imageAsset;
  final ParkingSystem parkingSystem;

  ChargingStation({
    required this.id,
    required this.name,
    required this.location,
    required this.imageAsset,
    required this.parkingSystem,
  });

  int get waitingVehicles => parkingSystem.queue.totalCars;
  bool get isCharging => parkingSystem.chargingStation.occupied;

  ChargingStation copyWith({
    int? id,
    String? name,
    LatLng? location,
    String? imageAsset,
    ParkingSystem? parkingSystem,
  }) {
    return ChargingStation(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      imageAsset: imageAsset ?? this.imageAsset,
      parkingSystem: parkingSystem ?? this.parkingSystem,
    );
  }
}

class ParkingSystem {
  final Queue queue;
  final ChargingStationData chargingStation;
  final Sensors sensors;
  final Statistics statistics;

  ParkingSystem({
    required this.queue,
    required this.chargingStation,
    required this.sensors,
    required this.statistics,
  });

  factory ParkingSystem.fromJson(Map<String, dynamic> json) {
    try {
      print('ParkingSystem.fromJson: Parsing queue...');
      final queue = Queue.fromJson(json['queue'] ?? {});
      print('ParkingSystem.fromJson: Queue parsed - totalCars: ${queue.totalCars}');
      
      print('ParkingSystem.fromJson: Parsing charging_station...');
      final chargingStation = ChargingStationData.fromJson(json['charging_station'] ?? {});
      print('ParkingSystem.fromJson: Charging station parsed - occupied: ${chargingStation.occupied}');
      
      print('ParkingSystem.fromJson: Parsing sensors...');
      final sensors = Sensors.fromJson(json['sensors'] ?? {});
      print('ParkingSystem.fromJson: Sensors parsed');
      
      print('ParkingSystem.fromJson: Parsing statistics...');
      final statistics = Statistics.fromJson(json['statistics'] ?? {});
      print('ParkingSystem.fromJson: Statistics parsed');
      
      return ParkingSystem(
        queue: queue,
        chargingStation: chargingStation,
        sensors: sensors,
        statistics: statistics,
      );
    } catch (e) {
      print('ParkingSystem.fromJson: Error parsing data: $e');
      print('ParkingSystem.fromJson: JSON data: $json');
      rethrow;
    }
  }
}

class Queue {
  final bool position1;
  final bool position2;
  final int totalCars;
  final String? position1UserId;
  final String? position2UserId;

  Queue({
    required this.position1,
    required this.position2,
    required this.totalCars,
    this.position1UserId,
    this.position2UserId,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    try {
      print('Queue.fromJson: Raw JSON: $json');
      
      // Handle position_1 and position_2
      final position1 = json['position_1'] ?? false;
      final position2 = json['position_2'] ?? false;
      
      // Handle total_cars with proper type conversion
      dynamic totalCarsRaw = json['total_cars'] ?? 0;
      int totalCars;
      if (totalCarsRaw is int) {
        totalCars = totalCarsRaw;
      } else if (totalCarsRaw is String) {
        totalCars = int.tryParse(totalCarsRaw) ?? 0;
      } else if (totalCarsRaw is double) {
        totalCars = totalCarsRaw.toInt();
      } else {
        totalCars = 0;
      }
      
      // Handle user IDs
      final position1UserId = json['position_1_user_id'];
      final position2UserId = json['position_2_user_id'];
      
      print('Queue.fromJson: Parsed values - position1: $position1, position2: $position2, totalCars: $totalCars (raw: $totalCarsRaw)');
      print('Queue.fromJson: User IDs - position1: $position1UserId, position2: $position2UserId');
      
      return Queue(
        position1: position1,
        position2: position2,
        totalCars: totalCars,
        position1UserId: position1UserId,
        position2UserId: position2UserId,
      );
    } catch (e) {
      print('Queue.fromJson: Error parsing queue: $e');
      print('Queue.fromJson: JSON data: $json');
      rethrow;
    }
  }
}

class ChargingStationData {
  final bool occupied;
  final String? carId;
  final DateTime? chargingStartTime;

  ChargingStationData({
    required this.occupied,
    this.carId,
    this.chargingStartTime,
  });

  factory ChargingStationData.fromJson(Map<String, dynamic> json) {
    return ChargingStationData(
      occupied: json['occupied'] ?? false,
      carId: json['car_id'],
      chargingStartTime: json['charging_start_time'] != null 
          ? DateTime.tryParse(json['charging_start_time']) 
          : null,
    );
  }
}

class Sensors {
  final bool irSensor1;
  final bool irSensor2;
  final bool irSensor3;
  final DateTime? lastUpdate;

  Sensors({
    required this.irSensor1,
    required this.irSensor2,
    required this.irSensor3,
    this.lastUpdate,
  });

  factory Sensors.fromJson(Map<String, dynamic> json) {
    try {
      print('Sensors.fromJson: Raw JSON: $json');
      
      // Handle boolean sensor values
      final irSensor1 = json['ir_sensor_1'] ?? false;
      final irSensor2 = json['ir_sensor_2'] ?? false;
      final irSensor3 = json['ir_sensor_3'] ?? false;
      
      // Handle last_update with proper type conversion
      dynamic lastUpdateRaw = json['last_update'];
      DateTime? lastUpdate;
      if (lastUpdateRaw != null) {
        if (lastUpdateRaw is int) {
          lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateRaw * 1000);
        } else if (lastUpdateRaw is String) {
          // Try parsing as timestamp first
          int? timestamp = int.tryParse(lastUpdateRaw);
          if (timestamp != null) {
            lastUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          } else {
            // Try parsing as ISO string
            lastUpdate = DateTime.tryParse(lastUpdateRaw);
          }
        } else if (lastUpdateRaw is double) {
          lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateRaw.toInt() * 1000);
        }
      }
      
      print('Sensors.fromJson: Parsed values - ir1: $irSensor1, ir2: $irSensor2, ir3: $irSensor3, lastUpdate: $lastUpdate (raw: $lastUpdateRaw)');
      
      return Sensors(
        irSensor1: irSensor1,
        irSensor2: irSensor2,
        irSensor3: irSensor3,
        lastUpdate: lastUpdate,
      );
    } catch (e) {
      print('Sensors.fromJson: Error parsing sensors: $e');
      print('Sensors.fromJson: JSON data: $json');
      rethrow;
    }
  }
}

class Statistics {
  final int totalCarsToday;
  final double averageChargingTime;
  final DateTime? lastReset;

  Statistics({
    required this.totalCarsToday,
    required this.averageChargingTime,
    this.lastReset,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    try {
      print('Statistics.fromJson: Raw JSON: $json');
      
      // Handle total_cars_today with proper type conversion
      dynamic totalCarsTodayRaw = json['total_cars_today'] ?? 0;
      int totalCarsToday;
      if (totalCarsTodayRaw is int) {
        totalCarsToday = totalCarsTodayRaw;
      } else if (totalCarsTodayRaw is String) {
        totalCarsToday = int.tryParse(totalCarsTodayRaw) ?? 0;
      } else if (totalCarsTodayRaw is double) {
        totalCarsToday = totalCarsTodayRaw.toInt();
      } else {
        totalCarsToday = 0;
      }
      
      // Handle average_charging_time with proper type conversion
      dynamic avgTimeRaw = json['average_charging_time'] ?? 0;
      double averageChargingTime;
      if (avgTimeRaw is double) {
        averageChargingTime = avgTimeRaw;
      } else if (avgTimeRaw is int) {
        averageChargingTime = avgTimeRaw.toDouble();
      } else if (avgTimeRaw is String) {
        averageChargingTime = double.tryParse(avgTimeRaw) ?? 0.0;
      } else {
        averageChargingTime = 0.0;
      }
      
      // Handle last_reset
      final lastReset = json['last_reset'] != null 
          ? DateTime.tryParse(json['last_reset']) 
          : null;
      
      print('Statistics.fromJson: Parsed values - totalCarsToday: $totalCarsToday (raw: $totalCarsTodayRaw), averageChargingTime: $averageChargingTime (raw: $avgTimeRaw)');
      
      return Statistics(
        totalCarsToday: totalCarsToday,
        averageChargingTime: averageChargingTime,
        lastReset: lastReset,
      );
    } catch (e) {
      print('Statistics.fromJson: Error parsing statistics: $e');
      print('Statistics.fromJson: JSON data: $json');
      rethrow;
    }
  }
}