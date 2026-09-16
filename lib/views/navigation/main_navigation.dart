import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../home/home_screen.dart';
import '../tools/stopwatch_screen.dart';
import '../help/help_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const StopwatchScreen(),
    const HelpScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final AppController appC = Get.find();
    return Scaffold(
      body: Obx(() => _screens[appC.tabIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: appC.tabIndex.value,
          onDestinationSelected: appC.changeTabIndex,
          indicatorColor: const Color(0xFFAECBFA),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Utama',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Stopwatch',
            ),
            NavigationDestination(
              icon: Icon(Icons.help_outline),
              selectedIcon: Icon(Icons.help),
              label: 'Bantuan',
            ),
          ],
        ),
      ),
    );
  }
}