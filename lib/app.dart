import 'package:blood_donation_app/layout/main_layout_screen.dart';
import 'package:blood_donation_app/providers/auth_provider.dart';
import 'package:blood_donation_app/routes/app_routes.dart';
import 'package:blood_donation_app/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:blood_donation_app/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class LifeBlood extends StatelessWidget {
  const LifeBlood({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..initialize(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: "LifeBlood",
            debugShowCheckedModeBanner: false,
            home: authProvider.currentUser == null
              ? const LoginScreen()
              : const MainLayoutScreen(child: DashboardPage()),
            routes: UserRoutes.routes,
          );
        },
      ),
    );
  }
}