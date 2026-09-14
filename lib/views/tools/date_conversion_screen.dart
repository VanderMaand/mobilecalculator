import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_controller.dart';

class DateConversionScreen extends StatefulWidget {
  @override
  _DateConversionScreenState createState() => _DateConversionScreenState();
}

class _DateConversionScreenState extends State<DateConversionScreen> {
  final AppController appC = Get.find();
  DateTime _selectedDate = DateTime.now(); // Default ke hari ini

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100), // Rentang tahun yang luas
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
      appBar: AppBar(title: Text('Konversi Kalender')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.date_range),
                label: Text('Pilih Tanggal Masehi'),
                onPressed: () => _pickDate(context),
              ),
              SizedBox(height: 30),
              Text(
                'Tanggal Terpilih:\n${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.green),
                title: Text('Kalender Hijriah'),
                subtitle: Text(appC.getHijriDate(_selectedDate)),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month, color: Colors.brown),
                title: Text('Pasaran Weton (Jawa)'),
                subtitle: Text(appC.getWeton(_selectedDate)),
              ),
              ListTile(
                leading: Icon(Icons.wb_sunny, color: Colors.orange),
                title: Text('Kalender Saka Bali'),
                subtitle: Text(appC.getSakaBali(_selectedDate)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
