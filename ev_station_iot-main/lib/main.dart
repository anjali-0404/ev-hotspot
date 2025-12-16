import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'models/station.dart';
import 'providers/stations_provider.dart';
import 'screens/map_screen.dart';
import 'screens/station_list_screen.dart';

import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Main: Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Main: Firebase initialized successfully');
    
    // Debug Firebase configuration
    final database = FirebaseDatabase.instance;
    print('Main: Database URL: ${database.databaseURL}');
    print('Main: Database app: ${database.app.name}');
    
  } catch (e) {
    print('Main: Firebase initialization failed: $e');
  }
  print('Main: Starting app...');
  runApp(const EVChargingApp());
}

class EVChargingApp extends StatelessWidget {
  const EVChargingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationsProvider(),
      child: MaterialApp(
        title: 'Charging Stations',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Arial',
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const ChargingStationsScreen(),
      ),
    );
  }
}

class ChargingStationsScreen extends StatefulWidget {
  const ChargingStationsScreen({super.key});

  @override
  State<ChargingStationsScreen> createState() => _ChargingStationsScreenState();
}

class _ChargingStationsScreenState extends State<ChargingStationsScreen> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTapNav(int index) {
    _controller.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Stations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: _onPageChanged,
        children: const [
          MapScreen(),
          StationListScreen(),
          BookingsScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                final stationsProvider = Provider.of<StationsProvider>(context, listen: false);
                
                // Check user booking status
                final canBook = await stationsProvider.canUserBook();
                final canUnbook = await stationsProvider.canUserUnbook();
                
                if (canUnbook) {
                  print('Main: Unbooking car...');
                  final success = await stationsProvider.unbookCar();
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to unbook car')),
                    );
                  }
                } else if (canBook) {
                  print('Main: Booking car...');
                  final success = await stationsProvider.bookCar();
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to book car')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No available positions or you already have a booking')),
                  );
                }
              },
              child: Consumer<StationsProvider>(
                builder: (context, provider, child) {
                  final userStatus = provider.userBookingStatus;
                  if (userStatus != null && userStatus['hasBooking'] == true) {
                    return const Icon(Icons.remove);
                  } else if (userStatus != null && userStatus['canBook'] == true) {
                    return const Icon(Icons.add);
                  } else {
                    return const Icon(Icons.block);
                  }
                },
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTapNav,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.ev_station), label: 'Stations'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


