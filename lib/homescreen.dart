import 'package:flutter/material.dart';
import 'checkinscreen.dart';
import 'finishclassscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckedIn = false;

  void _onCheckedIn() => setState(() => _isCheckedIn = true);
  void _onFinishClass() => setState(() => _isCheckedIn = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF3A7BD5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'Smart Class Check-in',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF888888),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isCheckedIn ? 'Checked In' : 'Not Checked In',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _isCheckedIn
                                  ? const Color(0xFF27AE60)
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: _isCheckedIn
                                ? Container(
                                    key: const ValueKey('checked'),
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F9F0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 54,
                                      color: Color(0xFF27AE60),
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('notchecked'),
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.question_mark_rounded,
                                      size: 54,
                                      color: Color(0xFFAAAAAA),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // STEP 1: Check-in Button
                    _StepButton(
                      step: 'STEP 1',
                      label: 'Check-in',
                      icon: Icons.qr_code_scanner_rounded,
                      activeColor: const Color(0xFF2ECC71),
                      enabled: !_isCheckedIn,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CheckInScreen(onCheckedIn: _onCheckedIn),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // STEP 2: Finish Class Button
                    _StepButton(
                      step: 'STEP 2',
                      label: 'Finish Class',
                      icon: Icons.exit_to_app_rounded,
                      activeColor: const Color(0xFFFF7043),
                      enabled: _isCheckedIn,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FinishClassScreen(
                                onFinished: _onFinishClass),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String step;
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.step,
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? activeColor : const Color(0xFFBDBDBD);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 62,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 54,
              height: 54,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}