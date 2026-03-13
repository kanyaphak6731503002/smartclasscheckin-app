import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInScreen extends StatefulWidget {
  final VoidCallback onCheckedIn;
  const CheckInScreen({super.key, required this.onCheckedIn});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prevTopicCtrl = TextEditingController();
  final _todayTopicCtrl = TextEditingController();
  int _mood = 3;
  String? _qrResult;
  bool _scanning = false;
  Position? _position;
  String? _timestamp;
  bool _fetchingLocation = false;

  final List<String> _moodEmoji = ['😡', '🙁', '😐', '🙂', '😄'];

  @override
  void dispose() {
    _prevTopicCtrl.dispose();
    _todayTopicCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _fetchingLocation = false);
        _showSnack('Location services are disabled.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _fetchingLocation = false);
          _showSnack('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _fetchingLocation = false);
        _showSnack('Location permission permanently denied.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final now = DateTime.now();
      setState(() {
        _position = pos;
        _timestamp =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        _fetchingLocation = false;
      });
    } catch (e) {
      setState(() => _fetchingLocation = false);
      _showSnack('Failed to get location: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onQrDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null) {
      setState(() {
        _qrResult = barcode.rawValue;
        _scanning = false;
      });
    }
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Check-in',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── QR Scanner Section ───────────────────────────
              _buildSectionTitle('📷  QR Code Scanner'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  children: [
                    if (_scanning)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: SizedBox(
                          height: 220,
                          child: MobileScanner(onDetect: _onQrDetect),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_qrResult != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F9F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF2ECC71), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _qrResult!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF2ECC71)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_qrResult != null) const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  setState(() => _scanning = !_scanning),
                              icon: Icon(_scanning
                                  ? Icons.stop_rounded
                                  : Icons.qr_code_scanner_rounded),
                              label: Text(
                                  _scanning ? 'Stop Scanning' : 'Open Camera to Scan QR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _scanning
                                    ? Colors.grey
                                    : const Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Location Section ─────────────────────────────
              _buildSectionTitle('📍  Location & Timestamp'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_position != null) ...[
                      _locationRow(
                          Icons.my_location,
                          'Latitude',
                          _position!.latitude.toStringAsFixed(6),
                          const Color(0xFF3498DB)),
                      const SizedBox(height: 6),
                      _locationRow(
                          Icons.explore,
                          'Longitude',
                          _position!.longitude.toStringAsFixed(6),
                          const Color(0xFF9B59B6)),
                      const SizedBox(height: 6),
                      _locationRow(Icons.access_time, 'Timestamp',
                          _timestamp!, const Color(0xFFE67E22)),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton.icon(
                      onPressed:
                          _fetchingLocation ? null : () => _fetchLocation(),
                      icon: _fetchingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.location_on_rounded),
                      label: Text(_fetchingLocation
                          ? 'Fetching location...'
                          : (_position != null
                              ? 'Update Location'
                              : 'Get GPS Location')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Form Section ─────────────────────────────────
              _buildSectionTitle('📝  Class Information'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _prevTopicCtrl,
                      decoration: _inputDecoration(
                          'What topic was covered in the previous class?'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _todayTopicCtrl,
                      decoration: _inputDecoration(
                          'What topic do you expect to learn today?'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Mood Scale
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) {
                        final selected = _mood == i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _mood = i + 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFF5F5F5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF2ECC71)
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                          color: const Color(0xFF2ECC71)
                                              .withOpacity(0.3),
                                          blurRadius: 8)
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                _moodEmoji[i],
                                style: TextStyle(
                                    fontSize: selected ? 28 : 22),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) =>
                        SizedBox(
                          width: 52,
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onCheckedIn();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text(
                  'Confirm Check-in',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
