import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> assets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await dbHelper.getAssets();
      setState(() {
        assets = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAssetForm({Map<String, dynamic>? asset}) {
    final isEdit = asset != null;
    final nameController = TextEditingController(text: isEdit ? asset['name'] : '');
    final typeController = TextEditingController(text: isEdit ? asset['type'] : '');
    final costController = TextEditingController(text: isEdit ? '${asset['cost']}' : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Aset' : 'Tambah Aset'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nama Aset'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: typeController,
                    decoration: InputDecoration(labelText: 'Tipe Aset'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Tipe wajib diisi' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    decoration: InputDecoration(labelText: 'Biaya (Rp)', prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Biaya wajib diisi';
                      if (int.tryParse(value.trim()) == null) return 'Biaya harus angka';
                      if (int.parse(value.trim()) <= 0) return 'Biaya harus lebih dari 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'name': nameController.text.trim(),
                  'type': typeController.text.trim(),
                  'cost': int.parse(costController.text.trim()),
                };
                Navigator.pop(context);
                if (isEdit) {
                  await _updateData(asset['id'], data);
                } else {
                  await _addData(data);
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addData(Map<String, dynamic> data) async {
    try {
      await dbHelper.insertAsset(data);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil ditambahkan'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateData(int id, Map<String, dynamic> data) async {
    try {
      await dbHelper.updateAsset(id, data);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil diperbarui'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteData(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Aset'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await dbHelper.deleteAsset(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Aset (CRUD)')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Terjadi Kesalahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: Text('Coba Lagi')),
                    ],
                  ),
                )
              : assets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada data aset', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          SizedBox(height: 8),
                          Text('Tekan tombol + untuk menambahkan aset', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(asset['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${asset['type']}  •  Rp ${asset['cost']}',
                              style: TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAssetForm(asset: asset),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteData(asset['id'], asset['name']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssetForm,
        icon: Icon(Icons.add),
        label: Text('Tambah Aset'),
      ),
    );
  }
}