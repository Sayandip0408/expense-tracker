import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> expenseData;

  const TransactionDetailScreen({super.key, required this.expenseData});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN', // Use Indian locale for proper formatting
      symbol: '₹', // Include the currency symbol if needed
      decimalDigits: 2, // Number of decimal digits
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              expenseData['category'] == 'Fees'
                                  ? 'images/Fees.png'
                                  : expenseData['category'] == 'Travel'
                                  ? 'images/Travel.png'
                                  : expenseData['category'] == 'Food'
                                  ? 'images/Food.png'
                                  : expenseData['category'] == 'Gift'
                                  ? 'images/Gift.png'
                                  : expenseData['category'] == 'Electronics'
                                  ? 'images/Electronics.png'
                                  : expenseData['category'] == 'Outfits'
                                  ? 'images/Outfit.png'
                                  : expenseData['category'] == 'Services'
                                  ? 'images/Services.png'
                                  : expenseData['category'] == 'Grooming'
                                  ? 'images/Grooming.png'
                                  : 'images/Others.png',
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text('Category: ${expenseData['category']}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Purpose: ',style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                          Text('${expenseData['product']}',style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Amount: ',style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                          Text(formatter.format(expenseData['amount']),style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Type: ',style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                          Text('${expenseData['type']}',style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Date: ',style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                          Text(DateFormat('d MMM, yyyy').format(expenseData['transaction_date'].toDate()),style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      // Add any other fields you'd like to display
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Developed by "),
                Text("SayanDip Adhikary ", style: GoogleFonts.inter(fontWeight: FontWeight.w600),),
                Icon(FluentIcons.arrow_right_12_regular, size: 15,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
