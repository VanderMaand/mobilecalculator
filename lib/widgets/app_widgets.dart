import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color kPrimary = Color(0xFF1565C0);
const Color kSecondary = Color(0xFF42A5F5);
const Color kBackgroundTop = Color(0xFFE3F2FD);

class AssetCategory {
  static const String hardware = 'Hardware';
  static const String software = 'Software';
  static const String lisensi = 'Lisensi';
  static const String aksesoris = 'Aksesoris';

  static const List<String> values = [
    hardware,
    software,
    lisensi,
    aksesoris,
  ];
}

Color categoryColor(String category) {
  switch (category) {
    case AssetCategory.hardware:
      return const Color(0xFF1E88E5);
    case AssetCategory.software:
      return const Color(0xFF00897B);
    case AssetCategory.lisensi:
      return const Color(0xFFFB8C00);
    case AssetCategory.aksesoris:
      return const Color(0xFF3949AB);
    default:
      return const Color(0xFF616161);
  }
}

IconData categoryIcon(String category) {
  switch (category) {
    case AssetCategory.hardware:
      return Icons.memory;
    case AssetCategory.software:
      return Icons.desktop_windows;
    case AssetCategory.lisensi:
      return Icons.verified_user_outlined;
    case AssetCategory.aksesoris:
      return Icons.headset;
    default:
      return Icons.inventory_2_outlined;
  }
}

String formatRupiah(num value) {
  return 'Rp ${NumberFormat('#,##0').format(value)}';
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimary, kSecondary],
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class PageBackground extends StatelessWidget {
  const PageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kBackgroundTop, Color(0xFFFAFAFA)],
        ),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
            color: Color(0xFF616161),
          ),
        ),
      ],
    );
  }
}