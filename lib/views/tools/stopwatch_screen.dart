import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../widgets/app_widgets.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appC = Get.find();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Stopwatch'),
      body: PageBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: Obx(() {
              final parts = appC.stopwatchTime.value.split(':');
              final totalSeconds =
                  int.tryParse(parts[0])! * 3600 +
                  int.tryParse(parts[1])! * 60 +
                  int.tryParse(parts[2])!;
              final ringValue = (totalSeconds % 60) / 60.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimerRing(
                    time: appC.stopwatchTime.value,
                    value: ringValue,
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _pillButton(
                        label: 'Start',
                        icon: Icons.play_arrow,
                        color: const Color(0xFF2E7D32),
                        onPressed: appC.isRunning.value
                            ? null
                            : appC.startStopwatch,
                      ),
                      const SizedBox(width: 12),
                      _pillButton(
                        label: 'Stop',
                        icon: Icons.stop,
                        color: const Color(0xFFC62828),
                        onPressed: appC.isRunning.value
                            ? appC.stopStopwatch
                            : null,
                      ),
                      const SizedBox(width: 12),
                      _pillButton(
                        label: 'Reset',
                        icon: Icons.refresh,
                        color: const Color(0xFF616161),
                        onPressed: appC.stopwatchTime.value == appC.startDisplay
                            ? null
                            : appC.resetStopwatch,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withValues(alpha: 0.25),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.time, required this.value});

  final String time;
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 12,
            strokeCap: StrokeCap.round,
            backgroundColor: kPrimary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(kSecondary),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimary, kSecondary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WAKTU',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 1,
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