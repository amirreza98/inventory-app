import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_input_card.dart';
import '../widgets/product_list_view.dart';
import 'product_detail_screen.dart';
import 'qr_scanner_page.dart';
import 'csv_import_page.dart';

// InventoryPage shows the product form and the live list of products.
// It has no Scaffold of its own — MainShell provides the outer Scaffold.
// Two floating buttons (QR scan + Excel import) sit in the bottom-right corner.
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minStockLevelController = TextEditingController();

  final _collection = FirebaseFirestore.instance.collection('products');

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    minStockLevelController.dispose();
    super.dispose();
  }

  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final quantity = quantityController.text.trim();
    final minStock = minStockLevelController.text.trim().isEmpty
        ? '0'
        : minStockLevelController.text.trim();
    if (name.isEmpty || quantity.isEmpty) return;
    await _collection.add({
      'name': name,
      'quantity': quantity,
      'minStockLevel': minStock,
    });
    nameController.clear();
    quantityController.clear();
    minStockLevelController.clear();
  }

  // _scanQrCode opens the camera scanner and auto-fills the product name field.
  Future<void> _scanQrCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (result != null && result.isNotEmpty) {
      final parts = result.split(',');
      setState(() {
        nameController.text = parts[0].trim();
        if (parts.length > 1) quantityController.text = parts[1].trim();
        if (parts.length > 2) minStockLevelController.text = parts[2].trim();
      });
    }
  }

  // _importFromCsv opens the system file picker, reads the chosen .csv file,
  // and pushes CsvImportPage where the user reviews rows before confirming.
  Future<void> _importFromCsv() async {
    // Open the system file picker — only csv files are shown
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true, // loads the file bytes into memory so we can parse them
    );

    if (result == null || result.files.isEmpty) return; // user cancelled

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read the file. Try again.')),
        );
      }
      return;
    }

    if (!mounted) return;

    // Decode bytes to a UTF-8 string and push the preview screen
    final content = utf8.decode(bytes);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CsvImportPage(csvContent: content),
      ),
    );
    // When CsvImportPage pops, the StreamBuilder below auto-refreshes the list
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _collection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final products = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return <String, dynamic>{
            'id': d.id,
            'name': data['name']?.toString() ?? '',
            'quantity': data['quantity']?.toString() ?? '0',
            'minStockLevel': data['minStockLevel']?.toString() ?? '0',
          };
        }).toList();

        // Stack layers the two FABs on top of the scrollable content.
        // No Scaffold here, so Positioned is the way to float buttons.
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ProductInputCard(
                    nameController: nameController,
                    quantityController: quantityController,
                    minStockLevelController: minStockLevelController,
                    onAdd: addProduct,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ProductListView(
                      products: products,
                      onTap: (product) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Two FABs stacked vertically in the bottom-right corner.
            // heroTag must be unique when multiple FABs share the same widget tree.
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Small FAB: CSV import (above the main QR FAB)
                  FloatingActionButton.small(
                    heroTag: 'csv_import',
                    onPressed: _importFromCsv,
                    tooltip: 'Import from CSV',
                    child: const Icon(Icons.upload_file),
                  ),
                  const SizedBox(height: 10),
                  // Main FAB: QR scanner
                  FloatingActionButton(
                    heroTag: 'qr_scan',
                    onPressed: _scanQrCode,
                    tooltip: 'Scan QR code',
                    child: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
