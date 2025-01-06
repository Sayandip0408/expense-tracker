import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'LoginScreen.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    const snackBar = SnackBar(
      content: Text('Moved to Trash!'),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Container(
          height: 45,
          padding: const EdgeInsets.only(left: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: Theme.of(context).colorScheme.tertiary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TrackStack",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: (){
                  _auth.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=> const LoginScreen()));
                },
                child: const Icon(FluentIcons.person_16_filled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}