import 'package:flutter/material.dart';
import 'package:blood_donation_app/screens/auth/login_screen.dart';

class LifeBlood extends StatelessWidget {
  const LifeBlood({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LifeBlood",
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}