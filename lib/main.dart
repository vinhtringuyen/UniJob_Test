import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCZAk_D6GXRBqGWQ0TRZz8Tm7cw7rAA-pw",
      authDomain: "unijob-tvu.firebaseapp.com",
      projectId: "unijob-tvu",
      storageBucket: "unijob-tvu.firebasestorage.app",
      messagingSenderId: "589137470789",
      appId: "1:589137470789:web:2afaa7b075bf9efb660a2c",
      measurementId: "G-2FR11GM9QL",
    ),
  );

  runApp(const JobMekongApp());
}

class JobMekongApp extends StatelessWidget {
  const JobMekongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIECHAY',
      home: SplashScreen(),
    );
  }
}