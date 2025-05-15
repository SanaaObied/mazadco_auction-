import 'package:flutter/material.dart';
import 'package:works/user_status.dart';
import 'addAuction.dart';
import 'msg.dart';
import 'admin.dart';
import 'dashbord.dart';
void main() {
  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auction Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
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
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  bool _isExpanded = true;

  final List<Widget> _pages = [
    const DashboardHome(),
    AdminAuctionsPage(),
     user_status(),
    SendMessagePage(senderName: 'Afnan'),
  ];

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
        title: const Text('Auction Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
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
          backgroundColor: Colors.deepPurple[50],
          selectedIconTheme: const IconThemeData(color: Colors.deepPurple),
          selectedLabelTextStyle: const TextStyle(color: Colors.deepPurple),
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
              icon: Icon(Icons.message),
              label: Text('Messages'),
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
      selectedItemColor: Colors.deepPurple,
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
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        Expanded(
          child: const AdminDashboard2(), 
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
        Icon(icon, size: 40, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}