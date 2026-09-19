import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../widgets/app_widgets.dart';

class ComputationScreen extends StatefulWidget {
  const ComputationScreen({super.key});

  @override
  State<ComputationScreen> createState() => _ComputationScreenState();
}

class _ComputationScreenState extends State<ComputationScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _allAssets = [];
  bool _isLoading = true;

  final Set<int> _selectedIds = {};
  String? _selectedCategory;
  String _searchQuery = '';
  String _sortBy = 'name_asc';
  bool _showPPN = false;
  final TextEditingController _budgetController = TextEditingController();
  double? _budgetTarget;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dbHelper.getAssets();
      setState(() {
        _allAssets = data;
        _selectedIds.addAll(data.map((e) => e['id'] as int));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Derived lists ──

  List<Map<String, dynamic>> get _filteredAssets {
    var list = _allAssets.where((a) {
      if (_selectedCategory != null && a['category'] != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final name = (a['name'] as String).toLowerCase();
        if (!name.contains(_searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      switch (_sortBy) {
        case 'name_asc':
          return (a['name'] as String).compareTo(b['name'] as String);
        case 'name_desc':
          return (b['name'] as String).compareTo(a['name'] as String);
        case 'cost_asc':
          return (a['cost'] as int).compareTo(b['cost'] as int);
        case 'cost_desc':
          return (b['cost'] as int).compareTo(a['cost'] as int);
        case 'quantity_asc':
          return (a['quantity'] as int).compareTo(b['quantity'] as int);
        case 'quantity_desc':
          return (b['quantity'] as int).compareTo(a['quantity'] as int);
        case 'category':
          return (a['category'] as String).compareTo(b['category'] as String);
        default:
          return 0;
      }
    });

    return list;
  }

  List<Map<String, dynamic>> get _selectedAssets {
    return _filteredAssets.where((a) => _selectedIds.contains(a['id'])).toList();
  }

  int get _totalCost {
    return _selectedAssets.fold(
      0,
      (sum, a) => sum + (a['cost'] as int) * (a['quantity'] as int),
    );
  }

  int get _totalUnits {
    return _selectedAssets.fold(0, (sum, a) => sum + (a['quantity'] as int));
  }

  Map<String, int> get _categoryTotals {
    final map = <String, int>{};
    for (final a in _selectedAssets) {
      final cat = a['category'] as String;
      map[cat] = (map[cat] ?? 0) + (a['cost'] as int) * (a['quantity'] as int);
    }
    return map;
  }

  Map<String, int> get _categoryUnits {
    final map = <String, int>{};
    for (final a in _selectedAssets) {
      final cat = a['category'] as String;
      map[cat] = (map[cat] ?? 0) + (a['quantity'] as int);
    }
    return map;
  }

  int get _mostExpensive {
    if (_selectedAssets.isEmpty) return 0;
    return _selectedAssets
        .map((a) => (a['cost'] as int) * (a['quantity'] as int))
        .reduce((a, b) => a > b ? a : b);
  }

  int get _cheapest {
    if (_selectedAssets.isEmpty) return 0;
    return _selectedAssets
        .map((a) => (a['cost'] as int) * (a['quantity'] as int))
        .reduce((a, b) => a < b ? a : b);
  }

  // ── Selection helpers ──

  void _toggleSelectAll() {
    final ids = _filteredAssets.map((a) => a['id'] as int).toSet();
    setState(() {
      if (_selectedIds.containsAll(ids)) {
        _selectedIds.removeAll(ids);
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  // ── Budget changed ──

  void _onBudgetChanged(String val) {
    final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
    setState(() => _budgetTarget = parsed != null && parsed > 0 ? parsed.toDouble() : null);
  }

  // ── Settings bottom sheet ──

  void _openSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF7F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return _SettingsSheet(
              sortBy: _sortBy,
              onSortChanged: (v) {
                setState(() => _sortBy = v);
                setSheetState(() {});
              },
              selectedCount: _selectedAssets.length,
              selectedUnits: _totalUnits,
              mostExpensive: _mostExpensive,
              cheapest: _cheapest,
              avgCost: _totalUnits > 0 ? (_totalCost / _totalUnits).round() : 0,
              showPPN: _showPPN,
              onPPNToggled: (v) {
                setState(() => _showPPN = v);
                setSheetState(() {});
              },
              budgetController: _budgetController,
              onBudgetChanged: (v) {
                _onBudgetChanged(v);
                setSheetState(() {});
              },
              budgetTarget: _budgetTarget,
              totalCost: _totalCost,
            );
          },
        );
      },
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Kalkulasi Biaya Aset'),
      body: PageBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allAssets.isEmpty
                ? _buildEmpty()
                : _buildContent(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data aset',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan aset terlebih dahulu di menu CRUD',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filtered = _filteredAssets;
    final selected = _selectedAssets;
    final catTotals = _categoryTotals;
    final catUnits = _categoryUnits;
    final allCats = AssetCategory.values.where((c) => catTotals.containsKey(c));
    final ppn = _showPPN ? (_totalCost * 0.11).round() : 0;
    final grandTotal = _totalCost + ppn;
    final selectAllActive =
        filtered.isNotEmpty && filtered.every((a) => _selectedIds.contains(a['id']));

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        children: [
          // ── SUMMARY CARD ──
          _SummaryCard(
            itemCount: _allAssets.length,
            selectedCount: selected.length,
            selectedUnits: _totalUnits,
            totalCost: _totalCost,
            showPPN: _showPPN,
            ppnAmount: ppn,
            grandTotal: grandTotal,
            mostExpensive: _mostExpensive,
            cheapest: _cheapest,
            avgCost: _totalUnits > 0 ? (_totalCost / _totalUnits).round() : 0,
            onTapSettings: _openSettingsSheet,
          ),
          const SizedBox(height: 16),

          // ── CATEGORY FILTER ──
          _CategoryDropdown(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 10),

          // ── SEARCH + SETTINGS ──
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  value: _searchQuery,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 10),
              _SettingsButton(onTap: _openSettingsSheet),
            ],
          ),
          const SizedBox(height: 12),

          // ── ACTION BUTTONS ──
          Row(
            children: [
              _ActionButton(
                label: selectAllActive ? 'Batal Pilih' : 'Pilih Semua',
                icon: selectAllActive ? Icons.deselect : Icons.select_all,
                onTap: _toggleSelectAll,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Bersihkan',
                icon: Icons.cleaning_services_outlined,
                onTap: _clearSelection,
                enabled: selected.isNotEmpty,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── ASSET ROWS ──
          if (filtered.isNotEmpty) ...[
            const SectionTitle(icon: Icons.receipt_long, label: 'RINCIAN ASET'),
            const SizedBox(height: 10),
            ...filtered.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AssetCheckbox(
                      index: entry.key,
                      asset: entry.value,
                      selected: _selectedIds.contains(entry.value['id']),
                      grandTotal: grandTotal,
                      onToggle: () {
                        final id = entry.value['id'] as int;
                        setState(() {
                          if (_selectedIds.contains(id)) {
                            _selectedIds.remove(id);
                          } else {
                            _selectedIds.add(id);
                          }
                        });
                      },
                    ),
                  ),
                ),
            const SizedBox(height: 8),
          ],

          // ── CATEGORY BREAKDOWN ──
          if (catTotals.isNotEmpty) ...[
            const SectionTitle(icon: Icons.pie_chart_outline, label: 'RINCIAN PER KATEGORI'),
            const SizedBox(height: 10),
            ...allCats.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryCard(
                  category: cat,
                  amount: catTotals[cat]!,
                  units: catUnits[cat] ?? 0,
                  share: grandTotal > 0 ? catTotals[cat]! / grandTotal : 0,
                ),
              ),
            ),
          ],

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Tidak ada aset yang cocok dengan filter',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.itemCount,
    required this.selectedCount,
    required this.selectedUnits,
    required this.totalCost,
    required this.showPPN,
    required this.ppnAmount,
    required this.grandTotal,
    required this.mostExpensive,
    required this.cheapest,
    required this.avgCost,
    required this.onTapSettings,
  });

  final int itemCount;
  final int selectedCount;
  final int selectedUnits;
  final int totalCost;
  final bool showPPN;
  final int ppnAmount;
  final int grandTotal;
  final int mostExpensive;
  final int cheapest;
  final int avgCost;
  final VoidCallback onTapSettings;

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payments_outlined, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$selectedCount/$itemCount aset dipilih • $selectedUnits unit',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Estimasi Biaya Terpilih',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatRupiah(totalCost),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showPPN) ...[
            const SizedBox(height: 4),
            Text(
              'PPN 11%: ${formatRupiah(ppnAmount)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              'Grand Total: ${formatRupiah(grandTotal)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          
          // ── TAMBAHAN SUMMARY RINGKAS DI SINI ──
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Rata-rata/unit', formatRupiah(avgCost)),
              _buildSummaryItem('Termahal', formatRupiah(mostExpensive)),
              _buildSummaryItem('Termurah', formatRupiah(cheapest)),
            ],
          ),
          const SizedBox(height: 14),
          // ─────────────────────────────────────────

          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onTapSettings,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Pengaturan',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ── Stats grid (inside settings sheet) ──

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.selectedCount,
    required this.selectedUnits,
    required this.mostExpensive,
    required this.cheapest,
    required this.avgCost,
  });

  final int selectedCount;
  final int selectedUnits;
  final int mostExpensive;
  final int cheapest;
  final int avgCost;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatTile(label: 'Aset Dipilih', value: '$selectedCount'),
            _StatTile(label: 'Total Unit', value: '$selectedUnits'),
            _StatTile(label: 'Termahal', value: formatRupiah(mostExpensive)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatTile(label: 'Termurah', value: formatRupiah(cheapest)),
            _StatTile(label: 'Rata-rata/unit', value: formatRupiah(avgCost)),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: kPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Settings bottom sheet ──

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({
    required this.sortBy,
    required this.onSortChanged,
    required this.selectedCount,
    required this.selectedUnits,
    required this.mostExpensive,
    required this.cheapest,
    required this.avgCost,
    required this.showPPN,
    required this.onPPNToggled,
    required this.budgetController,
    required this.onBudgetChanged,
    required this.budgetTarget,
    required this.totalCost,
  });

  final String sortBy;
  final ValueChanged<String> onSortChanged;
  final int selectedCount;
  final int selectedUnits;
  final int mostExpensive;
  final int cheapest;
  final int avgCost;
  final bool showPPN;
  final ValueChanged<bool> onPPNToggled;
  final TextEditingController budgetController;
  final ValueChanged<String> onBudgetChanged;
  final double? budgetTarget;
  final int totalCost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ── PENGATURAN CARD ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urutkan
                  _SortBar(value: sortBy, onChanged: onSortChanged),
                  const Divider(height: 18),

                  // Statistik ringkas
                  Text(
                    'Statistik Aset Terpilih',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatsGrid(
                    selectedCount: selectedCount,
                    selectedUnits: selectedUnits,
                    mostExpensive: mostExpensive,
                    cheapest: cheapest,
                    avgCost: avgCost,
                  ),
                  const Divider(height: 18),

                  // PPN
                  Row(
                    children: [
                      const Icon(Icons.receipt, size: 18, color: kPrimary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tampilkan PPN 11%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Switch(
                        value: showPPN,
                        onChanged: onPPNToggled,
                        activeThumbColor: kPrimary,
                      ),
                    ],
                  ),
                  const Divider(height: 18),

                  // Budget
                  Row(
                    children: [
                      const Icon(Icons.savings_outlined, size: 18, color: Color(0xFF00897B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Budget target',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Contoh: 25000000',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: onBudgetChanged,
                  ),
                  if (budgetTarget != null && budgetTarget! > 0) ...[
                    const SizedBox(height: 12),
                    _BudgetProgress(totalCost: totalCost, budget: budgetTarget!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category dropdown ──

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            categoryIcon(selectedCategory ?? ''),
            size: 18,
            color: categoryColor(selectedCategory ?? ''),
          ),
          const SizedBox(width: 8),
          const Text(
            'Kategori:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String?>(
              value: selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Semua'),
                ),
                ...AssetCategory.values.map(
                  (cat) => DropdownMenuItem<String?>(
                    value: cat,
                    child: Text(cat),
                  ),
                ),
              ],
              onChanged: onCategoryChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search ──

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari aset berdasarkan nama...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Settings button ──

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.tune, color: kPrimary, size: 22),
        ),
      ),
    );
  }
}

