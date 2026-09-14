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
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          int totalCost = snapshot.data!.fold(0, (sum, item) => sum + (item['cost'] as int));
          return Center(
            child: Text('Total Estimasi Biaya:\nRp $totalCost', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}