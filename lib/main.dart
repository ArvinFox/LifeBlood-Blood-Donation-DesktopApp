import 'package:blood_donation_app/app.dart';
import 'package:blood_donation_app/constants/app_credentials.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: AppCredentials.apiKey,
      authDomain: AppCredentials.authDomain,
      appId: AppCredentials.appId,
      messagingSenderId: AppCredentials.messagingSenderId,
      projectId: AppCredentials.projectId,
      storageBucket: AppCredentials.storageBucket
    ),
  );

  await Supabase.initialize(
    url: AppCredentials.supabaseUrl,
    anonKey: AppCredentials.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const LifeBlood();
  }
}
