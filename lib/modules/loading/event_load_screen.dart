import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EventLoadScreen extends StatelessWidget {
  const EventLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset("assets/lottie/event_search.json",
            height: 900, fit: BoxFit.fitWidth),
      ),
    );
  }
}
