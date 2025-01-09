import 'package:expense_tracker/screens/HistoryScreenTwo.dart';
import 'package:expense_tracker/screens/ReportScreenTwo.dart';
import 'package:expense_tracker/screens/TransactionScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'TransactionDetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userDetails;

  double creditSum = 0;
  double debitSum = 0;

  @override
  void initState() {
    super.initState();
    _listenToUserDetails();
    _fetchTransactionSums();
  }

  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Use Indian locale for proper formatting
    symbol: '₹', // Include the currency symbol if needed
    decimalDigits: 2, // Number of decimal digits
  );

  // Function to fetch expenses from Firestore
  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('owner', isEqualTo: user!.email)
          .orderBy('transaction_date', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching expenses: $e");
      return [];
    }
  }

  // Listen to changes in user details in real-time
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

  Future<void> _fetchTransactionSums() async {
    try {
      if (user != null) {
        DateTime now = DateTime.now();
        DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));

        // Convert the DateTime to Timestamp format for querying Firestore
        Timestamp thirtyDaysAgoTimestamp = Timestamp.fromDate(thirtyDaysAgo);

        // Listen to changes in the 'expenses' collection
        FirebaseFirestore.instance
            .collection('expenses')
            .where('owner', isEqualTo: user!.email)
            .where('transaction_date',
            isGreaterThanOrEqualTo: thirtyDaysAgoTimestamp)
            .snapshots() // Use snapshots() for real-time updates
            .listen((querySnapshot) {
          print("Query snapshot docs: ${querySnapshot.docs.length}");

          double tempCreditSum = 0;
          double tempDebitSum = 0;

          for (var doc in querySnapshot.docs) {
            var transaction = doc.data();

            // Ensure transaction is valid
            if (transaction.isNotEmpty) {
              Timestamp transactionTimestamp = transaction['transaction_date'];
              DateTime transactionDate = transactionTimestamp.toDate();

              // Log transaction data
              print("Transaction Date: $transactionDate");
              print("Transaction Type: ${transaction['type']}");
              print("Transaction Amount: ${transaction['amount']}");

              // Check if the transaction date is within the last 30 days
              if (transactionDate.isAfter(thirtyDaysAgo) &&
                  transactionDate.isBefore(now)) {
                if (transaction['type'] == 'Credit') {
                  tempCreditSum += (transaction['amount'] as num).toDouble();
                } else if (transaction['type'] == 'Debit') {
                  tempDebitSum += (transaction['amount'] as num).toDouble();
                }
              }
            }
          }

          setState(() {
            creditSum = tempCreditSum;
            debitSum = tempDebitSum;
          });

          print("Total Credit Sum: $creditSum");
          print("Total Debit Sum: $debitSum");
        });
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: userDetails != null && userDetails!.isNotEmpty
            ? Row(
          children: [
            if (userDetails!['dp'] != null)
              SizedBox(
                height: 30,
                width: 30,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userDetails!['dp']),
                ),
              ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Color.fromRGBO(118, 159, 140, 1),
                  ),
                ),
                Text(
                  userDetails!['name'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(24, 65, 44, 1),
                  ),
                ),
              ],
            ),
          ],
        )
            : const Text("Loading..."),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Balance",
                style: GoogleFonts.inter(
                  color: Color.fromRGBO(118, 159, 140, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              userDetails != null
                  ? (userDetails!.isEmpty
                  ? const Text(
                "User details not found.",
                style: TextStyle(
                    color: Color.fromRGBO(24, 65, 44, 1),
                    fontSize: 24),
              )
                  : Text(
                formatter.format(userDetails!['balance']),
                style: GoogleFonts.inter(
                  color: Color.fromRGBO(24, 65, 44, 1),
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ))
                  : const CircularProgressIndicator(),
              const SizedBox(height: 30),
              Text("In This Month (Total) ~", style: GoogleFonts.inter(color: Color.fromRGBO(24, 65, 44, 1), fontWeight: FontWeight.w500),),
              const SizedBox(height: 10),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Credit Container
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    // margin: const EdgeInsets.only(right: 5), // Add spacing between the containers
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(24, 65, 44, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min, // Adjusts height based on content
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.arrow_circle_down_12_regular, color: Color.fromRGBO(113, 213, 97, 1), size: 18,),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          formatter.format(creditSum),
                          style: GoogleFonts.inter(
                            color: Color.fromRGBO(113, 213, 97, 1),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Debit Container
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    // margin: const EdgeInsets.only(left: 5), // Add spacing between the containers
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(113, 213, 97, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min, // Adjusts height based on content
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.arrow_circle_up_12_regular, color: Colors.red, size: 22,),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          formatter.format(debitSum),
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      InkWell(
                        splashColor: Color.fromRGBO(215, 255, 209, 1),
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionScreen(
                                transactionType: "Credit",
                              ),
                            ),
                          );
                        },
                        child: Ink(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(
                              FluentIcons.arrow_down_12_filled,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Deposit",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        splashColor: Color.fromRGBO(255, 209, 209, 1),
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionScreen(
                                transactionType: "Debit",
                              ),
                            ),
                          );
                        },
                        child: Ink(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(
                              FluentIcons.arrow_up_12_filled,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Deduct",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        splashColor: Color.fromRGBO(255, 219, 162, 1),
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreenTwo(),
                            ),
                          );
                        },
                        child: Ink(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(
                              FluentIcons.history_16_filled,
                              color: Color.fromRGBO(243, 156, 18, 1),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "History",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        splashColor: Color.fromRGBO(183, 233, 255, 1),
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportScreenTwo(),
                            ),
                          );
                        },
                        child: Ink(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(
                              FluentIcons.chart_person_20_regular,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Reports",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Recent Transactions",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(24, 65, 44, 1),
                            ),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 40),
                                backgroundColor: Color.fromRGBO(24, 65, 44, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistoryScreenTwo(),
                                  ),
                                );
                              },
                              child: Text(
                                "See all",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 360,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchExpenses(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final expenses = snapshot.data ?? [];

                            if (expenses.isEmpty) {
                              return const Center(
                                  child: Text('No transactions found.'));
                            }

                            return ListView.builder(
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenses[index];
                                return ListTile(
                                  leading: ClipOval(
                                    child: Image.asset(
                                      expense['category'] == 'Fees'
                                          ? 'images/Fees.png'
                                          : expense['category'] == 'Travel'
                                          ? 'images/Travel.png'
                                          : expense['category'] == 'Food'
                                          ? 'images/Food.png'
                                          : expense['category'] ==
                                          'Gift'
                                          ? 'images/Gift.png'
                                          : expense['category'] ==
                                          'Electronics'
                                          ? 'images/Electronics.png'
                                          : expense['category'] ==
                                          'Outfits'
                                          ? 'images/Outfit.png'
                                          : expense['category'] ==
                                          'Services'
                                          ? 'images/Services.png'
                                          : expense['category'] ==
                                          'Grooming'
                                          ? 'images/Grooming.png'
                                          : 'images/Others.png',
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    expense['product'] ?? 'Unnamed Product',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                      DateFormat('d MMM, yyyy').format(
                                          expense['transaction_date'].toDate()),
                                      style: GoogleFonts.inter(fontSize: 12)),
                                  trailing: Text(
                                    formatter.format(expense['amount']),
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: expense['type'] == 'Debit'
                                            ? Colors.red
                                            : Color.fromRGBO(0, 125, 61, 1)),
                                  ),
                                  onTap: () {
                                    // Navigate to the TransactionDetailScreen and pass the expense data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionDetailScreen(
                                              expenseData: expense, // Pass data
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
