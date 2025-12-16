import 'package:firebase_database/firebase_database.dart';
import '../models/station.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  FirebaseService() {
    print('FirebaseService: Initialized with database URL: ${FirebaseDatabase.instance.databaseURL}');
    print('FirebaseService: Database reference: $_database');
  }

  // Helper method to safely convert Firebase data to Map<String, dynamic>
  Map<String, dynamic> _convertToMap(dynamic data) {
    print('_convertToMap: Input type: ${data.runtimeType}');
    print('_convertToMap: Input data: $data');
    
    if (data is Map<String, dynamic>) {
      print('_convertToMap: Already Map<String, dynamic>');
      return data;
    } else if (data is Map) {
      print('_convertToMap: Converting Map to Map<String, dynamic>');
      // Convert Map<Object?, Object?> to Map<String, dynamic>
      Map<String, dynamic> result = {};
      data.forEach((key, value) {
        if (key is String) {
          result[key] = _convertValue(value);
        } else {
          result[key.toString()] = _convertValue(value);
        }
      });
      print('_convertToMap: Converted result: $result');
      return result;
    } else {
      throw Exception('Expected Map but got ${data.runtimeType}');
    }
  }

  // Helper method to convert any Firebase value to proper Dart types
  dynamic _convertValue(dynamic value) {
    if (value is Map) {
      print('_convertValue: Converting nested Map: $value');
      return _convertToMap(value);
    } else if (value is List) {
      print('_convertValue: Converting List: $value');
      return value.map((item) => _convertValue(item)).toList();
    } else {
      return value;
    }
  }

  // Test connection method
  Future<void> testConnection() async {
    print('FirebaseService: Testing connection...');
    try {
      // Test reading from parking_system (which we have permission for)
      print('FirebaseService: Testing parking_system access...');
      final snapshot = await _database.child('parking_system').get();
      print('FirebaseService: Connection test successful');
      print('FirebaseService: Snapshot value: ${snapshot.value}');
      
      // Test writing data to test path
      await _database.child('test').set({
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Test connection'
      });
      print('FirebaseService: Write test successful');
      
      // Clean up test data
      await _database.child('test').remove();
      print('FirebaseService: Test data cleaned up');
      
      // Test setting parking system data
      await setTestParkingSystemData();
      
    } catch (e) {
      print('FirebaseService: Connection test failed: $e');
      // Don't throw the error, just log it
    }
  }

  // Set test parking system data
  Future<void> setTestParkingSystemData() async {
    print('FirebaseService: Setting test parking system data...');
    try {
      await _database.child('parking_system').set({
        'queue': {
          'position_1': true,
          'position_2': false,
          'total_cars': 1
        },
        'charging_station': {
          'occupied': false,
          'car_id': null,
          'charging_start_time': null
        },
        'sensors': {
          'ir_sensor_1': false,
          'ir_sensor_2': false,
          'ir_sensor_3': false,
          'last_update': DateTime.now().toIso8601String()
        },
        'statistics': {
          'total_cars_today': 3,
          'average_charging_time': 25.5,
          'last_reset': DateTime.now().toIso8601String()
        }
      });
      print('FirebaseService: Test parking system data set successfully');
    } catch (e) {
      print('FirebaseService: Failed to set test parking system data: $e');
    }
  }

  // Get real-time parking system data
  Stream<ParkingSystem> getParkingSystemStream() {
    print('FirebaseService: Starting to listen to parking_system stream');
    return _database
        .child('parking_system')
        .onValue
        .map((event) {
      print('FirebaseService: Received event: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        try {
          final data = _convertToMap(event.snapshot.value);
          print('FirebaseService: Parsed data successfully: $data');
          final parkingSystem = ParkingSystem.fromJson(data);
          print('FirebaseService: Created ParkingSystem with totalCars: ${parkingSystem.queue.totalCars}');
          return parkingSystem;
        } catch (e) {
          print('FirebaseService: Error parsing data: $e');
          print('FirebaseService: Raw data type: ${event.snapshot.value.runtimeType}');
          print('FirebaseService: Raw data: ${event.snapshot.value}');
        }
      } else {
        print('FirebaseService: No data received from Firebase');
      }
      // Return default data if no data exists
      return ParkingSystem(
        queue: Queue(position1: false, position2: false, totalCars: 0),
        chargingStation: ChargingStationData(occupied: false),
        sensors: Sensors(irSensor1: false, irSensor2: false, irSensor3: false),
        statistics: Statistics(totalCarsToday: 0, averageChargingTime: 0),
      );
    });
  }

  // Get parking system data once
  Future<ParkingSystem> getParkingSystem() async {
    print('FirebaseService: Getting parking system data once');
    final snapshot = await _database
        .child('parking_system')
        .get();
    
    print('FirebaseService: Snapshot value: ${snapshot.value}');
    if (snapshot.value != null) {
      try {
        final data = _convertToMap(snapshot.value);
        print('FirebaseService: Parsed data: $data');
        return ParkingSystem.fromJson(data);
      } catch (e) {
        print('FirebaseService: Error parsing data: $e');
        print('FirebaseService: Raw data type: ${snapshot.value.runtimeType}');
        print('FirebaseService: Raw data: ${snapshot.value}');
      }
    }
    
    print('FirebaseService: No data found, returning default ParkingSystem');
    // Return default data if no data exists
    return ParkingSystem(
      queue: Queue(position1: false, position2: false, totalCars: 0),
      chargingStation: ChargingStationData(occupied: false),
      sensors: Sensors(irSensor1: false, irSensor2: false, irSensor3: false),
      statistics: Statistics(totalCarsToday: 0, averageChargingTime: 0),
    );
  }

  // Update queue data
  Future<void> updateQueue(Queue queue) async {
    await _database
        .child('parking_system')
        .child('queue')
        .set({
      'position_1': queue.position1,
      'position_2': queue.position2,
      'total_cars': queue.totalCars,
      'position_1_user_id': queue.position1UserId,
      'position_2_user_id': queue.position2UserId,
    });
  }

  // Update charging station data
  Future<void> updateChargingStation(ChargingStationData chargingStation) async {
    await _database
        .child('parking_system')
        .child('charging_station')
        .set({
      'occupied': chargingStation.occupied,
      'car_id': chargingStation.carId,
      'charging_start_time': chargingStation.chargingStartTime?.toIso8601String(),
    });
  }

  // Update sensors data
  Future<void> updateSensors(Sensors sensors) async {
    await _database
        .child('parking_system')
        .child('sensors')
        .set({
      'ir_sensor_1': sensors.irSensor1,
      'ir_sensor_2': sensors.irSensor2,
      'ir_sensor_3': sensors.irSensor3,
      'last_update': DateTime.now().toIso8601String(),
    });
  }

  // Update statistics
  Future<void> updateStatistics(Statistics statistics) async {
    await _database
        .child('parking_system')
        .child('statistics')
        .set({
      'total_cars_today': statistics.totalCarsToday,
      'average_charging_time': statistics.averageChargingTime,
      'last_reset': statistics.lastReset?.toIso8601String(),
    });
  }

  // Book car to queue (only if position available)
  Future<bool> bookCar(String userId) async {
    final parkingSystem = await getParkingSystem();
    final currentQueue = parkingSystem.queue;
    
    // Check if user already has a booking
    if (currentQueue.position1UserId == userId || currentQueue.position2UserId == userId) {
      print('FirebaseService: User $userId already has a booking');
      return false;
    }
    
    // Check if any position is available
    if (currentQueue.position1 && currentQueue.position2) {
      print('FirebaseService: No positions available for booking');
      return false;
    }
    
    int newTotalCars = currentQueue.totalCars + 1;
    bool newPosition1 = currentQueue.position1;
    bool newPosition2 = currentQueue.position2;
    String? newPosition1UserId = currentQueue.position1UserId;
    String? newPosition2UserId = currentQueue.position2UserId;
    
    if (!currentQueue.position1) {
      newPosition1 = true;
      newPosition1UserId = userId;
    } else if (!currentQueue.position2) {
      newPosition2 = true;
      newPosition2UserId = userId;
    }
    
    final updatedQueue = Queue(
      position1: newPosition1,
      position2: newPosition2,
      totalCars: newTotalCars,
      position1UserId: newPosition1UserId,
      position2UserId: newPosition2UserId,
    );
    
    await updateQueue(updatedQueue);
    print('FirebaseService: Successfully booked car for user $userId');
    return true;
  }

  // Unbook car from queue (only if user owns the booking)
  Future<bool> unbookCar(String userId) async {
    final parkingSystem = await getParkingSystem();
    final currentQueue = parkingSystem.queue;
    
    // Check if user has a booking to unbook
    if (currentQueue.position1UserId != userId && currentQueue.position2UserId != userId) {
      print('FirebaseService: User $userId has no booking to unbook');
      return false;
    }
    
    int newTotalCars = (currentQueue.totalCars - 1).clamp(0, 2);
    bool newPosition1 = currentQueue.position1;
    bool newPosition2 = currentQueue.position2;
    String? newPosition1UserId = currentQueue.position1UserId;
    String? newPosition2UserId = currentQueue.position2UserId;
    
    if (currentQueue.position1UserId == userId) {
      newPosition1 = false;
      newPosition1UserId = null;
    } else if (currentQueue.position2UserId == userId) {
      newPosition2 = false;
      newPosition2UserId = null;
    }
    
    final updatedQueue = Queue(
      position1: newPosition1,
      position2: newPosition2,
      totalCars: newTotalCars,
      position1UserId: newPosition1UserId,
      position2UserId: newPosition2UserId,
    );
    
    await updateQueue(updatedQueue);
    print('FirebaseService: Successfully unbooked car for user $userId');
    return true;
  }

  // Check if user can book (has no existing booking and position available)
  Future<bool> canUserBook(String userId) async {
    final parkingSystem = await getParkingSystem();
    final currentQueue = parkingSystem.queue;
    
    // User already has a booking
    if (currentQueue.position1UserId == userId || currentQueue.position2UserId == userId) {
      return false;
    }
    
    // No positions available
    if (currentQueue.position1 && currentQueue.position2) {
      return false;
    }
    
    return true;
  }

  // Check if user can unbook (has an existing booking)
  Future<bool> canUserUnbook(String userId) async {
    final parkingSystem = await getParkingSystem();
    final currentQueue = parkingSystem.queue;
    
    return currentQueue.position1UserId == userId || currentQueue.position2UserId == userId;
  }

  // Get user's booking status
  Future<Map<String, dynamic>> getUserBookingStatus(String userId) async {
    final parkingSystem = await getParkingSystem();
    final currentQueue = parkingSystem.queue;
    
    bool hasBooking = currentQueue.position1UserId == userId || currentQueue.position2UserId == userId;
    int? position = null;
    
    if (currentQueue.position1UserId == userId) {
      position = 1;
    } else if (currentQueue.position2UserId == userId) {
      position = 2;
    }
    
    return {
      'hasBooking': hasBooking,
      'position': position,
      'canBook': !hasBooking && (!currentQueue.position1 || !currentQueue.position2),
    };
  }

  // Start charging
  Future<void> startCharging(String carId) async {
    final chargingStation = ChargingStationData(
      occupied: true,
      carId: carId,
      chargingStartTime: DateTime.now(),
    );
    
    await updateChargingStation(chargingStation);
  }

  // Stop charging
  Future<void> stopCharging() async {
    final chargingStation = ChargingStationData(
      occupied: false,
      carId: null,
      chargingStartTime: null,
    );
    
    await updateChargingStation(chargingStation);
  }

  // Test different database paths
  Future<void> testDatabasePaths() async {
    print('FirebaseService: Testing different database paths...');
    
    final paths = [
      'parking_system',
      'parking_system/queue',
      'parking_system/queue/total_cars',
      'test',
    ];
    
    for (final path in paths) {
      try {
        final ref = _database.child(path);
        final snapshot = await ref.get();
        print('FirebaseService: Path "$path" - Success: ${snapshot.value}');
      } catch (e) {
        print('FirebaseService: Path "$path" - Failed: $e');
      }
    }
  }
} 