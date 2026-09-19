import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../assets/computation_screen.dart';
import '../assets/crud_screen.dart';
import '../tools/age_conversion_screen.dart';
import '../tools/date_conversion_screen.dart';
import 'members_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appC = Get.find();
    return Scaffold(
      appBar: const GradientAppBar(title: 'Dashboard Utama'),
      body: PageBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Obx(
                () => _WelcomeHeader(
                  name: appC.loggedUser.value.isEmpty
                      ? 'Pengguna'
                      : appC.loggedUser.value,
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle(icon: Icons.apps, label: 'MENU APLIKASI'),
              const SizedBox(height: 12),
              _MenuCard(
                number: '1',
                title: 'Daftar Anggota',
                subtitle: 'Lihat daftar anggota kelompok',
                color: const Color(0xFF1E88E5),
                icon: Icons.groups,
                onTap: () => Get.to(() => const MembersScreen()),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                number: '2',
                title: 'Kalkulasi Biaya Aset',
                subtitle: 'Total biaya perangkat & lisensi produksi per kategori',
                color: const Color(0xFF00897B),
                icon: Icons.payments_outlined,
                onTap: () => Get.to(() => ComputationScreen()),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                number: '3',
                title: 'Kelola Aset Produksi (CRUD)',
                subtitle: 'Tambah, edit, dan hapus perangkat, software, dan lisensi',
                color: const Color(0xFFFB8C00),
                icon: Icons.inventory_2_outlined,
                onTap: () => Get.to(() => const CrudScreen()),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                number: '4',
                title: 'Konversi Umur',
                subtitle: 'Hitung umur lengkap dari tanggal lahir',
                color: const Color(0xFF3949AB),
                icon: Icons.cake_outlined,
                onTap: () => Get.to(() => const AgeConversionScreen()),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                number: '5',
                title: 'Konversi Kalender',
                subtitle: 'Konversi ke kalender Hijriah, Jawa, dan Saka',
                color: const Color(0xFF00ACC1),
                icon: Icons.calendar_month,
                onTap: () => Get.to(() => const DateConversionScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary, kSecondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dashboard, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola anggota, aset, dan tool konversi dalam satu aplikasi.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$number. $title',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}