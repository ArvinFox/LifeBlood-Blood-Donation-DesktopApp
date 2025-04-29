import 'dart:io';
import 'package:blood_donation_app/app.dart';
import 'package:blood_donation_app/constants/app_credentials.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('LifeBlood');
    
    // Set min and initial size
    const minSize = Size(1600, 900);
    const initialSize = Size(1600, 900);

    setWindowMinSize(minSize);
    setWindowMaxSize(Size.infinite);

    final info = await getWindowInfo();
    final screen = info.screen;

    if (screen != null) {
      final screenFrame = screen.visibleFrame;
      final left = screenFrame.left + (screenFrame.width - initialSize.width) / 2;
      final top = screenFrame.top + (screenFrame.height - initialSize.height) / 2;
      final frame = Rect.fromLTWH(left, top, initialSize.width, initialSize.height);
      setWindowFrame(frame);
    }
  }
  
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
