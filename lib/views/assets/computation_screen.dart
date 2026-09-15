import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class ComputationScreen extends StatelessWidget {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kalkulasi Biaya')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Gagal Memuat Data Aset',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }
          final assets = snapshot.data ?? [];
          final itemCount = assets.length;

          if (itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data aset', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Text('Tambahkan aset terlebih dahulu di menu CRUD', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          int totalCost = assets.fold(0, (sum, item) => sum + (item['cost'] as int));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Jumlah Aset: $itemCount', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      Text('Total Estimasi Biaya:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Text('Rp $totalCost',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('Rincian Aset:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...assets.asMap().entries.map((entry) {
                final index = entry.key;
                final asset = entry.value;
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(asset['name']),
                    subtitle: Text(asset['type']),
                    trailing: Text(
                      'Rp ${asset['cost']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}