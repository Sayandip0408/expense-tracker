import 'package:expense_tracker/screens/BalanceScreen.dart';
import 'package:expense_tracker/screens/HistoryScreenTwo.dart';
import 'package:expense_tracker/screens/ReportScreenTwo.dart';
import 'package:expense_tracker/screens/TransactionScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/LoginScreen.dart';

class CupertinoList extends StatelessWidget {
  final double balance;
  const CupertinoList({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;

    return CupertinoPageScaffold(
      child: CupertinoListSection(
        header: const Text('Inventory'),
        children: <CupertinoListTile>[
          CupertinoListTile(
            title: Text('Check Balance', style: GoogleFonts.inter(fontSize: 16,),),
            leading: Icon(FluentIcons.money_16_filled, color: CupertinoColors.activeBlue,),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return BalanceScreen(balanceVal: balance);
                },
              ),
            ),
          ),
          CupertinoListTile(
            title:  Text('Deposit Amount', style: GoogleFonts.inter(fontSize: 16,),),
            leading: Icon(FluentIcons.add_circle_12_regular, color: Colors.green,),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const TransactionScreen(transactionType: "Credit");
                },
              ),
            ),
          ),
          CupertinoListTile(
            title:  Text('Deduct Amount', style: GoogleFonts.inter(fontSize: 16,),),
            leading: Icon(FluentIcons.subtract_circle_12_regular, color: Colors.redAccent,),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const TransactionScreen(transactionType: "Debit");
                },
              ),
            ),
          ),
          CupertinoListTile(
            title: Text('Transaction History', style: GoogleFonts.inter(fontSize: 16,),),
            leading: Icon(FluentIcons.history_16_filled, color: Colors.brown,),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const HistoryScreenTwo();
                },
              ),
            ),
          ),
          CupertinoListTile(
            title: Text('Analytics', style: GoogleFonts.inter(fontSize: 16,),),
            leading: Icon(FluentIcons.data_area_20_filled, color: Colors.orange,),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const ReportScreenTwo();
                },
              ),
            ),
          ),
          CupertinoListTile(
              title:  Text('Log Out', style: GoogleFonts.inter(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),),
              leading: Icon(FluentIcons.sign_out_20_filled, color: Colors.red,),
              trailing: const CupertinoListTileChevron(),
              onTap: () {
                _auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=> const LoginScreen()));
              }
          ),
        ],
      ),
    );
  }
}

