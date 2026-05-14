import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// _ImportRow holds everything for one product row in the preview list.
// Each row starts selected and pre-filled from the CSV file.
// The user can uncheck it, or edit the Qty / Min fields before confirming.
class _ImportRow {
  final String name;
  final TextEditingController qtyController;
  final TextEditingController minController;
  bool selected = true;

  // null  →  this is a brand-new product (will be created in Firestore)
  // non-null → this product already exists (will be updated by docId)
  String? existingDocId;

  _ImportRow({
    required this.name,
    required String quantity,
    required String minStockLevel,
  })  : qtyController = TextEditingController(text: quantity),
        minController = TextEditingController(text: minStockLevel);

  void dispose() {
    qtyController.dispose();
    minController.dispose();
  }
}

// CsvImportPage is a full-screen preview before committing any changes.
// It receives the raw text content of the chosen CSV file, parses it,
// checks Firestore for existing products, then lets the user:
//   • uncheck rows to skip them
//   • edit the Qty / Min fields inline
//   • tap "Import N Products" to write everything to Firestore
class CsvImportPage extends StatefulWidget {
  final String csvContent;

  const CsvImportPage({super.key, required this.csvContent});

  @override
  State<CsvImportPage> createState() => _CsvImportPageState();
}

class _CsvImportPageState extends State<CsvImportPage> {
  List<_ImportRow> _rows = [];
  bool _isLoading = true;   // true while parsing + querying Firestore
  bool _isImporting = false; // true while writing to Firestore
  String? _parseError;      // non-null when the file could not be parsed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  // _loadData does two async steps back-to-back:
  //   1. Parse the CSV text into _ImportRow list
  //   2. One Firestore read to find which products already exist
  Future<void> _loadData() async {
    try {
      final parsed = _parseCsv(widget.csvContent);

      if (parsed.isEmpty) {
        setState(() {
          _parseError =
              'No products found in the file.\n\n'
              'Expected column layout (row 1 = header, data from row 2):\n'
              '  Column A  →  Product Name\n'
              '  Column B  →  Quantity\n'
              '  Column C  →  Min Stock Level (optional)';
          _isLoading = false;
        });
        return;
      }

      // Single Firestore read — load every existing product once
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      // Build a lookup map: lowercased name → Firestore document ID
      final existing = <String, String>{};
      for (final doc in snapshot.docs) {
        final name =
            (doc.data()['name']?.toString().trim() ?? '').toLowerCase();
        if (name.isNotEmpty) existing[name] = doc.id;
      }

      // Tag each parsed row as NEW or UPDATE
      for (final row in parsed) {
        row.existingDocId = existing[row.name.toLowerCase()];
      }

      setState(() {
        _rows = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _parseError = 'Could not read the file.\n\nDetails: $e';
        _isLoading = false;
      });
    }
  }

  // _parseCsv splits the CSV text into rows, skipping the header (row 0).
  // It handles quoted fields that may contain commas or newlines.
  List<_ImportRow> _parseCsv(String content) {
    // Normalize line endings so both \r\n and \n work
    final lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');

    if (lines.length < 2) return [];

    final result = <_ImportRow>[];

    // Start from index 1 to skip the header row
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final cols = _splitLine(line);

      final name = cols.isNotEmpty ? cols[0].trim() : '';
      if (name.isEmpty) continue;

      // Column B: quantity (default '0' when absent or empty)
      final qty = (cols.length > 1 && cols[1].trim().isNotEmpty)
          ? cols[1].trim()
          : '0';

      // Column C: min stock level (default '0' when absent or empty)
      final min = (cols.length > 2 && cols[2].trim().isNotEmpty)
          ? cols[2].trim()
          : '0';

      result.add(_ImportRow(name: name, quantity: qty, minStockLevel: min));
    }

