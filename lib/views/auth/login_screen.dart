import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';

class LoginScreen extends StatelessWidget {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final AppController appC = Get.find();

  @override
  Widget build(BuildContext context) {
    if (appC.isLoggedIn.value) {
      Future.microtask(() => Get.offAllNamed('/main'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset, size: 80, color: Colors.deepPurple),
            SizedBox(height: 20),
            TextField(controller: _username, decoration: InputDecoration(labelText: 'Username (admin)')),
            TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: 'Password (admin)')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => appC.login(_username.text, _password.text),
              child: Text('LOGIN'),
            )
          ],
        ),
      ),
    );
  }
}