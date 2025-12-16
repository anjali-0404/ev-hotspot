import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/stations_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ipController1 = TextEditingController();
  final _ipController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIps();
  }

  Future<void> _loadSavedIps() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController1.text = prefs.getString('nodeMcuIp_1') ?? '';
    _ipController2.text = prefs.getString('nodeMcuIp_2') ?? '';
  }

  Future<void> _saveIps() async {
    final ip1 = _ipController1.text.trim();
    final ip2 = _ipController2.text.trim();
    if (ip1.isNotEmpty) {
      await Provider.of<StationsProvider>(context, listen: false)
          .saveNodeMcuIp(1, ip1);
    }
    if (ip2.isNotEmpty) {
      await Provider.of<StationsProvider>(context, listen: false)
          .saveNodeMcuIp(2, ip2);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('IP addresses saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _ipController1.dispose();
    _ipController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 64 : 24, vertical: 32),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade300,
                        Colors.green.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'lib/assets/images/profile.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'EV Owner',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, '12', 'Bookings'),
                _buildStatItem(context, '3', 'Vehicles'),
                _buildStatItem(context, '85%', 'Avg. Charge'),
              ],
            ),
            const SizedBox(height: 30),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.email, color: Colors.white),
                      ),
                      title: Text('Email'),
                      subtitle: Text('john.doe@example.com'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.phone, color: Colors.white),
                      ),
                      title: Text('Phone'),
                      subtitle: Text('+1 234 567 890'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.location_on, color: Colors.white),
                      ),
                      title: Text('Address'),
                      subtitle: Text('123 EV Street, San Francisco, CA'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingItem(
                      context,
                      Icons.notifications,
                      'Notifications',
                      true,
                    ),
                    const Divider(),
                    _buildSettingItem(
                      context,
                      Icons.dark_mode,
                      'Dark Mode',
                      false,
                    ),
                    const Divider(),
                    _buildSettingItem(
                      context,
                      Icons.language,
                      'Language',
                      false,
                      value: 'English',
                    ),
                    const Divider(),
                    TextField(
                      controller: _ipController1,
                      decoration: const InputDecoration(
                        labelText: 'NodeMCU IP for Station 1',
                        hintText: 'e.g., 192.168.1.100',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ipController2,
                      decoration: const InputDecoration(
                        labelText: 'NodeMCU IP for Station 2',
                        hintText: 'e.g., 192.168.1.101',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveIps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save IPs'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context,
      IconData icon,
      String title,
      bool isSwitch, {
        String? value,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (isSwitch)
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: Colors.green,
            )
          else if (value != null)
            Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            )
          else
            const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}