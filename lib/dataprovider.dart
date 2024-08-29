import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class DataProvider with ChangeNotifier {
  final List<DataSet> _dataSets = [];
  List<DataSet> get dataSets => _dataSets;

  final DataSet _currentData = DataSet();
  DataSet get currentData => _currentData;

  Timer? _timer;
  double currentTime = 0;
  bool isGenerating = false;
  WebSocketChannel? _channel;

  void startGeneratingData() {
    if (isGenerating) return;

    isGenerating = true;
    _connectToWebSocket();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _channel?.sink.add('Requesting data...');
      notifyListeners();
    });

    print('Started generating data');
  }

  void stopGeneratingData() {
    if (!isGenerating) return;

    isGenerating = false;
    _timer?.cancel();

    // Use 1000 for normal closure or choose an appropriate code in 3000-4999 range
    _channel?.sink.close(1000); // Changed from status.goingAway to 1000
    _channel = null;
    notifyListeners();

    print('Stopped generating data');
  }

  // void stopGeneratingData() {
  //   if (!isGenerating) return;

  //   isGenerating = false;
  //   _timer?.cancel();
  //   _channel?.sink.close(status.goingAway);
  //   _channel = null;
  //   notifyListeners();

  //   print('Stopped generating data');
  // }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.0.155:81'),
    );

    _channel?.stream.listen(
      (message) {
        if (isGenerating) {
          _updateSensorData(message);
        }
      },
      onDone: () {
        print('WebSocket connection closed');
        _channel = null;
      },
      onError: (error) {
        print('WebSocket error: $error');
        _channel = null;
      },
    );
  }

  void _storeAndResetData() {
    _dataSets.add(_currentData.clone());
    _currentData.clear();
    currentTime = 0;
    notifyListeners();
  }

  void _updateSensorData(String message) {
    // Split the incoming message by newline to handle each line individually
    List<String> lines = message.split('\n');

    // Initialize variables to store parsed values
    double? ax,
        ay,
        az,
        rx,
        ry,
        rz,
        stdDevX,
        stdDevY,
        stdDevZ,
        avgStdDevX,
        avgStdDevY,
        avgStdDevZ,
        alt;
    bool fallDetected = false;
    String fluctuationState = '';

    // Iterate over each line to parse values
    for (String line in lines) {
      line = line.trim(); // Remove any leading/trailing whitespace
      // print("Processing line: $line"); // Debugging print

      // Parse CSV line based on its prefix
      if (line.startsWith('ACC,')) {
        // Split the line by commas
        List<String> values = line.split(',');

        // Ensure there are enough values in the line to parse
        if (values.length >= 10) {
          ax = double.tryParse(values[1]);
          ay = double.tryParse(values[2]);
          az = double.tryParse(values[3]);
          rx = double.tryParse(values[4]);
          ry = double.tryParse(values[5]);
          rz = double.tryParse(values[6]);
          stdDevX = double.tryParse(values[7]);
          stdDevY = double.tryParse(values[8]);
          stdDevZ = double.tryParse(values[9]);

          // If there are more values for averages
          if (values.length >= 13) {
            avgStdDevX = double.tryParse(values[10]);
            avgStdDevY = double.tryParse(values[11]);
            avgStdDevZ = double.tryParse(values[12]);
          }
        }
        // print(
        //     "Parsed ACC data: ax=$ax, ay=$ay, az=$az, rx=$rx, ry=$ry, rz=$rz, stdDevX=$stdDevX, stdDevY=$stdDevY, stdDevZ=$stdDevZ, avgStdDevX=$avgStdDevX, avgStdDevY=$avgStdDevY, avgStdDevZ=$avgStdDevZ"); // Debugging print
      } else if (line.startsWith('ALT,')) {
        List<String> values = line.split(',');

        // Ensure there is at least one value for altitude
        if (values.length >= 2) {
          alt = double.tryParse(values[1]);
        }
        // print("Parsed ALT data: alt=$alt"); // Debugging print
      } else if (line.startsWith('STATE,')) {
        List<String> values = line.split(',');

        // Ensure there is at least one value for state
        if (values.length >= 2) {
          fluctuationState = values[1].trim();
        }
        // print(
        //     "Parsed STATE data: fluctuationState=$fluctuationState"); // Debugging print
      }
    }

    // Add data points if values are not null
    _addDataPoint(
      ax: ax,
      ay: ay,
      az: az,
      rx: rx,
      ry: ry,
      rz: rz,
      stdDevX: stdDevX,
      stdDevY: stdDevY,
      stdDevZ: stdDevZ,
      avgStdDevX: avgStdDevX,
      avgStdDevY: avgStdDevY,
      avgStdDevZ: avgStdDevZ,
      alt: alt,
    );

    // Optionally, handle fall detection and fluctuation state
    if (fallDetected) {
      // print("Fall detected!");
    }
    if (fluctuationState.isNotEmpty) {
      // print("Fluctuation State: $fluctuationState");
    }
  }

  void _addDataPoint({
    double? ax,
    double? ay,
    double? az,
    double? rx,
    double? ry,
    double? rz,
    double? alt,
    double? stdDevX,
    double? stdDevY,
    double? stdDevZ,
    double? avgStdDevX,
    double? avgStdDevY,
    double? avgStdDevZ,
  }) {
    if (ax != null) _currentData.ax.add(FlSpot(currentTime, ax));
    if (ay != null) _currentData.ay.add(FlSpot(currentTime, ay));
    if (az != null) _currentData.az.add(FlSpot(currentTime, az));
    if (rx != null) _currentData.rx.add(FlSpot(currentTime, rx));
    if (ry != null) _currentData.ry.add(FlSpot(currentTime, ry));
    if (rz != null) _currentData.rz.add(FlSpot(currentTime, rz));
    if (alt != null) {
      _currentData.alt.add(FlSpot(currentTime, alt - 247));
    }

    // New additions for std dev and avg std dev
    if (stdDevX != null) {
      _currentData.stdDevX.add(FlSpot(currentTime, stdDevX));
      // print("STDDEVX*******: ${stdDevX}");
    }
    if (stdDevY != null) _currentData.stdDevY.add(FlSpot(currentTime, stdDevY));
    if (stdDevZ != null) _currentData.stdDevZ.add(FlSpot(currentTime, stdDevZ));
    if (avgStdDevX != null) {
      _currentData.avgStdDevX.add(FlSpot(currentTime, avgStdDevX));
    }
    if (avgStdDevY != null) {
      _currentData.avgStdDevY.add(FlSpot(currentTime, avgStdDevY));
    }
    if (avgStdDevZ != null) {
      _currentData.avgStdDevZ.add(FlSpot(currentTime, avgStdDevZ));
    }

    currentTime++;

    // Check if the current data set has reached 60 points
    if (_currentData.ax.length >= 60) {
      _storeAndResetData();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _channel?.sink.close(status.goingAway);
    super.dispose();
  }
}

