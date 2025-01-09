import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

enum FilterOption {
  all,
  lastMonth,
  lastYear,
  lastWeek,
  thisMonth,
  thisYear,
  last7Days
}

class _ReportScreenState extends State<ReportScreen> {
  final user = FirebaseAuth.instance.currentUser;
  FilterOption _selectedFilter = FilterOption.all;

  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  int _getDayIndex(String day) {
    switch (day) {
      case 'Mon':
        return 1;
      case 'Tue':
        return 2;
      case 'Wed':
        return 3;
      case 'Thu':
        return 4;
      case 'Fri':
        return 5;
      case 'Sat':
        return 6;
      case 'Sun':
        return 0;
      default:
        return 0;
    }
  }

  String _getDayName(int index) {
    List<String> dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return dayLabels[index % 7]; // Safely handles day index
  }

  int daysRange = 7; // Default range
  Map<String, Map<String, double>> dayWiseTotals = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryWiseTotals();
    _fetchDailyTotals();
  }

  Future<Map<String, Map<String, double>>> _fetchCategoryWiseTotals() async {
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

      // Initialize totals for categories
      Map<String, double> debitTotals = {};
      Map<String, double> creditTotals = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String;
        final amount = data['amount'] as double;
        final type = data['type'] as String;

        if (type == 'Debit') {
          debitTotals[category] = (debitTotals[category] ?? 0) + amount;
        } else if (type == 'Credit') {
          creditTotals[category] = (creditTotals[category] ?? 0) + amount;
        }
      }

      return {'debit': debitTotals, 'credit': creditTotals};
    } catch (e) {
      print("Error fetching category-wise totals: $e");
      return {'debit': {}, 'credit': {}};
    }
  }

  // Function to fetch total debit and credit for the last 7 days
  Future<Map<String, Map<String, double>>> _fetchDailyTotals() async {
    try {
      DateTime now = DateTime.now();
      DateTime last7DaysStart = now.subtract(const Duration(days: 7));
      Query query = FirebaseFirestore.instance
          .collection('expenses')
          .where('owner', isEqualTo: user?.email)
          .where('transaction_date', isGreaterThanOrEqualTo: last7DaysStart)
          .orderBy('transaction_date', descending: true);

      final querySnapshot = await query.get();

      // Initialize totals for categories per day
      Map<String, double> debitTotals = {};
      Map<String, double> creditTotals = {};
      List<String> dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

      // Initialize the map for each day (Sunday to Saturday)
      for (var day in dayLabels) {
        debitTotals[day] = 0.0;
        creditTotals[day] = 0.0;
      }

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final transactionDate = (data['transaction_date'] as Timestamp).toDate();
        final type = data['type'] as String;
        final amount = data['amount'] as double;

        // Calculate the day of the week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
        String dayName = DateFormat('E').format(transactionDate);

        if (type == 'Debit') {
          debitTotals[dayName] = (debitTotals[dayName] ?? 0) + amount;
        } else if (type == 'Credit') {
          creditTotals[dayName] = (creditTotals[dayName] ?? 0) + amount;
        }
      }
      print({'debit': debitTotals, 'credit': creditTotals});

      return {'debit': debitTotals, 'credit': creditTotals};
    } catch (e) {
      print("Error fetching daily totals: $e");
      return {'debit': {}, 'credit': {}};
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Debit and Credit
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // Color of the AppBar background
          scrolledUnderElevation: 0,
          title: Text(
            "TrackStack Analytics",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(24, 65, 44, 1)),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color.fromRGBO(24, 65, 44,
                  1), // Change this to change the color of the bottom area
              child: TabBar(
                indicatorColor: Colors.green, // Color of the tab indicator
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(text: "Debits"),
                  Tab(text: "Credits"),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Container(
                width: double.infinity, // Set the width
                height: 40, // Set the height
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
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
                        child: Text(
                          'All',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOption.lastMonth,
                        child: Text(
                          'Last Month',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOption.lastYear,
                        child: Text(
                          'Last Year',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOption.lastWeek,
                        child: Text(
                          'Last Week',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOption.thisMonth,
                        child: Text(
                          'This Month',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOption.thisYear,
                        child: Text(
                          'This Year',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: FilterOption.last7Days,
                        child: Text(
                          'Last 7 Days',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, Map<String, double>>>(
                future: _fetchCategoryWiseTotals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final totals = snapshot.data ?? {'debit': {}, 'credit': {}};
                  final debitTotals = totals['debit']!;
                  final creditTotals = totals['credit']!;

                  // Calculate sum for debit and credit
                  final debitSum = debitTotals.values
                      .fold(0.0, (sum, amount) => sum + amount);
                  final creditSum = creditTotals.values
                      .fold(0.0, (sum, amount) => sum + amount);

                  return TabBarView(
                    children: [
                      // Debit tab
                      ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          ...debitTotals.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87
                                    ),
                                  ),
                                  Text(
                                    formatter.format(entry.value),
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const SizedBox(
                              height: 20), // Space between list and total

                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors
                                  .red.shade50, // Light green background
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Debit',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red
                                  ),
                                ),
                                Text(
                                  formatter.format(debitSum),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Credit tab
                      ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          ...creditTotals.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    formatter.format(entry.value),
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(
                              height: 20), // Space between list and total

                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color:
                              Colors.green.shade50, // Light blue background
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Credit',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(24, 65, 44, 1),
                                  ),
                                ),
                                Text(
                                  formatter.format(creditSum),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromRGBO(24, 65, 44, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, Map<String, double>>>(
                future: _fetchDailyTotals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final totals = snapshot.data ?? {'debit': {}, 'credit': {}};
                  final debitTotals = totals['debit']!;
                  final creditTotals = totals['credit']!;

                  // Convert to List for BarChart
                  List<BarChartGroupData> barData = [];

                  // Merge both debit and credit bars into a single BarChartGroupData for each day
                  for (var day in debitTotals.keys) {
                    barData.add(BarChartGroupData(
                      x: _getDayIndex(day),
                      barRods: [
                        BarChartRodData(
                          fromY: 0,  // Starting point
                          toY: debitTotals[day]!,  // Debit value
                          color: Colors.red,
                          width: 16,
                        ),
                        BarChartRodData(
                          fromY: 0,  // Starting point
                          toY: creditTotals[day]!,  // Credit value
                          color: Colors.green,
                          width: 16,
                        ),
                      ],
                    ));
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            barGroups: barData,
                            titlesData: FlTitlesData(
                              // Configure the left titles (Y-axis)
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,  // Show titles on the left
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(0),  // Display Y-axis value
                                      style: TextStyle(fontSize: 10, color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                              // Configure the bottom titles (X-axis)
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,  // Show titles on the bottom
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      _getDayName(value.toInt()),  // Display day name
                                      style: TextStyle(fontSize: 10, color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                              // Hide top and right titles
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true, drawVerticalLine: true),
                            alignment: BarChartAlignment.spaceAround,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
