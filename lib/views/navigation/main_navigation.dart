import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../home/home_screen.dart';
import '../tools/stopwatch_screen.dart';
import '../help/help_screen.dart';

class MainNavigation extends StatelessWidget {
  final AppController appC = Get.find();

  final List<Widget> _screens = [HomeScreen(), StopwatchScreen(), HelpScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _screens[appC.tabIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: appC.tabIndex.value,
          onTap: appC.changeTabIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Stopwatch',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Bantuan'),
          ],
        ),
      ),
    );
  }
}
