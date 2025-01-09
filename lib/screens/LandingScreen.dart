import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/HistoryScreen.dart';
import 'package:expense_tracker/screens/HomeScreen.dart';
import 'package:expense_tracker/screens/ProfileScreen.dart';
import 'package:expense_tracker/screens/ReportScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int currentPageIndex = 0;
  final user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userDetails;

  // Variables for Transaction Bottom Sheet
  String transactionType = "Debit";
  String category = "Food";
  String product = "";
  double? amount;
  DateTime? transactionDate;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      if (user != null) {
        print("Fetching user details for email: ${user!.email}");

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user!.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Assuming only one document matches the email
          final userDoc = querySnapshot.docs.first.data();

          setState(() {
            userDetails = userDoc; // Update state with fetched data
          });
        } else {
          print("No document found for email: ${user!.email}");
        }
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void _selectTransactionDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        transactionDate = pickedDate;
      });
    }
  }

  void _showTransactionBottomSheet(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "New Transaction",
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(24, 65, 44, 1)),
                  ),
                  const SizedBox(height: 16),
                  // Transaction Type
                  DropdownButtonFormField<String>(
                    value: transactionType,
                    items: ["Debit", "Credit"]
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        transactionType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Transaction Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category
                  DropdownButtonFormField<String>(
                    value: category,
                    items: [
                      "Food",
                      "Electronics",
                      "Travel",
                      "Services",
                      "Outfits",
                      "Grooming",
                      "Gift",
                      "Fees",
                      "Others"
                    ]
                        .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an amount.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      amount = double.tryParse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Product
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Product",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a product.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      product = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Transaction Date
                  GestureDetector(
                    onTap: () => _selectTransactionDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: transactionDate != null
                              ? "${transactionDate!.day}th ${transactionDate!.month}, ${transactionDate!.year}"
                              : "Select Date",
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (transactionDate == null) {
                            return "Please select a date.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(
                          24, 65, 44, 1), // Set the background color
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final now = DateTime.now();
                        transactionDate = DateTime(
                          transactionDate!.year,
                          transactionDate!.month,
                          transactionDate!.day,
                          now.hour,
                          now.minute,
                          now.second,
                        );

                        // Create a new document in the 'expenses' collection
                        try {
                          final transactionRef = FirebaseFirestore.instance
                              .collection('expenses')
                              .doc();

                          // Save the transaction details in Firestore
                          await transactionRef.set({
                            'type': transactionType,
                            'category': category,
                            'amount': amount, // Ensure amount is double
                            'product': product,
                            'transaction_date': transactionDate,
                            'owner': user!
                                .email, // owner is the logged-in user's email
                            '_id': transactionRef.id, // _id is the document ID
                          });

                          print("Transaction saved to Firebase:");
                          print("Type: $transactionType");
                          print("Category: $category");
                          print("Amount: $amount");
                          print("Product: $product");
                          print(
                              "Date: ${transactionDate!.day}th ${transactionDate!.month}, ${transactionDate!.year}");

                          // Update the user's balance
                          if (user != null) {
                            final userDoc = FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isEqualTo: user!.email)
                                .limit(1);

                            final userSnapshot = await userDoc.get();
                            if (userSnapshot.docs.isNotEmpty) {
                              // Get current balance (ensure it's treated as a double)
                              double currentBalance = userSnapshot
                                  .docs.first['balance']
                                  ?.toDouble() ??
                                  0.0;

                              // Calculate new balance based on transaction type
                              double newBalance = (transactionType == 'Debit')
                                  ? currentBalance -
                                  (amount ??
                                      0.0) // Ensure amount is treated as a double
                                  : currentBalance +
                                  (amount ??
                                      0.0); // Ensure amount is treated as a double

                              // Update the balance in the 'users' collection
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userSnapshot.docs.first
                                  .id) // Use the document ID of the user
                                  .update({
                                'balance': newBalance,
                              });
                            }
                          }

                          Navigator.pop(
                              context); // Safely close the bottom sheet
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LandingScreen()));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving transaction. $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      "Save Transaction",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (index == 2) {
            // Open bottom sheet when Transaction is selected
            _showTransactionBottomSheet(context);
          } else {
            setState(() {
              currentPageIndex = index;
            });
          }
        },
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              FluentIcons.home_12_filled,
              color: Color.fromRGBO(24, 65, 44, 1),
            ),
            icon: Icon(FluentIcons.home_12_regular,
                color: Color.fromRGBO(24, 65, 44, 1)),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(FluentIcons.chart_person_20_filled,
                color: Color.fromRGBO(24, 65, 44, 1)),
            icon: Icon(FluentIcons.chart_person_20_regular,
                color: Color.fromRGBO(24, 65, 44, 1)),
            label: 'Reports',
          ),
          NavigationDestination(
            selectedIcon: Icon(FluentIcons.add_circle_16_filled,
                color: Color.fromRGBO(24, 65, 44, 1)),
            icon: Icon(FluentIcons.add_circle_16_regular,
                color: Color.fromRGBO(24, 65, 44, 1)),
            label: 'Transaction',
          ),
          NavigationDestination(
            selectedIcon: Icon(FluentIcons.receipt_16_filled,
                color: Color.fromRGBO(24, 65, 44, 1)),
            icon: Icon(FluentIcons.receipt_16_regular,
                color: Color.fromRGBO(24, 65, 44, 1)),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(FluentIcons.person_accounts_20_filled,
                color: Color.fromRGBO(24, 65, 44, 1)),
            icon: Icon(FluentIcons.person_accounts_20_regular,
                color: Color.fromRGBO(24, 65, 44, 1)),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        HomeScreen(),
        ReportScreen(),
        Container(),
        HistoryScreen(),
        ProfileScreen(),
      ][currentPageIndex],
    );
  }
}
