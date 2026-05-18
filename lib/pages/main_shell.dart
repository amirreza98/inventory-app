import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';
import 'inventory_page.dart';
import 'suppliers_page.dart';
import 'profile_page.dart';
import 'alerts_page.dart';
import 'chat_page.dart';

// MainShell is the top-level screen shown after login.
// It owns the AppBar, the bottom NavigationBar, and the low-stock badge count.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 0 = Dashboard, 1 = Products, 2 = Suppliers, 3 = Alerts
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'S';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Tapping the avatar opens the Profile page
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
      body: _buildPage(_currentIndex),

      // StreamBuilder wraps the NavigationBar so the Products badge count
      // updates in real time whenever any product document changes in Firestore.
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          // lowStockCount  — qty > 0 AND qty <= min (warning state, badge on Products)
          // alertCount     — qty == 0 OR (min > 0 AND qty <= min) (badge on Alerts)
          int lowStockCount = 0;
          int alertCount = 0;
          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final qty =
                  int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
              final min =
                  int.tryParse(data['minStockLevel']?.toString() ?? '0') ?? 0;
              if (qty > 0 && qty <= min) lowStockCount++;
              if (qty == 0 || (min > 0 && qty <= min)) alertCount++;
            }
          }

          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              // Badge overlays the count on the Products icon.
              // isLabelVisible: false hides it when count is zero.
              NavigationDestination(
                icon: Badge(
                  label: Text('$lowStockCount'),
                  isLabelVisible: lowStockCount > 0,
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('$lowStockCount'),
                  isLabelVisible: lowStockCount > 0,
                  child: const Icon(Icons.inventory_2),
                ),
                label: 'Products',
              ),
              const NavigationDestination(
                icon: Icon(Icons.factory_outlined),
                selectedIcon: Icon(Icons.factory),
                label: 'Suppliers',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text('$alertCount'),
                  isLabelVisible: alertCount > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('$alertCount'),
                  isLabelVisible: alertCount > 0,
                  child: const Icon(Icons.notifications),
                ),
                label: 'Alerts',
              ),
              NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy),
                label: 'Assistant',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const InventoryPage();
      case 2:
        return const SuppliersPage();
      case 3:
        return const AlertsPage();
      case 4:
        return const ChatPage();
      default:
        return const InventoryPage();
    }
  }
}
