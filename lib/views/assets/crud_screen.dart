import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> assets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final data = await dbHelper.getAssets();
    setState(() => assets = data);
  }

  _addData() async {
    await dbHelper.insertAsset({'name': '3D Model Karakter', 'type': '3D', 'cost': 1500000});
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Aset (CRUD)')),
      body: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return ListTile(
            title: Text(asset['name']),
            subtitle: Text('${asset['type']} - Rp ${asset['cost']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await dbHelper.deleteAsset(asset['id']);
                _loadData();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addData,
        child: Icon(Icons.add),
      ),
    );
  }
}