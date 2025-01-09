import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BalanceScreen extends StatefulWidget {
  final double balanceVal;
  const BalanceScreen({super.key, required this.balanceVal});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Use Indian locale for proper formatting
    symbol: '₹', // Include the currency symbol if needed
    decimalDigits: 2, // Number of decimal digits
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(FluentIcons.chevron_left_12_regular),
        ),
        title: Text(
          "Back",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'images/check.jpg',
                height: 200,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Your current balance is:',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                formatter.format(widget.balanceVal),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  color: Color.fromRGBO(24, 65, 44, 1),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                  backgroundColor: Color.fromRGBO(24, 65, 44, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Done",
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
