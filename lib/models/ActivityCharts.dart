import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'log.dart'; 
import "package:localization_lite/translate.dart";

class ActivityChart extends StatefulWidget {
  final Log logProvider;
  final int itemId;

  const ActivityChart({super.key, required this.logProvider, required this.itemId});

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  bool isMonthly = true; // Toggle between Month and Year
  DateTime now = DateTime.now();
  Color primaryColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        _buildToggle(),
        SizedBox(
          height: 200,
          child: isMonthly ? _buildMonthlyChart() : _buildYearlyChart(),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    var now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => setState(() => isMonthly = true),
          child: Text(tr(DateFormat("MMMM").format(now)), style: TextStyle(color: isMonthly ? primaryColor : Colors.grey)),
        ),
        TextButton(
          onPressed: () => setState(() => isMonthly = false),
          child: Text(now.year.toString(), style: TextStyle(color: !isMonthly ? primaryColor : Colors.grey)),
        ),
      ],
    );
  }

  // --- Chart Data Processing ---

  Widget _buildMonthlyChart() {
    String monthKey = DateFormat('yyyy-MM').format(now);
    sqlite.ResultSet rows = widget.logProvider.getLogByMonth(monthKey, widget.itemId);

    if (rows.isEmpty) return _buildEmptyState();

    Map<int, double> dayData = {};
    for (var row in rows) {
      // Assuming row['DateOnly'] format: YYYY-MM-DD
      int day = DateTime.parse(row['DateOnly']).day;
      dayData[day] = (dayData[day] ?? 0) + (row['TotalCount'] ?? 1).toDouble();
    }

    List<double> values = dayData.values.toList();
    double maxVal = values.isNotEmpty ? values.reduce((curr, next) => curr > next ? curr : next) : 0;
    double avgVal = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal + 1, // Give some headroom
        gridData: const FlGridData(show: false),
        titlesData: _buildTitles(isMonth: true),
        borderData: FlBorderData(show: false),
        
        // SOLUTION 1: Fix the Black Border
        barTouchData: BarTouchData(
          enabled: false, // Keep tooltips enabled
        ),

        // SOLUTION 2: Average and Max Lines
        extraLinesData: ExtraLinesData(
          horizontalLines: _buildStatLines(maxVal, avgVal),
        ),

        barGroups: List.generate(31, (i) {
          int dayIndex = i + 1;
          return BarChartGroupData(
            x: dayIndex, 
            barRods: [
              BarChartRodData(
                toY: dayData[dayIndex] ?? 0, 
                color: primaryColor, 
                width: 4,
                // borderRadius: BorderRadius.zero, // Make them sharp cols
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildYearlyChart() {
    String yearKey = DateFormat('yyyy').format(now);
    sqlite.ResultSet rows = widget.logProvider.getLogByYear(yearKey, widget.itemId);

    if (rows.isEmpty) return _buildEmptyState();

    Map<int, double> monthData = {};
    for (var row in rows) {
      // Assuming row['Month'] format: MM (01-12)
      int month = int.parse(row['Month']);
      monthData[month] = (monthData[month] ?? 0) + (row['TotalCount'] ?? 1).toDouble();
    }

    List<double> values = monthData.values.toList();
    double maxVal = values.isNotEmpty ? values.reduce((curr, next) => curr > next ? curr : next) : 0;
    double avgVal = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal + (maxVal * 0.1), // Give some headroom
        gridData: const FlGridData(show: false),
        titlesData: _buildTitles(isMonth: false),
        borderData: FlBorderData(show: false),
        
        // SOLUTION 1: Fix the Black Border
        barTouchData: BarTouchData(
          enabled: false,
          
        ),

        // SOLUTION 2: Average and Max Lines
        extraLinesData: ExtraLinesData(
          horizontalLines: _buildStatLines(maxVal, avgVal),
        ),

        barGroups: List.generate(12, (i) {
          int monthIndex = i + 1;
          return BarChartGroupData(x: monthIndex, barRods: [
            BarChartRodData(
              toY: monthData[monthIndex] ?? 0, 
              color: primaryColor, 
              width: 14,
            //   borderRadius: BorderRadius.zero, // Make them sharp cols
            )
          ]);
        }),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildEmptyState() {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.grey, size: 40),
          const SizedBox(height: 10,),
          Text(tr("noLogsForThisPeriod"), style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  List<HorizontalLine> _buildStatLines(double maxVal, double avgVal) {
    if (maxVal == 0) return []; // No lines if no data

    return [
      // Max Line
      HorizontalLine(
        y: maxVal,
        color: Colors.grey.withOpacity(0.6),
        strokeWidth: 1,
        dashArray: [5, 5], // Dotted line
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 5, bottom: 2),
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
          labelResolver: (line) => '${maxVal.toInt()}',
        ),
      ),
      // Average Line
      HorizontalLine(
        y: avgVal,
        color: Colors.grey.withOpacity(0.6),
        strokeWidth: 1,
        dashArray: [10, 2], // Long dash dotted line
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 5, bottom: 2),
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
          labelResolver: (line) => '${avgVal.toStringAsFixed(1)}',
        ),
      ),
    ];
  }

  FlTitlesData _buildTitles({required bool isMonth}) {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTitlesWidget: (value, meta) {
            if (isMonth) {
              // Show only every 5th day to save space
              return value % 5 == 0 ? Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ) : const SizedBox();
            }
            // Show Month abbreviation
            const months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
            return Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(months[value.toInt() - 1], style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }
}