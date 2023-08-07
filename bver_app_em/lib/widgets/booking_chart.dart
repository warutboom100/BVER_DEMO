import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BookingLineChart extends StatelessWidget {
  final List<double> bookingData = [
    200,
    400,
    100,
    500,
    300,
    450,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Booking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 0:
                            return '00:00';
                          case 1:
                            return '04:00';
                          case 2:
                            return '08:00';
                          case 3:
                            return '12:00';
                          case 4:
                            return '16:00';
                          case 5:
                            return '20:00';
                          default:
                            return '';
                        }
                      },
                      margin: 10,
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      getTitles: (value) {
                        if (value % 200 == 0) {
                          return value.toInt().toString();
                        }
                        return '';
                      },
                      interval: 200,
                      reservedSize: 40,
                      margin: 10,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 600,
                  lineBarsData: [
                    LineChartBarData(
                      spots: getSpots(),
                      isCurved: true,
                      colors: [
                        Colors.orange,
                      ],
                      barWidth: 5,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.orange.withOpacity(0.3)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> getSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < bookingData.length; i++) {
      spots.add(FlSpot(i.toDouble(), bookingData[i]));
    }
    return spots;
  }
}
