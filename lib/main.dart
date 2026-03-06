import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.6, 
        child: Transform.rotate(
          angle: 0, 
          child: Image.network(
            'https://as2.ftcdn.net/jpg/02/99/31/23/1000_F_299312307_7B1W2Z1gCG9UvJyf5BjMbY9ippiWtv5q.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget customAppBar(String title) {
  return AppBar(
    centerTitle: true,
    title: Text(
      title,
      style: GoogleFonts.lobster(
        fontSize: 28, 
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0, 
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.green,
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Nutri Scan'),
      body: Stack(
        children: [
          const Background(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QRInputScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 60),
                  ),
                  child: const Text(
                    'Generate QR Code',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 60),
                  ),
                  child: const Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QRInputScreen extends StatefulWidget {
  const QRInputScreen({super.key});

  @override
  State<QRInputScreen> createState() => _QRInputScreenState();
}

class _QRInputScreenState extends State<QRInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nutritionController = TextEditingController();
  String? _qrData;

  void _generateQR() {
    String name = _nameController.text.trim();
    String nutrition = _nutritionController.text.trim();

    if (name.isNotEmpty && nutrition.isNotEmpty) {
      setState(() {
        _qrData = '{"name": "$name", "nutrition": "${nutrition.replaceAll('\n', '\\n')}"}';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both name and nutrition info'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('QR Generator'),
      body: Stack(
        children: [
          const Background(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Name',
                    filled: true,
                    fillColor: Color.fromARGB(100, 255, 255, 255), 
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nutritionController,
                  decoration: const InputDecoration(
                    labelText: 'Nutrition Info (Separate with new lines)',
                    filled: true,
                    fillColor: Color.fromARGB(100, 255, 255, 255), 
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _generateQR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 60),
                  ),
                  child: const Text('Generate', style: TextStyle(color: Colors.white)),
                ),
                if (_qrData != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? _scannedData;

  void _showScannedData(String data) {
    Map<String, dynamic> fruitInfo = {};
    try {
      fruitInfo = json.decode(data) as Map<String, dynamic>;
    } catch (e) {
      fruitInfo = {'error': 'Invalid QR Code'};
    }

    setState(() {
      _scannedData = fruitInfo.containsKey('error')
          ? fruitInfo['error']
          : 'NAME : ${fruitInfo['name']}\nNUTRITION :\n${fruitInfo['nutrition'].replaceAll('\\n', '\n')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Scan QR Code'),
      body: Stack(
        children: [
          const Background(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: MobileScanner(
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        if (barcode.rawValue != null) {
                          _showScannedData(barcode.rawValue!);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black.withOpacity(0.7),
                  width: double.infinity,
                  child: Text(
                    _scannedData ?? 'Scan a QR code to see details',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
