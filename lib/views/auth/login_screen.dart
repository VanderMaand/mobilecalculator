import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

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
        padding: const EdgeInsets.all(35.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset, size: 80, color: Colors.blue[700]),
            Text('Login Game Studio', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue[700])),
            SizedBox(height: 20),
            TextField(controller: _username, decoration: InputDecoration(labelText: 'Username (admin)',border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))) ),
            SizedBox(height: 10),
            TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: 'Password (admin)',border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))) ),
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