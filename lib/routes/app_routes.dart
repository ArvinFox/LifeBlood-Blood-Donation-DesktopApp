import 'package:blood_donation_app/layout/main_layout_screen.dart';
import 'package:blood_donation_app/screens/dashboard.dart';
import 'package:blood_donation_app/screens/donors/donors_page.dart';
import 'package:blood_donation_app/screens/donors/request_donors_page.dart';
import 'package:blood_donation_app/screens/events.dart';
import 'package:blood_donation_app/screens/medical_reports.dart';
import 'package:blood_donation_app/screens/rewards.dart';
import 'package:flutter/material.dart';

class UserRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/dashboard': (context) => MainLayoutScreen(child: DashboardPage()),
    '/donors': (context) => MainLayoutScreen(child: DonorsPage()),
    '/request-donors':
        (context) => MainLayoutScreen(child: RequestDonorsPage()),
    '/events': (context) => MainLayoutScreen(child: EventsScreen()),
    '/rewards': (context) => MainLayoutScreen(child: Rewardscreen()),
    '/medical-reports':
        (context) => MainLayoutScreen(child: MedicalReportsPage()),
  };
}
