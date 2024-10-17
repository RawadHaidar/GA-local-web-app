import "package:fl_chart/fl_chart.dart";

class DataSet {
  // Lists to hold data points for various metrics
  final List<FlSpot> ax;
  final List<FlSpot> ay;
  final List<FlSpot> az;
  final List<FlSpot> rx;
  final List<FlSpot> ry;
  final List<FlSpot> rz;

  // final List<FlSpot> stdDevX;
  // final List<FlSpot> stdDevY;
  // final List<FlSpot> stdDevZ;
  // final List<FlSpot> avgStdDevX;
  // final List<FlSpot> avgStdDevY;
  // final List<FlSpot> avgStdDevZ;

  // final List<FlSpot> wavelength; // New wavelength data

  // Variables to store activity, step count, and fluctuation state
  String activity;
  int stepCount;
  String fluctuationState;
  String position;
  bool falldetected;
  String fallstate;

  // Constructor to initialize DataSet
  DataSet(
      {List<FlSpot>? ax,
      List<FlSpot>? ay,
      List<FlSpot>? az,
      List<FlSpot>? rx,
      List<FlSpot>? ry,
      List<FlSpot>? rz,
      List<FlSpot>? stdDevX,
      List<FlSpot>? stdDevY,
      List<FlSpot>? stdDevZ,
      List<FlSpot>? avgStdDevX,
      List<FlSpot>? avgStdDevY,
      List<FlSpot>? avgStdDevZ,
      // List<FlSpot>? wavelength, // Added wavelength to constructor
      String activity = '',
      int stepCount = 0,
      String fluctuationState = '',
      String position = '',
      bool falldetected = false,
      String fallstate = 'None'})
      : ax = ax ?? [],
        ay = ay ?? [],
        az = az ?? [],
        rx = rx ?? [],
        ry = ry ?? [],
        rz = rz ?? [],
        // stdDevX = stdDevX ?? [],
        // stdDevY = stdDevY ?? [],
        // stdDevZ = stdDevZ ?? [],
        // avgStdDevX = avgStdDevX ?? [],
        // avgStdDevY = avgStdDevY ?? [],
        // avgStdDevZ = avgStdDevZ ?? [],
        // wavelength = wavelength ?? [], // Initialize wavelength
        activity = activity,
        stepCount = stepCount,
        fluctuationState = fluctuationState,
        position = position,
        falldetected = falldetected,
        fallstate = fallstate;

  // Method to clear all data
  void clear() {
    ax.clear();
    ay.clear();
    az.clear();
    rx.clear();
    ry.clear();
    rz.clear();

    // stdDevX.clear();
    // stdDevY.clear();
    // stdDevZ.clear();
    // avgStdDevX.clear();
    // avgStdDevY.clear();
    // avgStdDevZ.clear();
    // wavelength.clear(); // Clear wavelength

    activity = '';
    stepCount = 0;
    fluctuationState = '';
    position = '';
    falldetected = false;
    fallstate = 'None';
  }

  DataSet clone() {
    return DataSet(
        ax: List<FlSpot>.from(ax),
        ay: List<FlSpot>.from(ay),
        az: List<FlSpot>.from(az),
        rx: List<FlSpot>.from(rx),
        ry: List<FlSpot>.from(ry),
        rz: List<FlSpot>.from(rz),
        // stdDevX: List<FlSpot>.from(stdDevX),
        // stdDevY: List<FlSpot>.from(stdDevY),
        // stdDevZ: List<FlSpot>.from(stdDevZ),
        // avgStdDevX: List<FlSpot>.from(avgStdDevX),
        // avgStdDevY: List<FlSpot>.from(avgStdDevY),
        // avgStdDevZ: List<FlSpot>.from(avgStdDevZ),
        // wavelength: List<FlSpot>.from(wavelength), // Clone wavelength
        activity: activity,
        stepCount: stepCount,
        fluctuationState: fluctuationState,
        position: position,
        falldetected: falldetected,
        fallstate: fallstate);
  }
}
