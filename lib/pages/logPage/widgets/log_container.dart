// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:sqlite3/sqlite3.dart' as sqlite;

// import '../../../models/PrimaryContainer.dart';
// import '../models/log.dart';

// class LogContainer extends StatelessWidget {
//   final sqlite.ResultSet dates;
//   final Log log;

//   const LogContainer({super.key, required this.dates, required this.log});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: dates.length,
//       itemBuilder: (BuildContext context, int index) {
//         sqlite.ResultSet rows =
//             log.getLogsPerDate(dates[index]["DateOnly"].toString());
//         var logPerDay = [];
//         for (sqlite.Row row in rows) {
//           var widget = PrimaryContainer(
//               paddingHorizontal: 20,
//               padding: 10,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [Text("${row['Name']}"), Text("${row['Count']}")],
//                 ),
//               ));
//           logPerDay.add(widget);
//         }

//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [Text("${dates[index]["DateOnly"]} "), ...logPerDay],
//           ),
//         );
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for easy date formatting
import 'package:sqlite3/sqlite3.dart' as sqlite;
import '../../../models/PrimaryContainer.dart';
import '../models/log.dart';

class LogContainer extends StatefulWidget {
  final Log log;
  const LogContainer({super.key, required this.log});

  @override
  State<LogContainer> createState() => _LogContainerState();
}

class _LogContainerState extends State<LogContainer> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int increment) {
    var firstDate = DateTime.parse(widget.log.getFirstLogDate());
    bool IsBeforeFirstDate =  DateTime(_selectedMonth.year, _selectedMonth.month + increment).isBefore(DateTime(firstDate.year,firstDate.month));
    bool IsAfterNow =  DateTime(_selectedMonth.year, _selectedMonth.month + increment).isAfter(DateTime.now());
    if(IsBeforeFirstDate || IsAfterNow){
      print(DateTime.parse(widget.log.getFirstLogDate()));
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Prepare the month string for SQL (YYYY-MM)
    String monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    
    // 2. Fetch all logs for this month
    // Note: In a production app, you might use a FutureBuilder here
    sqlite.ResultSet monthlyData = widget.log.getLogsByMonth(monthKey);

    // 3. Group data by day manually for the UI
    Map<String, List<sqlite.Row>> groupedData = {};
    for (var row in monthlyData) {
      String date = row['DateOnly'].toString();
      groupedData.putIfAbsent(date, () => []).add(row);
    }
    
    var sortedDates = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // Monthly Navigation Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
            ],
          ),
        ),
        
        // The List
        Expanded(
          child: sortedDates.isEmpty 
            ? const Center(child: Text("No logs for this month"))
            : ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  String date = sortedDates[index];
                  List<sqlite.Row> dayLogs = groupedData[date]!;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 4),
                          child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...dayLogs.map((row) => PrimaryContainer(
                          paddingHorizontal: 20,
                          padding: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${row['Name']}"), 
                              Text("${row['Count'] ?? ''}")
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}