class DataSet {
  final List<FlSpot> ax = [];
  final List<FlSpot> ay = [];
  final List<FlSpot> az = [];
  final List<FlSpot> rx = [];
  final List<FlSpot> ry = [];
  final List<FlSpot> rz = [];
  final List<FlSpot> alt = [];

  // New lists for standard deviation and average standard deviation
  final List<FlSpot> stdDevX = [];
  final List<FlSpot> stdDevY = [];
  final List<FlSpot> stdDevZ = [];
  final List<FlSpot> avgStdDevX = [];
  final List<FlSpot> avgStdDevY = [];
  final List<FlSpot> avgStdDevZ = [];

  void clear() {
    ax.clear();
    ay.clear();
    az.clear();
    rx.clear();
    ry.clear();
    rz.clear();
    alt.clear();
    stdDevX.clear();
    stdDevY.clear();
    stdDevZ.clear();
    avgStdDevX.clear();
    avgStdDevY.clear();
    avgStdDevZ.clear();
  }

  DataSet clone() {
    return DataSet()
      ..ax.addAll(ax)
      ..ay.addAll(ay)
      ..az.addAll(az)
      ..rx.addAll(rx)
      ..ry.addAll(ry)
      ..rz.addAll(rz)
      ..alt.addAll(alt)
      ..stdDevX.addAll(stdDevX)
      ..stdDevY.addAll(stdDevY)
      ..stdDevZ.addAll(stdDevZ)
      ..avgStdDevX.addAll(avgStdDevX)
      ..avgStdDevY.addAll(avgStdDevY)
      ..avgStdDevZ.addAll(avgStdDevZ);
  }
}
