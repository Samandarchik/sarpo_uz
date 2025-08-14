import 'package:flutter/material.dart';

class TimeBasedButton extends StatelessWidget {
  TimeBasedButton({super.key});

  final DateTime now = DateTime.now();

  bool isBetweenTime(int startHour, int endHour) {
    print("Current time: ${now.hour}:${now.minute}");
    print("Checking if between $startHour:00 and $endHour:00");
    return now.hour >= startHour && now.hour < endHour;
  }

  @override
  Widget build(BuildContext context) {
    return isBetweenTime(8, 10)
        ? IconButton(
            icon: const Icon(Icons.location_on, size: 30, color: Colors.white),
            onPressed: () {
              // Button bosilganda nima bo'lishini keyin yozasiz
              debugPrint("Location button pressed");
            },
          )
        : SizedBox();
  }
}
