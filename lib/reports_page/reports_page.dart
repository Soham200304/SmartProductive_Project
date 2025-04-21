import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smartproductive_app/drawer_page/drawer.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<DateTime, int> _focusMinutesPerDay = {};
  List<Map<String, dynamic>> _taskLogs = [];
  DateTime _selectedStartDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _selectedEndDate = DateTime.now();
  String _selectedFilter = 'Month'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  ///Function to filter tasks based on selected time range
  List<Map<String, dynamic>> _getFilteredLogs() {
    DateTime now = DateTime.now();
    DateTime startFilterDate;

    if (_selectedFilter == "Day") {
      startFilterDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedFilter == "Week") {
      startFilterDate = now.subtract(Duration(days: 7));
    } else if (_selectedFilter == "Month") {
      startFilterDate = DateTime(now.year, now.month, 1);
    } else {
      startFilterDate = DateTime(now.year, 1, 1);
    }

    return _taskLogs
        .where((task) => task['date'].isAfter(startFilterDate))
        .toList();
  }

  Map<DateTime, int> _getFilteredFocusMinutes() {
    DateTime now = DateTime.now();
    DateTime startFilterDate;

    if (_selectedFilter == "Day") {
      startFilterDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedFilter == "Week") {
      startFilterDate = now.subtract(Duration(days: 7));
    } else if (_selectedFilter == "Month") {
      startFilterDate = DateTime(now.year, now.month, 1);
    } else {
      startFilterDate = DateTime(now.year, 1, 1);
    }

    return _focusMinutesPerDay.entries
        .where((entry) => entry.key.isAfter(startFilterDate))
        .fold<Map<DateTime, int>>({}, (map, entry) {
      map[entry.key] = entry.value;
      return map;
    });
  }

  Future<void> _fetchReportData() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("User is not logged in.");
        return;
      }

      print("Fetching data for user: $uid");

      QuerySnapshot timerSnapshot = await FirebaseFirestore.instance
          .collection('timerCompletions')
          .where("userId", isEqualTo: uid)
          .get();

      print("Retrieved ${timerSnapshot.docs.length} documents from Firestore.");

      if (timerSnapshot.docs.isEmpty) {
        print("No data found for this user.");
      }

      Map<DateTime, int> focusData = {};
      List<Map<String, dynamic>> taskLogs = [];

      for (var doc in timerSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print("Document data: $data");

        if (data['completedAt'] != null && data['taskName'] != null && data['timer'] != null) {
          DateTime date = (data['completedAt'] as Timestamp).toDate();
          DateTime normalizedDate = DateTime(date.year, date.month, date.day);

          focusData[normalizedDate] = (focusData[normalizedDate] ?? 0) + (data['timer'] as num).toInt();

          taskLogs.add({
            'taskName': data['taskName'],
            'date': date,
            'minutesFocused': (data['timer'] as num).toInt(),
          });
        } else {
          print("Skipping document due to missing fields.");
        }
      }

      setState(() {
        _focusMinutesPerDay = focusData;
        _taskLogs = taskLogs;
      });

      print("Data successfully fetched and processed.");

    } catch (e) {
      print("Error fetching reports: $e");
    }
  }



  /// Date Picker for filtering reports
  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _selectedStartDate, end: _selectedEndDate),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
    }
  }

  double _calculateAverageFocusMinutes(Map<DateTime, int> data) {
    if (data.isEmpty) return 0;
    int total = data.values.reduce((a, b) => a + b);
    return total / data.length;
  }

  void saveTimerCompletion(String taskName, int minutes) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("No user logged in.");
      return;
    }

    await FirebaseFirestore.instance.collection("timerCompletions").add({
      "userId": uid, // ✅ Make sure this is saved
      "taskName": taskName,
      "timer": minutes,
      "completedAt": FieldValue.serverTimestamp(),
    });

    print("Timer completion saved.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4FC3F7),
        title: Text("Reports", style: GoogleFonts.alike(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFF9F2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSummaryCard(),
                SizedBox(height: 20),
                _buildBarChart(),
                SizedBox(height: 20),
                _buildTaskTimeline(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📊 Bar Chart for Daily Productivity
  Widget _buildBarChart() {
    final filteredData = _getFilteredFocusMinutes();

    return Card(
      color: Color(0xFFD5F0FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Daily Focus Minutes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 250,
              child: filteredData.isEmpty
                  ? Center(child: Text("No data for selected period"))
                  : BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        DateTime date = filteredData.keys.elementAt(group.x);
                        return BarTooltipItem(
                          "${date.day}/${date.month}\n${rod.toY.toInt()} min",
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()} min',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          DateTime date = filteredData.keys.elementAt(value.toInt());
                          return Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text("${date.day}/${date.month}",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    border: Border.all(color: Colors.transparent),
                  ),
                  barGroups: filteredData.entries.map((entry) {
                    return BarChartGroupData(
                      x: filteredData.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.purpleAccent],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 Task Timeline Log
  Widget _buildTaskTimeline() {
    List<Map<String, dynamic>> filteredLogs = _getFilteredLogs();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      color: Color(0xFFD0EFFD),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔽 Dropdown Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Productivity Timeline",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: ["Day", "Week", "Month", "Year"]
                      .map((filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            /// 🔹 Timeline List
            filteredLogs.isEmpty
                ? Text("No tasks available for selected period",
                style: TextStyle(color: Colors.grey))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                var task = filteredLogs[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  color: Color(0xFFFFD54F),//Warm golden sand
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Icon(Icons.task_alt, color: Colors.green),
                    title: Text(task['taskName'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${DateFormat('dd MMM yyyy, hh:mm a').format(task['date'])} - ${task['minutesFocused']} min",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Summary Card for Total Productivity (Filtered)
  Widget _buildSummaryCard() {
    List<Map<String, dynamic>> filteredLogs = _getFilteredLogs();

    // Ensure 'minutesFocused' is not null and safely cast to int
    int totalMinutes = filteredLogs.fold(0, (sum, task) {
      return sum + ((task['minutesFocused'] ?? 0) as int);
    });
    return Card(
      color: Color(0xFFFFA726),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Total Focus Time",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "$totalMinutes min",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
