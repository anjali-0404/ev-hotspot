import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

import '../models/station.dart';
import '../services/firebase_service.dart';

class StationsProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<ChargingStation> _stations = [];
  StreamSubscription<ParkingSystem>? _parkingSystemSubscription;
  ParkingSystem _currentParkingSystem = ParkingSystem(
    queue: Queue(position1: false, position2: false, totalCars: 0),
    chargingStation: ChargingStationData(occupied: false),
    sensors: Sensors(irSensor1: false, irSensor2: false, irSensor3: false),
    statistics: Statistics(totalCarsToday: 0, averageChargingTime: 0),
  );
  
  // User management
  String? _currentUserId;
  Map<String, dynamic>? _userBookingStatus;

  StationsProvider() {
    _initializeStations();
    _testFirebaseConnection();
    _startListeningToParkingSystem();
    _initializeUser();
  }

  void _initializeStations() {
    _stations = [
      ChargingStation(
        id: 1,
        name: 'Station 1',
        location: LatLng(22.5533, 72.9244), // Anand, Gujarat
        imageAsset: 'lib/assets/images/1.jpg',
        parkingSystem: _currentParkingSystem,
      ),
    ];
  }

  void _testFirebaseConnection() async {
    print('StationsProvider: Testing Firebase connection...');
    await _firebaseService.testConnection();
    await _firebaseService.testDatabasePaths();
  }

  void _startListeningToParkingSystem() {
    // Cancel existing subscription if any
    _parkingSystemSubscription?.cancel();
    
    print('StationsProvider: Starting to listen to parking system');
    // Start new subscription
    _parkingSystemSubscription = _firebaseService
        .getParkingSystemStream()
        .listen((parkingSystem) {
      print('StationsProvider: Received update - totalCars: ${parkingSystem.queue.totalCars}');
      _currentParkingSystem = parkingSystem;
      _updateAllStationsParkingSystem(parkingSystem);
    }, onError: (error) {
      print('StationsProvider: Error listening to parking system: $error');
      print('StationsProvider: Error type: ${error.runtimeType}');
      print('StationsProvider: Error details: $error');
    }, onDone: () {
      print('StationsProvider: Stream completed');
    });
    
    print('StationsProvider: Stream subscription created');
  }

  void _updateAllStationsParkingSystem(ParkingSystem parkingSystem) {
    for (int i = 0; i < _stations.length; i++) {
      _stations[i] = _stations[i].copyWith(parkingSystem: parkingSystem);
    }
    notifyListeners();
    print('StationsProvider: Updated all stations with totalCars: ${parkingSystem.queue.totalCars}');
    _updateUserBookingStatus(); // Update user booking status when data changes
  }

  List<ChargingStation> get stations => _stations;

  ChargingStation? getStationById(int id) {
    try {
      return _stations.firstWhere((station) => station.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveNodeMcuIp(int stationId, String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nodeMcuIp_$stationId', ip);
    notifyListeners();
  }

  Future<String?> getNodeMcuIp(int stationId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nodeMcuIp_$stationId');
  }

  // Firebase operations
  Future<bool> bookCar() async {
    if (_currentUserId == null) {
      print('StationsProvider: No user ID available for booking');
      return false;
    }
    
    final success = await _firebaseService.bookCar(_currentUserId!);
    if (success) {
      print('StationsProvider: Successfully booked car for user $_currentUserId');
    } else {
      print('StationsProvider: Failed to book car for user $_currentUserId');
    }
    return success;
  }

  Future<bool> unbookCar() async {
    if (_currentUserId == null) {
      print('StationsProvider: No user ID available for unbooking');
      return false;
    }
    
    final success = await _firebaseService.unbookCar(_currentUserId!);
    if (success) {
      print('StationsProvider: Successfully unbooked car for user $_currentUserId');
    } else {
      print('StationsProvider: Failed to unbook car for user $_currentUserId');
    }
    return success;
  }

  Future<bool> canUserBook() async {
    if (_currentUserId == null) return false;
    return await _firebaseService.canUserBook(_currentUserId!);
  }

  Future<bool> canUserUnbook() async {
    if (_currentUserId == null) return false;
    return await _firebaseService.canUserUnbook(_currentUserId!);
  }

  Future<void> startCharging(String carId) async {
    await _firebaseService.startCharging(carId);
  }

  Future<void> stopCharging() async {
    await _firebaseService.stopCharging();
  }

  Future<void> updateSensors(Sensors sensors) async {
    await _firebaseService.updateSensors(sensors);
  }

  Future<void> updateStatistics(Statistics statistics) async {
    await _firebaseService.updateStatistics(statistics);
  }

  @override
  void dispose() {
    // Cancel subscription
    _parkingSystemSubscription?.cancel();
    super.dispose();
  }

  void _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
    if (_currentUserId == null) {
      // Generate a unique user ID if none exists
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('user_id', _currentUserId!);
    }
    print('StationsProvider: Current user ID: $_currentUserId');
    _updateUserBookingStatus();
  }

  String? get currentUserId => _currentUserId;
  Map<String, dynamic>? get userBookingStatus => _userBookingStatus;

  Future<void> _updateUserBookingStatus() async {
    if (_currentUserId != null) {
      _userBookingStatus = await _firebaseService.getUserBookingStatus(_currentUserId!);
      notifyListeners();
    }
  }
}