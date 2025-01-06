import 'dart:async';

import 'package:expense_tracker/screens/HomeScreen.dart';
import 'package:expense_tracker/screens/LoginScreen.dart';
import 'package:expense_tracker/themes/lightTheme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackStack',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    final user = _auth.currentUser;
    if(user != null){
      Timer(const Duration(milliseconds: 500),
              ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomeScreen())));
    }
    else{
      Timer(const Duration(milliseconds: 500),
              ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen())));
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("images/Splash.png", height: 200, width: 200,),
              Text("Keep Workplace",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        )
    );
  }
}