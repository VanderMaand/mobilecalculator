import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';

class StopwatchScreen extends StatelessWidget {
  final AppController appC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(appC.stopwatchTime.value, style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold))),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: appC.startStopwatch, child: Text('Start')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: appC.stopStopwatch, child: Text('Stop')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: appC.resetStopwatch, child: Text('Reset')),
              ],
            )
          ],
        ),
      ),
    );
  }
}