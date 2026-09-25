import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_controller.dart';

class AgeConversionScreen extends StatefulWidget {
  const AgeConversionScreen({super.key});

  @override
  State<AgeConversionScreen> createState() => _AgeConversionScreenState();
}

class _AgeConversionScreenState extends State<AgeConversionScreen> {
  static const Color _primary = Color(0xFF1565C0);
  static const Color _secondary = Color(0xFF42A5F5);

  final AppController appC = Get.find();
  DateTime? _selectedDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Memicu pembaruan UI setiap 1 detik untuk detik/menit/jam real-time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_selectedDate != null && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  _AgeData _computeAge(DateTime birthDate) {
    final now = DateTime.now();

    // Perhitungan komponen kalender
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    // Sisa waktu berjalan hari ini dari pukul 00:00:00
    int hours = now.hour;
    int minutes = now.minute;
    int seconds = now.second;

    return _AgeData(
      years < 0 ? 0 : years,
      months < 0 ? 0 : months,
      days < 0 ? 0 : days,
      hours,
      minutes,
      seconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konversi Umur Lengkap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primary, _secondary],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFAFAFA)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildIntroCard(),
                const SizedBox(height: 20),
                _buildDateCard(),
                const SizedBox(height: 20),
                if (_selectedDate != null)
                  _buildAgeResultCard(_computeAge(_selectedDate!))
                else
                  _buildEmptyHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x401565C0),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cake, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Umur Anda sejauh ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pilih tanggal lahir untuk melihat perhitungan umur secara lengkap.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    final bool hasDate = _selectedDate != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickDate(context),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
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
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event, color: _primary, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TANGGAL LAHIR',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasDate
                          ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                          : 'Belum dipilih',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: hasDate ? _primary : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_calendar, color: _primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeResultCard(_AgeData data) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.query_stats, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'HASIL PERHITUNGAN UMUR',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statTile(Icons.calendar_today, '${data.years}', 'Tahun'),
              const SizedBox(width: 12),
              _statTile(Icons.calendar_month, '${data.months}', 'Bulan'),
              const SizedBox(width: 12),
              _statTile(Icons.today, '${data.days}', 'Hari'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _detailItem(Icons.schedule, '${data.hours}', 'Jam'),
                const _DetailDot(),
                _detailItem(Icons.timer_outlined, '${data.minutes}', 'Menit'),
                const _DetailDot(),
                _detailItem(Icons.av_timer, '${data.seconds}', 'Detik'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String value, String label) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _primary, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(Icons.cake_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Silakan pilih tanggal lahir Anda\ndi bagian atas terlebih dahulu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DetailDot extends StatelessWidget {
  const _DetailDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AgeData {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  _AgeData(this.years, this.months, this.days, this.hours, this.minutes, this.seconds);
}