import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'members_screen.dart';
import '../assets/computation_screen.dart';
import '../assets/crud_screen.dart';
import '../tools/age_conversion_screen.dart';
import '../tools/date_conversion_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Utama')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuBtn('1. Daftar Anggota', () => Get.to(() => MembersScreen())),
            _buildMenuBtn('2. Kalkulasi Biaya Aset', () => Get.to(() => ComputationScreen())),
            _buildMenuBtn('3. Kelola Data Aset (CRUD)', () => Get.to(() => CrudScreen())),
            _buildMenuBtn('4. Konversi Umur', () => Get.to(() => AgeConversionScreen())),
            _buildMenuBtn('5. Konversi Kalender', () => Get.to(() => DateConversionScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBtn(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: Size(250, 50)),
        onPressed: onTap,
        child: Text(title),
      ),
    );
  }
}