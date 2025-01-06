import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/SignupScreen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              "images/logo_low.png",
              height: 33,
              width: 25,
            ),
            Text(
              " TrackStack",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Sign in to your Account",
              style:
                  GoogleFonts.inter(fontSize: 35, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20,),
            Text(
              "Enter your email and password to login",
              style: GoogleFonts.inter(),
            ),
            SizedBox(height: 20,),
            Text(
              "Email",
              style: GoogleFonts.inter(),
            ),
            SizedBox(height: 10,),
            SizedBox(
              height: 45,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: "Enter your Email",
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary),
                  prefixIcon: Icon(
                    FluentIcons.mail_20_regular,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20,),
            Text(
              "Password",
              style: GoogleFonts.inter(),
            ),
            SizedBox(height: 10,),
            SizedBox(
              height: 45,
              child: TextField(
                keyboardType: TextInputType.text,
                obscureText: true,
                obscuringCharacter: "*",
                controller: passController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: "Enter password",
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary),
                  prefixIcon: Icon(
                    FluentIcons.password_20_regular,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              splashColor: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                try {
                  await _auth.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passController.text);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                } catch (e) {
                  debugPrint(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed. Invalid email or password.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Ink(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoColors.activeBlue,
                ),
                child: const Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have and account?",
                  style: GoogleFonts.inter(),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SignupScreen()));
                  },
                  child: Text(
                    " Sign Up",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
