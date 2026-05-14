import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// QrScannerPage opens the device camera full-screen and reads QR codes.
// Unlike tab pages, this screen is pushed with Navigator.push() so it
// has its own Scaffold and AppBar with an automatic back button.
// When a QR code is detected it closes and sends the scanned text back
// to InventoryPage via Navigator.pop(context, value).
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  // MobileScannerController drives the camera hardware.
  // It exposes toggleTorch() and switchCamera() for the AppBar buttons.
  final MobileScannerController _controller = MobileScannerController();

  // _hasScanned prevents onDetect from firing multiple times for the same code.
  // The camera runs at many frames per second — without this flag the app
  // would try to navigate away multiple times in quick succession.
  bool _hasScanned = false;

  @override
  void dispose() {
    // Releasing the controller stops the camera and frees the hardware resource.
    _controller.dispose();
    super.dispose();
  }

  // _onDetect is called every time the camera finds a barcode in a frame.
  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasScanned = true);

    // Navigator.pop(context, rawValue):
    //   1. Closes this screen (same as the back button)
    //   2. Returns rawValue to InventoryPage as: final result = await Navigator.push(...)
    Navigator.pop(context, rawValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Torch toggle — useful in dim warehouses or storerooms
          IconButton(
            icon: const Icon(Icons.flashlight_on, color: Colors.white),
            tooltip: 'Toggle torch',
            onPressed: () => _controller.toggleTorch(),
          ),
          // Camera flip — swap between front and back camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            tooltip: 'Flip camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // MobileScanner fills the body with a live camera preview.
          // onDetect fires every time the camera spots a barcode.
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // White square overlay guides the user where to aim
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Hint text at the bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: Text(
                'Point the camera at a QR code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
