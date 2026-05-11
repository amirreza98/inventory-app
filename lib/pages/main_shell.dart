import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';
import 'inventory_page.dart';
import 'suppliers_page.dart';
import 'profile_page.dart';

// MainShell is the top-level screen shown after the user logs in.
// It owns the AppBar and the bottom NavigationBar that all tabs share.
// Each tab renders a different page in the body.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // _currentIndex tracks which bottom tab the user has selected.
  // 0 = Dashboard, 1 = Products, 2 = Suppliers, 3 = Alerts
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Read the logged-in user's email to build the avatar initial dynamically.
    // currentUser is never null here — MainShell is only shown when logged in.
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'S';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,

        // GestureDetector wraps the avatar so tapping it opens the Profile page.
        // Navigator.push() slides ProfilePage in from the right.
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        title: const Text(
          'StockFlow',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // The body shows a different widget depending on which tab is selected
      body: _buildPage(_currentIndex),

      // NavigationBar is the Material 3 bottom navigation component
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory),
            label: 'Suppliers',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  // _buildPage() returns the correct widget for the selected tab index
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const InventoryPage();
      case 2:
        return const SuppliersPage();
      case 3:
        return const _PlaceholderPage(
          icon: Icons.notifications,
          message: 'Alerts — Coming in Session 7',
        );
      default:
        return const InventoryPage();
    }
  }
}

// _PlaceholderPage is a simple centered message for tabs not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _PlaceholderPage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
