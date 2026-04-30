// ─────────────────────────────────────────────────────────────────────────────
// We import the Flutter UI library — this gives us all the widgets we need
// like Text, Button, TextField, Column, etc.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// We import fl_chart — this is a third-party package we added in pubspec.yaml
// It gives us the BarChart widget to draw our chart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:fl_chart/fl_chart.dart';

// ─────────────────────────────────────────────────────────────────────────────
// main() is the entry point of every Flutter app.
// When you run the app, Flutter calls this function first.
// runApp() takes our root widget and puts it on the screen.
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// MyApp is the ROOT of our entire application.
// It is a StatelessWidget because it never changes — it just sets up the app.
// Think of it as the "settings" of your app (title, theme, first page).
// ─────────────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The name of our app (shown in browser tab)
      title: 'Product Inventory',

      // Hides the red "DEBUG" banner in the top right corner
      debugShowCheckedModeBanner: false,

      // ThemeData sets the colors and style for the whole app
      // ColorScheme.fromSeed() generates a full color palette from one color
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // home is the first page that shows when the app opens
      home: const InventoryPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InventoryPage is our MAIN PAGE.
//
// We use StatefulWidget here because this page has DATA THAT CHANGES:
//   - The list of products changes when we add or remove items
//   - The selected tab changes when we switch between List and Chart
//
// Rule: If something on your page can CHANGE → use StatefulWidget
//       If nothing changes → use StatelessWidget
// ─────────────────────────────────────────────────────────────────────────────
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  // createState() connects this widget to its State class below
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

// ─────────────────────────────────────────────────────────────────────────────
// _InventoryPageState is where ALL the logic and data lives.
// The underscore _ means it is private (only used in this file).
//
// This class holds:
//   1. Our data (products list, controllers, selected tab)
//   2. Our functions (addProduct, removeProduct, buildBarGroups)
//   3. Our UI (the build method)
// ─────────────────────────────────────────────────────────────────────────────
class _InventoryPageState extends State<InventoryPage> {

  // ─── OUR DATA ─────────────────────────────────────────────────────────────

  // This List stores all the products the user adds.
  // Each product is a Map with two keys: 'name' and 'quantity'
  // Example: [{'name': 'Laptop', 'quantity': '5'}, {'name': 'Phone', 'quantity': '12'}]
  // It starts as an empty list [] — no products yet.
  List<Map<String, String>> products = [];

  // TextEditingController "listens" to a TextField.
  // When we attach it to a TextField, we can read what the user typed.
  // We also use it to clear the field after adding a product.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // This tracks which tab is currently selected.
  // 0 = Inventory (list view)
  // 1 = Chart (bar chart view)
  int selectedTab = 0;

  // ─── OUR FUNCTIONS ────────────────────────────────────────────────────────

  // addProduct() runs when the user clicks the "Add Product" button.
  void addProduct() {
    // Read the text the user typed in each field
    // .trim() removes any extra spaces before or after the text
    String name = nameController.text.trim();
    String quantity = quantityController.text.trim();

    // If either field is empty, stop here — don't add an empty product
    if (name.isEmpty || quantity.isEmpty) return;

    // setState() is the most important function in StatefulWidget!
    // It does two things:
    //   1. Runs the code inside the { } brackets (updates our data)
    //   2. Tells Flutter: "data changed, please redraw the screen!"
    // Without setState(), the screen would NOT update even if data changes.
    setState(() {
      // Add a new product Map to our products list
      products.add({
        'name': name,
        'quantity': quantity,
      });
    });

    // Clear both text fields so user can type the next product
    nameController.clear();
    quantityController.clear();
  }

  // removeProduct() runs when the user clicks the delete icon on a product.
  // It receives the index (position) of the product to remove.
  // index 0 = first product, index 1 = second product, etc.
  void removeProduct(int index) {
    // Again we use setState() because we are changing the products list
    // and we want the screen to redraw without that product
    setState(() {
      products.removeAt(index); // removes the item at that position
    });
  }

