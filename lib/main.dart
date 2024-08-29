import 'package:flutter/material.dart';
import 'package:ga_local_web_app/customlinechart.dart';
import 'package:ga_local_web_app/dataprovider.dart';
import 'package:ga_local_web_app/sensordatapage.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        title: 'Line Chart Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Line Chart Demo'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return ListView.builder(
            itemCount: dataProvider.dataSets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(
                  height: 500,
                  child: LineChartSample(dataProvider.currentData),
                );
              } else {
                return SizedBox(
                  height: 500,
                  child: LineChartSample(dataProvider.dataSets[index - 1]),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return FloatingActionButton(
            onPressed: () {
              if (dataProvider.isGenerating) {
                dataProvider.stopGeneratingData();
              } else {
                dataProvider.startGeneratingData();
              }
            },
            child: Icon(
                dataProvider.isGenerating ? Icons.pause : Icons.play_arrow),
          );
        },
      ),
    );
  }
}
