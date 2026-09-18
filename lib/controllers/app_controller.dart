import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';

class AppController extends GetxController {
  // Navigation
  var tabIndex = 0.obs;
  
  // Session
  var isLoggedIn = false.obs;

  // Stopwatch
  var stopwatchTime = "00:00:00".obs;
  var isRunning = false.obs;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // Sesi Login
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLogged') ?? false;
  }

  Future<void> login(String username, String password) async {
    if (username == 'admin' && password == 'admin') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogged', true);
      isLoggedIn.value = true;
      Get.offAllNamed('/main');
    } else {
      Get.snackbar('Error', 'Username atau Password salah');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogged');
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  // Stopwatch Logic
  void startStopwatch() {
    if (!isRunning.value) {
      _stopwatch.start();
      isRunning.value = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        stopwatchTime.value = _formatDuration(_stopwatch.elapsed);
      });
    }
  }

  void stopStopwatch() {
    _stopwatch.stop();
    isRunning.value = false;
    _timer?.cancel();
  }

  void resetStopwatch() {
    _stopwatch.reset();
    stopwatchTime.value = "00:00:00";
    stopStopwatch();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Fungsi Konversi
String getAgeDetails(DateTime birthDate) {
  final now = DateTime.now();

  if (birthDate.isAfter(now)) {
    return "Tanggal lahir belum terjadi";
  }

  // 1. Hitung Tahun, Bulan, dan Hari (berbasis tanggal 00:00)
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

  // 2. Waktu sisa berjalan hari ini (berhitung dari 00:00:00)
  int hours = now.hour;
  int minutes = now.minute;
  int seconds = now.second;

  return "$years Tahun, $months Bulan, $days Hari,\n$hours Jam, $minutes Menit, $seconds Detik";
}

  String getHijriDate(DateTime date) {
    var hDate = HijriCalendar.fromDate(date);
    return hDate.toFormat("dd MMMM yyyy");
  }

  String getWeton(DateTime date) {
    final pasaran = ['Wage', 'Kliwon', 'Legi', 'Pahing', 'Pon'];
    final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    int dayIndex = date.weekday % 7;
    int diff = date.difference(DateTime(1970, 1, 1)).inDays;
    int pasaranIndex = (diff % 5).abs();
    return "${dayNames[dayIndex]} ${pasaran[pasaranIndex]}";
  }

  String getSakaBali(DateTime date) {
    const sakaMonths = [
      'Chaitra', 'Vaisakha', 'Jyeshtha', 'Ashadha',
      'Shravana', 'Bhadra', 'Ashwin', 'Kartik',
      'Margashirsha', 'Pausha', 'Magha', 'Phalguna',
    ];
    int sakaYear = date.year - 78;
    DateTime sakaStart = DateTime(date.year, 3, 21);
    if (date.isBefore(sakaStart)) {
      sakaStart = DateTime(date.year - 1, 3, 21);
      sakaYear--;
    }
    int dayCount = date.difference(sakaStart).inDays;
    int month = (dayCount / 30).floor();
    int day = (dayCount % 30) + 1;
    if (month >= 12) {
      month = 11;
      day = (dayCount - 330) + 1;
      if (day > 30) day = 30;
    }
    return "$day ${sakaMonths[month]} $sakaYear Saka";
  }
}