import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk function 'Getar' (Haptic)
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exhibition Guide',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const ExhibitionHomePage(),
    );
  }
}

class ExhibitionHomePage extends StatefulWidget {
  const ExhibitionHomePage({super.key});

  @override
  State<ExhibitionHomePage> createState() => _ExhibitionHomePageState();
}

class _ExhibitionHomePageState extends State<ExhibitionHomePage> {
  String _locationMessage = "Menunggu satelit...";
  String _beaconStatus = "Sistem belum aktif";
  Color _statusColor = Colors.grey;
  IconData _statusIcon = Icons.radar;
  String? _imageUrl; // Variable untuk simpan link gambar

  List<ScanResult> _scanResults = [];
  bool _isSystemActive = false;

  Future<void> _startSystem() async {
    setState(() => _beaconStatus = "Meminta izin...");

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    if (statuses[Permission.location]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted) {
      setState(() {
        _isSystemActive = true;
        _beaconStatus = "Mengimbas Objek...";
        _statusColor = Colors.blueAccent;
        _statusIcon = Icons.search;
      });
      _startLocationUpdates();
      _startBeaconScan();
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _locationMessage =
              "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        });
      }
    });
  }

  void _startBeaconScan() async {
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
          bool foundNearby = false;

          for (ScanResult r in results) {
            // Logic: Signal > -75 (Dekat)
            if (r.rssi > -75) {
              String namaObjek = "Objek Misteri";
              IconData iconJumpa = Icons.help_outline;
              String? gambarJumpa; // Variable sementara

              // --- RUANGAN DATABASE MINI ---
              // Ganti ID ni dengan ID iPhone/Beacon awak
              if (r.device.remoteId.toString() == "C3:96:62:12:34:16") {
                namaObjek = "Lukisan Monalisa\n(Leonardo da Vinci, 1503)";
                iconJumpa = Icons.brush;
                // Link gambar Monalisa dari Wikipedia
                gambarJumpa =
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/800px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg";
              } else {
                namaObjek = "Artifak Purba (${r.device.remoteId})";
                iconJumpa = Icons.museum;
                // Link gambar 'placeholder' (icon muzium)
                gambarJumpa =
                    "https://cdn-icons-png.flaticon.com/512/1089/1089129.png";
              }

              // EFEK GETAR (HAPTIC)
              // Kalau status baru bertukar (dari tak jumpa -> jumpa), kita getar sikit
              if (!_beaconStatus.contains("HADAPAN")) {
                HapticFeedback.mediumImpact();
              }

              _beaconStatus = "ANDA BERADA DI HADAPAN:\n$namaObjek";
              _statusColor = Colors.green;
              _statusIcon = iconJumpa;
              _imageUrl = gambarJumpa; // Simpan link gambar untuk dipapar
              foundNearby = true;
              break;
            }
          }

          // Kalau tak jumpa apa-apa yang dekat
          if (!foundNearby) {
            _beaconStatus = "Mencari pameran...";
            _statusColor = Colors.indigoAccent;
            _statusIcon = Icons.search;
            _imageUrl = null; // Padam gambar
          }
        });
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      // ignore: avoid_print
      print("Scan error: $e");
    }
  }

  String _getProximity(int rssi) {
    if (rssi >= -60) return "Sangat Dekat";
    if (rssi >= -85) return "Dekat";
    return "Jauh";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. HEADER BESAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Smart Exhibition Guide",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _locationMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. STATUS INDICATOR (KOTAK TENGAH YANG CANGGIH)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon atau Gambar
                  if (_imageUrl != null)
                    Container(
                      height: 150,
                      width: 150,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(
                            _imageUrl!,
                          ), // Tarik gambar dari internet
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Icon(_statusIcon, size: 40, color: Colors.white),

                  const SizedBox(height: 10),
                  Text(
                    _beaconStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. BUTANG MULA
          if (!_isSystemActive)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: _startSystem,
                icon: const Icon(Icons.rocket_launch),
                label: const Text("MULA JELAJAH MUSEUM"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

          // 4. SENARAI DEVICE
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _scanResults.isEmpty
                  ? Center(
                      child: Text(
                        "Tiada isyarat berdekatan...",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _scanResults.length,
                      itemBuilder: (context, index) {
                        final result = _scanResults[index];
                        Color signalColor = result.rssi > -70
                            ? Colors.green
                            : Colors.orange;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8EAF6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bluetooth_audio,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Text(
                              result.device.platformName.isNotEmpty
                                  ? result.device.platformName
                                  : "Unknown Beacon",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ID: ${result.device.remoteId}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${result.rssi} dBm",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: signalColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: signalColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _getProximity(result.rssi),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: signalColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
