import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/database_helper.dart';
import '../../widgets/app_widgets.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
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
    final quantityController =
        TextEditingController(text: isEdit ? '${asset['quantity']}' : '1');
    final costController = TextEditingController(text: isEdit ? '${asset['cost']}' : '');
    String selectedCategory = isEdit ? asset['category'] ?? AssetCategory.hardware : AssetCategory.hardware;
    DateTime? selectedDate = isEdit && asset['purchase_date'] != null
        ? DateTime.tryParse(asset['purchase_date'] as String)
        : null;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setDialogState(() => selectedDate = picked);
              }
            }

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
                        decoration: const InputDecoration(labelText: 'Nama Aset'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: AssetCategory.values
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedCategory = value);
                          }
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Kategori wajib dipilih' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(labelText: 'Jumlah Unit'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Jumlah wajib diisi';
                          final qty = int.tryParse(value.trim());
                          if (qty == null) return 'Jumlah harus angka';
                          if (qty <= 0) return 'Jumlah harus lebih dari 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: costController,
                        decoration: const InputDecoration(labelText: 'Biaya per Unit (Rp)', prefixText: 'Rp '),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Biaya wajib diisi';
                          if (int.tryParse(value.trim()) == null) return 'Biaya harus angka';
                          if (int.parse(value.trim()) <= 0) return 'Biaya harus lebih dari 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Pengadaan (opsional)',
                            suffixIcon: Icon(Icons.event),
                          ),
                          child: Text(
                            selectedDate == null
                                ? 'Belum dipilih'
                                : DateFormat('dd MMMM yyyy').format(selectedDate!),
                            style: TextStyle(
                              color: selectedDate == null ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final data = {
                      'name': nameController.text.trim(),
                      'category': selectedCategory,
                      'quantity': int.parse(quantityController.text.trim()),
                      'cost': int.parse(costController.text.trim()),
                      'purchase_date':
                          selectedDate?.toIso8601String().split('T').first,
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
        title: const Text('Hapus Aset'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
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
      appBar: const GradientAppBar(title: 'Manajemen Aset (CRUD)'),
      body: PageBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Terjadi Kesalahan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                      ],
                    ),
                  )
                : assets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data aset',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tekan tombol + untuk menambahkan aset',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : SafeArea(
                        top: false,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
                          itemCount: assets.length,
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AssetCard(
                                asset: asset,
                                onEdit: () => _showAssetForm(asset: asset),
                                onDelete: () => _deleteData(asset['id'], asset['name']),
                              ),
                            );
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssetForm,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Aset'),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> asset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = asset['name'] as String;
    final category = asset['category'] as String;
    final cost = asset['cost'] as int;
    final quantity = asset['quantity'] as int;
    final total = cost * quantity;
    final purchaseDate = asset['purchase_date'] as String?;
    final color = categoryColor(category);

    return Container(
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
            child: Icon(categoryIcon(category), color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        purchaseDate == null
                            ? '$quantity × ${formatRupiah(cost)}'
                            : '$quantity × ${formatRupiah(cost)}  •  ${DateFormat('dd MMM yyyy').format(DateTime.parse(purchaseDate))}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E88E5)),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}