import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ga_local_web_app/dataset_class.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
// import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // To get file paths
import 'package:csv/csv.dart';

class DataProvider with ChangeNotifier {
  final List<DataSet> _dataSets = [];
  List<DataSet> get dataSets => _dataSets;

  final DataSet _currentData = DataSet();
  DataSet get currentData => _currentData;

  Timer? _timer;
  double currentTime = 0;
  bool isGenerating = false;
  WebSocketChannel? _channel;

  // int slowstepcounter = 0;

  // // Callback to notify when new data is received
  // void Function(double, double, double, double, double, double)? onNewData;

  // Track the previous two values of ay, az, and position
  double? _prevAy1;
  double? _prevAy2;
  double? _prevAz1;
  double? _prevAz2;
  String? _prevPosition1;
  String? _prevPosition2;

  void startGeneratingData() {
    if (isGenerating) return;

    isGenerating = true;
    _connectToWebSocket();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _channel?.sink.add('Requesting data...');
      notifyListeners();
    });

    print('Started generating data');
  }

  void stopGeneratingData() {
    if (!isGenerating) return;

    isGenerating = false;
    _timer?.cancel();

    _channel?.sink.close(1000); // Changed from status.goingAway to 1000
    _channel = null;
    notifyListeners();

    print('Stopped generating data');
  }

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
    try {
      // print('Raw message received: $message');
      final Map<String, dynamic> data = jsonDecode(message);
      // Safely extract data from the JSON object with null checks
      int stepCounter = data['stepCount']?.toInt();
      String activity = data['activity'] ?? '';
      bool fallDetected = false;
      String fallstate = 'None';
      final double? ax = data['accelX']?.toDouble();
      final double? ay = data['accelY']?.toDouble();
      final double? az = data['accelZ']?.toDouble();
      final double? rx = data['rotationX']?.toDouble();
      final double? ry = data['rotationY']?.toDouble();
      final double? rz = data['rotationZ']?.toDouble();
      final String fluctuationState =
          data['isFluctuating'] == 1 ? 'Fluctuation Detected' : 'Stable';

      if (ax == null || ay == null || az == null) {
        print('Missing or invalid sensor data: ax, ay, or az is null.');
        return;
      }

      String position = '';
      if (ay > 0.5 && ay > ax && ay > az) {
        position = "Straight";
      } else {
        position = "Laying";
      }

      // Calculate if a fall is detected based on ay and az comparison with previous two values
      if ((_prevPosition1 == "Straight" || _prevPosition2 == "Straight") &&
          _prevAy1 != null &&
          _prevAy2 != null &&
          _prevAz1 != null &&
          _prevAz2 != null) {
        // Calculate the differences for ay
        double ayDiff1 = (_prevAy1! - ay).abs(); // Current and previous
        double ayDiff2 = (_prevAy2! - ay).abs(); // Current and previous-2

        // Calculate the differences for az
        double azDiff1 = (_prevAz1! - az).abs(); // Current and previous
        double azDiff2 = (_prevAz2! - az).abs(); // Current and previous-2

        if (ayDiff1 > 0.8 || ayDiff2 > 0.8 || azDiff1 > 0.8 || azDiff2 > 0.8) {
          fallDetected = true;
        }
      }

      _prevAy2 = _prevAy1;
      _prevAy1 = ay;
      _prevAz2 = _prevAz1;
      _prevAz1 = az;
      _prevPosition2 = _prevPosition1;
      _prevPosition1 = position;

      // if (fallDetected && position == "Laying") {
      //   print("Fall detected!***************");
      //   fallstate = 'Fall detected!';
      // }
      // if (fallDetected &&
      //     position != "Laying" &&
      //     _prevPosition1 != "Standing still") {
      //   print("Fall predicted!!!!!!!!!!!!!!!");
      //   fallstate = 'Fall predicted!';
      // }

      // }

      _addDataPoint(
        ax: ax,
        ay: ay,
        az: az,
        rx: rx,
        ry: ry,
        rz: rz,
        fallDetected: fallDetected,
        fallstate: fallstate,
        fluctuationState: fluctuationState,
        activity: activity,
        stepCount: stepCounter,
        position: position,
      );
    } catch (e) {
      print('Error parsing sensor data: $e');
    }
  }

  void _addDataPoint({
    double? ax,
    double? ay,
    double? az,
    double? rx,
    double? ry,
    double? rz,
    bool? fallDetected = false,
    String? fallstate,
    String? activity,
    int? stepCount,
    String? fluctuationState,
    String? position,
  }) {
    if (ax != null) _currentData.ax.add(FlSpot(currentTime, ax));
    if (ay != null) _currentData.ay.add(FlSpot(currentTime, ay));
    if (az != null) _currentData.az.add(FlSpot(currentTime, az));
    if (rx != null) _currentData.rx.add(FlSpot(currentTime, rx / 100));
    if (ry != null) _currentData.ry.add(FlSpot(currentTime, ry / 100));
    if (rz != null) _currentData.rz.add(FlSpot(currentTime, rz / 100));

    _currentData.falldetected = fallDetected ?? false;
    _currentData.fallstate = fallstate ?? 'None';
    _currentData.activity = activity ?? '';
    _currentData.stepCount = stepCount ?? 0;
    _currentData.fluctuationState = fluctuationState ?? '';
    _currentData.position = position ?? '';

    print("$currentTime,$ax,$ay,$az,$rx,$ry,$rz,$activity,$fallDetected");

    currentTime++;

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
