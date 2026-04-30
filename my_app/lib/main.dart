// Padding — adds space around widgets
// Column — stacks widgets vertically
// Card — a nice container with a shadow
// TextField — text input field
// ElevatedButton — clickable button (button does nothing yet — that's okay!)
// SizedBox — adds empty space between widgets


import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InventoryPage(),
    );
  }
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Product Inventory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        // Adds space (16px) around the entire body content
        padding: const EdgeInsets.all(16.0),

        child: Column(
          // Column arranges widgets vertically (top → bottom)
          children: [

            // ── The input card ───────────────────────────────────────
            Card(
              // elevation adds a shadow → gives a "raised" card effect
              elevation: 3,

              child: Padding(
                // inner spacing inside the card
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  // aligns children to the left instead of center
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Add New Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Adds vertical spacing between elements
                    const SizedBox(height: 12),

                    // Product name field
                    const TextField(
                      // InputDecoration defines UI of the input field
                      decoration: InputDecoration(
                        labelText: 'Product Name',   // floating label
                        hintText: 'e.g. Laptop',     // placeholder text
                        border: OutlineInputBorder(), // visible border
                        prefixIcon: Icon(Icons.inventory_2), // icon inside field
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quantity field
                    const TextField(
                      // Forces numeric keyboard on mobile
                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'e.g. 10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Add button — does nothing yet
                    SizedBox(
                      // Makes button take full width
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        // Click handler (currently empty → no logic yet)
                        onPressed: () {},

                        // Icon + text button (combined)
                        icon: const Icon(Icons.add),

                        label: const Text(
                          'Add Product',
                          style: TextStyle(fontSize: 16),
                        ),

                        // Custom styling for the button
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),

                          // Uses theme color (keeps design consistent)
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,

                          // Text/icon color
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Placeholder text for future feature (product list)
            const Text(
              'Product list will appear here...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
           ),
          ],
        ),
      ),
    );
  }
}