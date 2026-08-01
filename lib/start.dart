import 'package:flutter/material.dart';
import 'package:works/item_deatailed_from_dp.dart';
import 'package:works/main.dart';
import 'package:works/user_status.dart';
import 'addAuction.dart';
import 'admin_profile.dart';
import 'msg.dart';
import 'admin.dart';
import 'dashbord.dart';
import 'user_profile.dart';

class AdminDashboardApp extends StatelessWidget {
  final int ipAddress;
  const AdminDashboardApp({super.key ,required this.ipAddress});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Auction Admin Dashboard',
      theme: ThemeData(
       // primarySwatch: Colors.black,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home:  AdminDashboard(ipAddress: ipAddress,),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  final int ipAddress;
  const AdminDashboard({super.key, required this.ipAddress});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  bool _isExpanded = true;

  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardHome(ipAddress: widget.ipAddress),
      AdminAuctionsPage(),
      user_status(),
      //SendMessagePage(senderName: 'Afnan'),
      user_profile(userId: widget.ipAddress,),
      NewProductScreen()
    ];
  }

  void _navigateTo(int index) {
    if (index >= _pages.length) {
      switch (index) {
        case 4: // Add Auction
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewProductScreen()),
          );
          break;
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Auction Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => LoginPage(

                  ),
                ),
              );
            },          ),
        ],
      ),
      body: isMobile ? _pages[_currentIndex] : _buildDesktopLayout(),
      bottomNavigationBar: isMobile ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          minWidth: 70,
          extended: _isExpanded,
          backgroundColor: Colors.teal[50],
          selectedIconTheme: const IconThemeData(color: Colors.teal),
          selectedLabelTextStyle: const TextStyle(color: Colors.teal),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.gavel),
              label: Text('Auctions'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people),
              label: Text('Users'),
            ),
         NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Admin Profile'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.add_circle),
              label: Text('Add Auction'),
            ),
          ],
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateTo,
        ),
        Expanded(
          child: _pages[_currentIndex],
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _navigateTo,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Auctions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Admin Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Add Auction',
        ),
      ],
    );
  }
}

class DashboardHome extends StatelessWidget {
  final int ipAddress;
  const DashboardHome({super.key, required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        Expanded(
          child: AdminDashboard2(
            userId: ipAddress,
          ),
        ),
         
    
        const SizedBox(height: 20),
        _buildQuickStatsSection(),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.teal),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}