// ── Sort ──

class _SortBar extends StatelessWidget {
  const _SortBar({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.sort, size: 18, color: kPrimary),
        const SizedBox(width: 8),
        const Text(
          'Urutkan:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            items: const [
              DropdownMenuItem(value: 'name_asc', child: Text('Nama (A-Z)')),
              DropdownMenuItem(value: 'name_desc', child: Text('Nama (Z-A)')),
              DropdownMenuItem(value: 'cost_desc', child: Text('Biaya (Tertinggi)')),
              DropdownMenuItem(value: 'cost_asc', child: Text('Biaya (Terendah)')),
              DropdownMenuItem(value: 'quantity_desc', child: Text('Jumlah (Terbanyak)')),
              DropdownMenuItem(value: 'quantity_asc', child: Text('Jumlah (Tersedikit)')),
              DropdownMenuItem(value: 'category', child: Text('Kategori')),
            ],
onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

// ── Action buttons ──

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? kPrimary : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.white : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Budget progress ──

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.totalCost, required this.budget});

  final int totalCost;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final ratio = totalCost / budget;
    final isOver = ratio > 1.0;
    final color = isOver ? const Color(0xFFE53935) : kPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOver ? Icons.warning_amber_rounded : Icons.savings_outlined,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOver ? 'Melebihi Budget!' : 'Progres Budget',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Text(
                '${(ratio * 100).clamp(0, 999).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai: ${formatRupiah(totalCost)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                'Budget: ${formatRupiah(budget.round())}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category card ──

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.amount,
    required this.units,
    required this.share,
  });

  final String category;
  final int amount;
  final int units;
  final double share;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon(category), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$units unit',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${(share * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Asset row with checkbox ──

class _AssetCheckbox extends StatelessWidget {
  const _AssetCheckbox({
    required this.index,
    required this.asset,
    required this.selected,
    required this.grandTotal,
    required this.onToggle,
  });

  final int index;
  final Map<String, dynamic> asset;
  final bool selected;
  final int grandTotal;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final name = asset['name'] as String;
    final category = asset['category'] as String;
    final cost = asset['cost'] as int;
    final quantity = asset['quantity'] as int;
    final total = cost * quantity;
    final color = categoryColor(category);
    final share = grandTotal > 0 ? total / grandTotal : 0.0;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.4) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (_) => onToggle(),
                  activeColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(categoryIcon(category), color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. $name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.black87 : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$category • $quantity × ${formatRupiah(cost)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatRupiah(total),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selected ? kPrimary : Colors.grey[400],
                  ),
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 5,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}