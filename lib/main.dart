import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/app_controller.dart';
import 'views/auth/login_screen.dart';
import 'views/navigation/main_navigation.dart';

void main() {
  Get.put(AppController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Game Studio App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/main', page: () => MainNavigation()),
      ],
    );
  }
}
