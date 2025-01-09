import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/utils/CupertinoList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://sayandip-adhikary.vercel.app');

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userDetails;

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void initState() {
    super.initState();
    _listenToUserDetails();
  }

  void _listenToUserDetails() {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user!.email)
          .snapshots() // Listen for real-time updates
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first.data();
          print("User document found:");

          setState(() {
            userDetails = userDoc; // Update state with the fetched data
          });
        } else {
          print("No document found for email: ${user!.email}");
        }
      });
    } else {
      print("No user is currently logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Your Profile",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(24, 65, 44, 1)),
        ),
      ),
      body: userDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userDetails!['dp']),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userDetails!['name'],
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                userDetails!['email'],
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54),
              ),
              const SizedBox(height: 10),
              CupertinoList(
                balance: userDetails!['balance']?.toDouble() ?? 0.0,
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Developed by "),
                  TextButton(
                    onPressed: (){
                      _launchUrl();
                    },
                    child: Text("SayanDip Adhikary ",
                      style:
                      GoogleFonts.inter(fontWeight: FontWeight.w600),),
                  ),
                  Icon(
                    FluentIcons.arrow_right_12_regular,
                    size: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
