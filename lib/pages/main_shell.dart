import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'inventory_page.dart';
import 'suppliers_page.dart';

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
  int _currentIndex = 1; // Start on the Products tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar is shared across all four tabs
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,

        // CircleAvatar with the letter "S" as the app logo
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade700,
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        title: const Text(
          'StockFlow',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        // Sign-out button in the top-right corner.
        // FirebaseAuth.instance.signOut() clears the session and the StreamBuilder
        // in main.dart automatically navigates back to the login screen.
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),

      // The body shows a different widget depending on which tab is selected
      body: _buildPage(_currentIndex),

      // NavigationBar is the modern Material 3 bottom navigation component.
      // It replaces the older BottomNavigationBar with a cleaner look.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        // setState() tells Flutter "my data changed — rebuild this widget".
        // Changing _currentIndex causes _buildPage() to return a different screen.
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
        return const _PlaceholderPage(
          icon: Icons.dashboard,
          message: 'Dashboard — Coming in Session 7',
        );
      case 1:
        // InventoryPage no longer has its own Scaffold — it returns a Column
        // that fills this Scaffold's body
        return const InventoryPage();
      case 2:
        return const SuppliersPage();
      case 3:
        return const _PlaceholderPage(
          icon: Icons.notifications,
          message: 'Alerts — Coming in Session 6',
        );
      default:
        return const InventoryPage();
    }
  }
}

// _PlaceholderPage is a simple centered message used for tabs not yet built.
// The underscore in the class name means it is private to this file.
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
          // Large grey icon as a visual hint of what this tab will contain
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
