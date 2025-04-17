import 'package:flutter/material.dart';
import 'package:blood_donation_app/components/sidebar.dart';

class MainLayoutScreen extends StatelessWidget {
  final Widget child;
  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            color: Colors.red[700],
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/icons/life_blood_logo.png', height: 70),
                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: Colors.white),
                    SizedBox(width: 20),
                    Icon(Icons.power_settings_new, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                const Sidebar(),
                Container(width: 1, color: Colors.black),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