    return result;
  }

  // _splitLine splits one CSV line into fields.
  // Handles quoted fields: "hello, world" stays as one field.
  List<String> _splitLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];

      if (ch == '"') {
        // Two consecutive double-quotes inside a quoted field = literal "
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }

    fields.add(buffer.toString()); // last field
    return fields;
  }

  // _confirmImport writes every checked row to Firestore.
  // If the product already exists it calls .update(); otherwise .add().
  Future<void> _confirmImport() async {
    final toImport = _rows.where((r) => r.selected).toList();
    if (toImport.isEmpty) return;

    setState(() => _isImporting = true);

    final col = FirebaseFirestore.instance.collection('products');

    try {
      for (final row in toImport) {
        final qty = row.qtyController.text.trim().isEmpty
            ? '0'
            : row.qtyController.text.trim();
        final min = row.minController.text.trim().isEmpty
            ? '0'
            : row.minController.text.trim();

        if (row.existingDocId != null) {
          // Product already exists — update quantity and minStockLevel
          await col.doc(row.existingDocId).update({
            'quantity': qty,
            'minStockLevel': min,
          });
        } else {
          // Brand-new product — create a Firestore document
          await col.add({
            'name': row.name,
            'quantity': qty,
            'minStockLevel': min,
          });
        }
      }

      // Pop back to InventoryPage — the StreamBuilder there will auto-refresh
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  // ── Helpers for the select-all checkbox ──────────────────────────────

  int get _selectedCount => _rows.where((r) => r.selected).length;
  bool get _allSelected => _rows.isNotEmpty && _rows.every((r) => r.selected);
  bool get _noneSelected => _rows.every((r) => !r.selected);

  void _toggleAll(bool? value) {
    setState(() {
      for (final row in _rows) {
        row.selected = value ?? false;
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Products',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // Show "X of Y selected" subtitle once loading is done
            if (!_isLoading && _parseError == null)
              Text(
                '$_selectedCount of ${_rows.length} selected',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    // ── Loading ──
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reading file and checking existing products…'),
          ],
        ),
      );
    }

    // ── Error ──
    if (_parseError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _parseError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    // ── Product preview table ──
    return Column(
      children: [
        // Header row with column labels and a select-all checkbox
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Tristate: checked = all selected, null = some selected, false = none
              Checkbox(
                value: _noneSelected ? false : (_allSelected ? true : null),
                tristate: true,
                onChanged: _toggleAll,
              ),
              const Expanded(
                flex: 3,
                child: Text(
                  'Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(
                width: 60,
                child: Text(
                  'Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 60,
                child: Text(
                  'Min',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 58,
                child: Text(
                  'Status',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Scrollable list of product rows
        Expanded(
          child: ListView.separated(
            itemCount: _rows.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16),
            itemBuilder: (context, i) => _buildRow(_rows[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(_ImportRow row) {
    final isUpdate = row.existingDocId != null;

    return Container(
      // Dim the background slightly when a row is unchecked
      color: row.selected ? null : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Per-row checkbox
          Checkbox(
            value: row.selected,
            onChanged: (v) => setState(() => row.selected = v ?? false),
          ),

          // Product name — greyed out when unchecked
          Expanded(
            flex: 3,
            child: Text(
              row.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: row.selected ? null : Colors.grey,
              ),
            ),
          ),

          // Quantity text field — disabled when unchecked
          SizedBox(
            width: 60,
            child: TextField(
              controller: row.qtyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: row.selected,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)),
                filled: !row.selected,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Min stock level field — disabled when unchecked
          SizedBox(
            width: 60,
            child: TextField(
              controller: row.minController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: row.selected,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)),
                filled: !row.selected,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Status badge: green NEW or blue UPDATE
          SizedBox(
            width: 58,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isUpdate ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUpdate
                      ? Colors.blue.shade300
                      : Colors.green.shade400,
                ),
              ),
              child: Text(
                isUpdate ? 'UPDATE' : 'NEW',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUpdate
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom confirm button — hidden during loading and on error
  Widget? _buildBottomBar() {
    if (_isLoading || _parseError != null) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                (_selectedCount == 0 || _isImporting) ? null : _confirmImport,
            icon: _isImporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              _isImporting
                  ? 'Importing…'
                  : 'Import $_selectedCount '
                      'Product${_selectedCount == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
