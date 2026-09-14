import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';

class HelpScreen extends StatelessWidget {
  final AppController appC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bantuan')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cara Penggunaan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('1. Halaman utama memiliki 5 menu vertikal.\n2. Gunakan bottom navbar untuk ke stopwatch.\n3. Tekan Logout untuk mengakhiri sesi.'),
            Spacer(),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: appC.logout,
            )
          ],
        ),
      ),
    );
  }
}