  // buildBarGroups() creates the data that the BarChart widget needs.
  // It loops through our products list and converts each product
  // into a BarChartGroupData object (one bar per product).
  List<BarChartGroupData> buildBarGroups() {
    // .asMap() gives us both the index AND the value as we loop
    // .entries gives us each index-value pair
    // .map() transforms each product into a bar
    return products.asMap().entries.map((entry) {
      // entry.key = the index (0, 1, 2...)
      // entry.value = the product Map {'name': ..., 'quantity': ...}
      int index = entry.key;

      // Convert the quantity string to a decimal number
      // double.tryParse() safely converts "10" → 10.0
      // If it fails (e.g. user typed letters), ?? 0 gives us 0 instead of an error
      double qty = double.tryParse(entry.value['quantity'] ?? '0') ?? 0;

      // BarChartGroupData = one group of bars on the chart
      // x = the horizontal position of this bar
      return BarChartGroupData(
        x: index,
        barRods: [
          // BarChartRodData = one individual bar
          BarChartRodData(
            toY: qty,                          // height of the bar = quantity
            color: Colors.blue.shade400,       // bar color
            width: 22,                         // bar width in pixels
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),         // rounded top corners
            ),
          ),
        ],
      );
    }).toList(); // convert the result back to a List
  }

  // ─── BUILD METHOD — THIS DRAWS THE SCREEN ─────────────────────────────────
  // Flutter calls build() every time setState() is called.
  // It returns the entire widget tree (UI) for this page.
  @override
  Widget build(BuildContext context) {

    // DefaultTabController manages the tab switching for us automatically.
    // length: 2 means we have 2 tabs (Inventory + Chart)
    // It must wrap the Scaffold so the TabBar inside AppBar can find it.
    return DefaultTabController(
      length: 2,
      child: Scaffold(

        // ── APP BAR ───────────────────────────────────────────────────────
        // AppBar is the blue bar at the top of the screen
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Product Inventory',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,

          // bottom adds a widget below the title in the AppBar
          // Here we add our TabBar (the two tabs)
          bottom: TabBar(
            // onTap runs when user taps a tab
            // We update selectedTab so the body knows which view to show
            onTap: (index) => setState(() => selectedTab = index),
            tabs: const [
              // Tab 1: Inventory list
              Tab(
                icon: Icon(Icons.list, color: Colors.white),
                text: 'Inventory',
              ),
              // Tab 2: Bar chart
              Tab(
                icon: Icon(Icons.bar_chart, color: Colors.white),
                text: 'Chart',
              ),
            ],
            indicatorColor: Colors.white, // the underline under selected tab
            labelColor: Colors.white,     // text color of tabs
          ),
        ),

        // ── BODY ──────────────────────────────────────────────────────────
        // The body is everything below the AppBar
        body: Padding(
          // Padding adds space around all edges (16 pixels on each side)
          padding: const EdgeInsets.all(16.0),

          // Column stacks widgets vertically, one on top of the other
          child: Column(
            children: [

              // ── INPUT CARD ─────────────────────────────────────────────
              // Card is a container with a white background and shadow
              Card(
                elevation: 3, // shadow depth
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // crossAxisAlignment aligns children to the LEFT
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Section title
                      const Text(
                        'Add New Product',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // SizedBox adds empty vertical space (like a margin)
                      const SizedBox(height: 12),

                      // TextField for product name
                      // controller: connects this field to nameController
                      // so we can read what the user types with nameController.text
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',     // floating label
                          hintText: 'e.g. Laptop',       // placeholder text
                          border: OutlineInputBorder(),  // rectangle border
                          prefixIcon: Icon(Icons.inventory_2), // icon on the left
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TextField for quantity
                      // keyboardType: TextInputType.number shows number keyboard on mobile
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'e.g. 10',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Add Product Button
                      // SizedBox with width: double.infinity makes button full width
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          // onPressed connects the button to our addProduct() function
                          // When user clicks → addProduct() runs
                          onPressed: addProduct,
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Add Product',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── TAB CONTENT ────────────────────────────────────────────
              // Expanded makes this widget fill all remaining vertical space
              // Without Expanded, the ListView would have no space to grow into
              Expanded(
                // Ternary operator: condition ? valueIfTrue : valueIfFalse
                // If selectedTab is 0 → show the list
                // If selectedTab is 1 → show the chart
                child: selectedTab == 0
                    ? _buildListView(context)
                    : _buildChartView(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _buildListView() returns the inventory list UI.
  // We put it in a separate function to keep build() clean and readable.
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildListView(BuildContext context) {
    return Column(
      children: [

        // Header row: "Products in Stock" title + item count badge
        Row(
          // SpaceBetween pushes children to opposite ends of the row
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Products in Stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Chip is a small rounded badge — shows how many products we have
            // products.length is automatically updated when we add/remove items
            Chip(
              label: Text('${products.length} items'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Expanded fills the rest of the screen with either:
        //   - An empty state message (if no products)
        //   - The scrollable product list (if there are products)
        Expanded(
          // Ternary: if products list is empty → show empty message
          //          if products list has items → show ListView
          child: products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // A big grey inbox icon
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No products yet.\nAdd your first product above!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )

              // ListView.builder efficiently builds a scrollable list.
              // It only builds the widgets that are currently visible on screen
              // which is important for performance with large lists.
              : ListView.builder(
                  // itemCount = how many rows to build = number of products
                  itemCount: products.length,

                  // itemBuilder runs once for each item in the list
                  // context = the build context
                  // index = the current row number (0, 1, 2, 3...)
                  itemBuilder: (context, index) {
                    // Get the product at this index position
                    final product = products[index];

                    // Each product gets a Card with a ListTile inside
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        // leading = widget on the LEFT side of the tile
                        // CircleAvatar is a circle — we use it to show the number
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            // index starts at 0, so we add 1 to show 1, 2, 3...
                            '${index + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // title = the main text (product name)
                        // The ! after product['name'] tells Dart: "I promise this is not null"
                        title: Text(
                          product['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // subtitle = smaller text below the title (quantity)
                        subtitle: Text('Quantity: ${product['quantity']}'),

                        // trailing = widget on the RIGHT side of the tile
                        // This is our delete button
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          // When tapped → call removeProduct() with this index
                          // The => is a shorthand for a one-line function
                          onPressed: () => removeProduct(index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _buildChartView() returns the bar chart UI.
  // Again, a separate function to keep the code organized.
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChartView(BuildContext context) {

    // If no products, show a friendly empty message instead of an empty chart
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Add products to see the chart!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Find the highest quantity in our products list.
    // We use this to set the top of the Y axis on the chart.
    // .map() converts each product to its quantity as a number
    // .reduce() compares pairs and keeps the larger one each time
    double maxQty = products
        .map((p) => double.tryParse(p['quantity'] ?? '0') ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Chart title
        const Text(
          'Stock Levels by Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Expanded gives the chart all remaining vertical space
        Expanded(
          // BarChart is from the fl_chart package we imported
          child: BarChart(
            // BarChartData holds all the configuration for our chart
            BarChartData(
              // maxY = the highest value on the Y axis
              // We add 5 so there's some space above the tallest bar
              maxY: maxQty + 5,

              // barGroups = the actual bars to draw
              // We call our buildBarGroups() function to generate them
              barGroups: buildBarGroups(),

              // Hide the border around the chart
              borderData: FlBorderData(show: false),

              // Show horizontal grid lines (makes it easier to read values)
              gridData: const FlGridData(show: true),

              // titlesData configures the labels on each axis
              titlesData: FlTitlesData(

                // Bottom axis labels = product names
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    // getTitlesWidget builds the label for each bar
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      // Safety check: don't crash if index is out of range
                      if (index >= products.length) return const SizedBox();
                      String name = products[index]['name']!;
                      // Shorten long names so they fit under the bar
                      if (name.length > 8) {
                        name = '${name.substring(0, 7)}..';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                    reservedSize: 36, // height reserved for bottom labels
                  ),
                ),

                // Left axis labels = quantity numbers
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36, // width reserved for left labels
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),

                // Hide labels on top and right — we don't need them
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Small caption below the chart
        const Center(
          child: Text(
            'Each bar = quantity of one product',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}