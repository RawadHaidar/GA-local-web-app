import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ga_local_web_app/dataprovider.dart';

class LineChartSample extends StatefulWidget {
  final DataSet dataSet;

  LineChartSample(this.dataSet);

  @override
  _LineChartSampleState createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  final List<String> _selectedDataTypes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Line Chart'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (_selectedDataTypes.contains(value)) {
                  _selectedDataTypes.remove(value);
                } else {
                  _selectedDataTypes.add(value);
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return <String>[
                'AX',
                'AY',
                'AZ',
                'RX',
                'RY',
                'RZ',
                'StdDevX',
                'StdDevY',
                'StdDevZ',
                'avgStdDevX',
                'avgStdDevY',
                'avgStdDevZ',
                'ALT'
              ].map<PopupMenuItem<String>>((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedDataTypes.contains(value),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedDataTypes.add(value);
                            } else {
                              _selectedDataTypes.remove(value);
                            }
                          });
                        },
                      ),
                      Text(value),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LineChart(
          LineChartData(
            lineBarsData: _getLineBars(),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 30),
              ),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: 180,
            minY: -20,
            maxY: 20,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final barData = touchedSpot.bar as LineChartBarData;
                    final yValue = touchedSpot.y.toStringAsFixed(5);
                    final textStyle = TextStyle(
                      color: touchedSpot.bar.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    return LineTooltipItem(
                      yValue,
                      textStyle,
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _getLineBars() {
    List<LineChartBarData> lineBars = [];

    if (_selectedDataTypes.contains('AX')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.ax,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('AY')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.ay,
          isCurved: true,
          color: Colors.red,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('AZ')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.az,
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('RX')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.rx,
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('RY')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.ry,
          isCurved: true,
          color: Colors.purple,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('RZ')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.rz,
          isCurved: true,
          color: Colors.yellow,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('StdDevX')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.stdDevX,
          isCurved: true,
          color: Colors.blue[400],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('StdDevY')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.stdDevY,
          isCurved: true,
          color: Colors.red[400],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('StdDevZ')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.stdDevZ,
          isCurved: true,
          color: Colors.green[400],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('avgStdDevX')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.avgStdDevX,
          isCurved: true,
          color: Colors.blue[800],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('avgStdDevY')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.avgStdDevY,
          isCurved: true,
          color: Colors.red[800],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('avgStdDevZ')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.avgStdDevZ,
          isCurved: true,
          color: Colors.green[800],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (_selectedDataTypes.contains('ALT')) {
      lineBars.add(
        LineChartBarData(
          spots: widget.dataSet.alt,
          isCurved: true,
          color: Colors.grey,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return lineBars;
  }
}
