import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishClassScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const FinishClassScreen({super.key, required this.onFinished});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();
  String? _qrResult;
  bool _scanning = false;
  Position? _position;
  String? _timestamp;
  bool _fetchingLocation = false;
  bool _submitting = false;

  @override
  void dispose() {
    _learnedCtrl.dispose();
    _feedbackCtrl.dispose();
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

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toIso8601String();
      await prefs.setString('finish_learned_${now}', _learnedCtrl.text.trim());
      await prefs.setString(
          'finish_feedback_${now}', _feedbackCtrl.text.trim());
      await prefs.setString('finish_qr_${now}', _qrResult ?? '');
      await prefs.setString(
          'finish_lat_${now}', _position?.latitude.toString() ?? '');
      await prefs.setString(
          'finish_lng_${now}', _position?.longitude.toString() ?? '');
      await prefs.setString('finish_timestamp_${now}', _timestamp ?? '');
      await prefs.setString('finish_saved_at', now);

      setState(() => _submitting = false);
      widget.onFinished();
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2ECC71), size: 28),
                SizedBox(width: 8),
                Text('Saved Successfully!'),
              ],
            ),
            content: const Text('Data has been saved to your device.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context)
                  ..pop()
                  ..pop(),
                child: const Text('OK',
                    style: TextStyle(color: Color(0xFF2ECC71))),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      _showSnack('Error saving data: $e');
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
          'Finish Class',
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
              // ─── QR Scanner ───────────────────────────────────
              _buildSectionTitle('📷  Identity Verification (QR Code)'),
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

              // ─── Location ─────────────────────────────────────
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

              // ─── Post-class Form ───────────────────────────────
              _buildSectionTitle('📝  Class Summary'),
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
                      controller: _learnedCtrl,
                      decoration: _inputDecoration('What did you learn today?'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      maxLines: 5,
                      minLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _feedbackCtrl,
                      decoration: _inputDecoration(
                          'Feedback about the class / instructor.'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submitData,
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _submitting ? 'Saving...' : 'Submit & Finish Class',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
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
            const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
