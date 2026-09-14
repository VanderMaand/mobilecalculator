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
    final diff = now.difference(birthDate);
    final years = (diff.inDays / 365).floor();
    final months = ((diff.inDays % 365) / 30).floor();
    final days = (diff.inDays % 365) % 30;
    return "$years Tahun, $months Bulan, $days Hari,\n${diff.inHours} Jam, ${diff.inMinutes} Menit, ${diff.inSeconds} Detik";
  }

  String getHijriDate(DateTime date) {
    var hDate = HijriCalendar.fromDate(date);
    return hDate.toFormat("dd MMMM yyyy");
  }

  String getWeton(DateTime date) {
    // Referensi 1 Jan 1970 adalah Wage
    final pasaran = ['Wage', 'Kliwon', 'Legi', 'Pahing', 'Pon'];
    final diff = date.difference(DateTime(1970, 1, 1)).inDays;
    return pasaran[(diff % 5).abs()];
  }

  String getSakaBali(DateTime date) {
    int sakaYear = date.year - 78;
    return "Tahun Saka $sakaYear";
  }
}