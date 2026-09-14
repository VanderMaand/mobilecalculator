import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_controller.dart';

class AgeConversionScreen extends StatefulWidget {
  @override
  _AgeConversionScreenState createState() => _AgeConversionScreenState();
}

class _AgeConversionScreenState extends State<AgeConversionScreen> {
  final AppController appC = Get.find();
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900), // Batas tahun termuda
      lastDate: DateTime.now(), // Batas tahun maksimal (hari ini)
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Konversi Umur Lengkap')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.cake),
                label: Text('Pilih Tanggal Lahir'),
                onPressed: () => _pickDate(context),
              ),
              SizedBox(height: 30),
              if (_selectedDate != null) ...[
                Text(
                  'Tanggal Lahir: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  appC.getAgeDetails(_selectedDate!),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ] else
                Text(
                  'Silakan pilih tanggal lahir Anda terlebih dahulu.',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
