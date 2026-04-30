// Import Flutter's Material Design library (UI components like Scaffold, AppBar, Text, etc.)
import 'package:flutter/material.dart';

// Entry point of every Flutter app
void main() {
  // runApp starts the Flutter app and takes a Widget as input
  // 'const' is used because MyApp is immutable (optimization)
  runApp(const MyApp());
}

// MyApp is the root widget of the application
// StatelessWidget means it does NOT manage any internal state: meaning after creation the appriance wont change
class MyApp extends StatelessWidget {

  // Constructor for MyApp
  // super.key allows Flutter to optimize widget rebuilding
  const MyApp({super.key});

  // build() describes how the UI should look
  @override
  Widget build(BuildContext context) {

    // MaterialApp is the top-level widget for a Material Design app
    return MaterialApp(

      // Title of the app (used in task switchers, not visible in UI directly)
      title: 'Product Inventory',

      // Removes the "DEBUG" banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // Theme configuration for the whole app
      theme: ThemeData(

        // Generates a color scheme based on a seed color (blue here)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

        // Enables Material Design 3 (modern UI style)
        useMaterial3: true,
      ),

      // The first screen that will be shown when the app starts
      home: const InventoryPage(),
    );
  }
}

// InventoryPage is another screen (widget)
// Also Stateless → UI does not change dynamically
class InventoryPage extends StatelessWidget {

  // Constructor
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Scaffold provides a basic app layout structure
    return Scaffold(

      // Top bar of the app
      appBar: AppBar(

        // Background color comes from the theme's primary color
        backgroundColor: Theme.of(context).colorScheme.primary,

        // Title displayed in the AppBar
        title: const Text(
          'Product Inventory',

          // Styling the text (white + bold)
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Centers the title in the AppBar
        centerTitle: true,
      ),

      // Main body of the screen
      body: const Center(

        // Center widget places its child in the middle of the screen
        child: Text(
          'Welcome to Product Inventory!',

          // Text styling
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}