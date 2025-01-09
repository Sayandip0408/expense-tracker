import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/TransactionDetailsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryScreenTwo extends StatefulWidget {
  const HistoryScreenTwo({super.key});

  @override
  State<HistoryScreenTwo> createState() => _HistoryScreenTwoState();
}

enum FilterOption { all, lastMonth, lastYear, lastWeek, thisMonth, thisYear, last7Days }

class _HistoryScreenTwoState extends State<HistoryScreenTwo> {
  final user = FirebaseAuth.instance.currentUser; // Get logged in user
  FilterOption _selectedFilter = FilterOption.all; // Default filter is 'All'

  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Use Indian locale for proper formatting
    symbol: '₹', // Include the currency symbol if needed
    decimalDigits: 2, // Number of decimal digits
  );

  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    try {
      DateTime now = DateTime.now();
      Query query = FirebaseFirestore.instance
          .collection('expenses')
          .where('owner', isEqualTo: user!.email)
          .orderBy('transaction_date', descending: true);

      // Apply filter to query
      switch (_selectedFilter) {
        case FilterOption.lastMonth:
          DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
          DateTime lastDayOfLastMonth = DateTime(now.year, now.month, 0);
          query = query
              .where('transaction_date',
              isGreaterThanOrEqualTo: firstDayOfLastMonth)
              .where('transaction_date',
              isLessThanOrEqualTo: lastDayOfLastMonth);
          break;
        case FilterOption.lastYear:
          DateTime firstDayOfLastYear = DateTime(now.year - 1, 1, 1);
          DateTime lastDayOfLastYear = DateTime(now.year - 1, 12, 31);
          query = query
              .where('transaction_date',
              isGreaterThanOrEqualTo: firstDayOfLastYear)
              .where('transaction_date',
              isLessThanOrEqualTo: lastDayOfLastYear);
          break;
        case FilterOption.thisMonth:
          DateTime firstDayOfThisMonth = DateTime(now.year, now.month, 1);
          DateTime lastDayOfThisMonth = DateTime(now.year, now.month + 1, 0);
          query = query
              .where('transaction_date',
              isGreaterThanOrEqualTo: firstDayOfThisMonth)
              .where('transaction_date',
              isLessThanOrEqualTo: lastDayOfThisMonth);
          break;
        case FilterOption.thisYear:
          DateTime firstDayOfThisYear = DateTime(now.year, 1, 1);
          query = query.where('transaction_date',
              isGreaterThanOrEqualTo: firstDayOfThisYear);
          break;
        case FilterOption.lastWeek:
          DateTime lastWeekStart =
          now.subtract(Duration(days: now.weekday + 6));
          DateTime lastWeekEnd = now.subtract(Duration(days: now.weekday));
          query = query
              .where('transaction_date', isGreaterThanOrEqualTo: lastWeekStart)
              .where('transaction_date', isLessThanOrEqualTo: lastWeekEnd);
          break;
        case FilterOption.last7Days:
          DateTime last7DaysStart = now.subtract(const Duration(days: 7));
          query = query.where('transaction_date',
              isGreaterThanOrEqualTo: last7DaysStart);
          break;
        case FilterOption.all:
        // No additional filter for 'All'
          break;
      }

      final querySnapshot = await query.get();

      // Ensure the data is cast to the correct type
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching expenses: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          "TrackStack",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(24, 65, 44, 1)),
        ),
        actions: [
          // Add a dropdown for selecting the filter
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<FilterOption>(
              value: _selectedFilter,
              onChanged: (FilterOption? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: FilterOption.all,
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: FilterOption.lastMonth,
                  child: Text('Last Month'),
                ),
                DropdownMenuItem(
                  value: FilterOption.lastYear,
                  child: Text('Last Year'),
                ),
                DropdownMenuItem(
                  value: FilterOption.lastWeek,
                  child: Text('Last Week'),
                ),
                DropdownMenuItem(
                  value: FilterOption.thisMonth,
                  child: Text('This Month'),
                ),
                DropdownMenuItem(
                  value: FilterOption.thisYear,
                  child: Text('This Year'),
                ),
                DropdownMenuItem(
                  value: FilterOption.last7Days,
                  child: Text('Last 7 Days'),
                ),
              ],
            ),
          ),
        ],
      ),
      // Rest of the body remains the same
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          String filterText = '';
          switch (_selectedFilter) {
            case FilterOption.all:
              filterText = 'Displaying all your transactions';
              break;
            case FilterOption.lastMonth:
              filterText = 'Transactions from the previous month';
              break;
            case FilterOption.lastYear:
              filterText = 'Transactions from the previous year';
              break;
            case FilterOption.thisMonth:
              filterText = 'Your transactions for this month';
              break;
            case FilterOption.thisYear:
              filterText = 'All transactions in the current year';
              break;
            case FilterOption.lastWeek:
              filterText = 'Transactions from the past week';
              break;
            case FilterOption.last7Days:
              filterText = 'Transactions from the last 7 days';
              break;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    "Transactions",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(24, 65, 44, 1),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'images/transaction.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Display filter description
                  Text(
                    filterText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(24, 65, 44, 1),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              // Dynamic list of expenses
              ...expenses.map((expense) {
                return ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      expense['category'] == 'Fees'
                          ? 'images/Fees.png'
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
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('d MMM, yyyy')
                        .format(expense['transaction_date'].toDate()),
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  trailing: Text(
                    formatter.format(expense['amount']),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: expense['type'] == 'Debit'
                          ? Colors.red
                          : const Color.fromRGBO(0, 125, 61, 1),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(
                          expenseData: expense,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
