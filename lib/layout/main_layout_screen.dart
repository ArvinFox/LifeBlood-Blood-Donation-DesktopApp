import 'package:blood_donation_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:blood_donation_app/components/sidebar.dart';
import 'package:provider/provider.dart';

class MainLayoutScreen extends StatelessWidget {
  final Widget child;
  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.power_settings_new, color: Colors.white),
                      onPressed: () {
                        authProvider.logout();
                        // Navigator.pushNamedAndRemoveUntil(
                        //   context, 
                        //   '/login', 
                        //   (route) => false,
                        // );
                      },
                    ),
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
