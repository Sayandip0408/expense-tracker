import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String? gender;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create your Account",
                  style: GoogleFonts.inter(fontSize: 35, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 20),
                Text(
                  "Enter your details to create an account",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(height: 20),
                Text(
                  "Name",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
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
                      labelText: "Enter your Name",
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary),
                      prefixIcon: Icon(
                        FluentIcons.person_20_regular,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Email",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
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
                SizedBox(height: 20),
                Text(
                  "Password",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    obscuringCharacter: "*",
                    controller: passController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
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
                      labelText: "Enter your password",
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
                SizedBox(height: 20),
                Text(
                  "Gender",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Male', style: GoogleFonts.inter()),
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Female', style: GoogleFonts.inter()),
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                InkWell(
                  splashColor: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passController.text,
                        );
                        String image = "";
                        if(gender == "Male"){
                          image = "https://res.cloudinary.com/dgb69w56a/image/upload/v1736219943/expense-tracker/g3ftoyoy8zdw19fo90hm.png";
                        }
                        else{
                          image = "https://res.cloudinary.com/dgb69w56a/image/upload/v1736219942/expense-tracker/d62cxzgxhshhvpwa741g.png";
                        }
                        // Add user details to Firestore
                        FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                          'name': nameController.text,
                          'email': emailController.text,
                          'password': passController.text,
                          'gender': gender,
                          'balance': 0,
                          'user_id': userCredential.user!.uid,
                          'dp': image
                        });

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } catch (e) {
                        debugPrint(e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Signup failed. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.inter(),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: Text(
                        " Log In",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
