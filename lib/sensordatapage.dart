import 'package:flutter/material.dart';
import 'package:ga_local_web_app/dataprovider.dart';
import 'package:provider/provider.dart';

class SensorDataPage extends StatelessWidget {
  final DataProvider dataProvider;

  SensorDataPage({required this.dataProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: dataProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sensor Data'),
        ),
        body: Consumer<DataProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              itemCount: provider.dataSets.length,
              itemBuilder: (context, index) {
                final dataSet = provider.dataSets[index];
                return ListTile(
                  title: Text('DataSet ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AX: ${dataSet.ax.map((e) => e.y).toList()}'),
                      Text('AY: ${dataSet.ay.map((e) => e.y).toList()}'),
                      Text('AZ: ${dataSet.az.map((e) => e.y).toList()}'),
                      Text('RX: ${dataSet.rx.map((e) => e.y).toList()}'),
                      Text('RY: ${dataSet.ry.map((e) => e.y).toList()}'),
                      Text('RZ: ${dataSet.rz.map((e) => e.y).toList()}'),
                      Text('ALT: ${dataSet.alt.map((e) => e.y).toList()}'),
                      Text(
                          'Std Dev X: ${dataSet.stdDevX.map((e) => e.y).toList()}'),
                      Text(
                          'Std Dev Y: ${dataSet.stdDevY.map((e) => e.y).toList()}'),
                      Text(
                          'Std Dev Z: ${dataSet.stdDevZ.map((e) => e.y).toList()}'),
                      Text(
                          'Avg Std Dev X: ${dataSet.avgStdDevX.map((e) => e.y).toList()}'),
                      Text(
                          'Avg Std Dev Y: ${dataSet.avgStdDevY.map((e) => e.y).toList()}'),
                      Text(
                          'Avg Std Dev Z: ${dataSet.avgStdDevZ.map((e) => e.y).toList()}'),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Consumer<DataProvider>(
          builder: (context, provider, child) {
            return FloatingActionButton(
              onPressed: () {
                if (provider.isGenerating) {
                  provider.stopGeneratingData();
                } else {
                  provider.startGeneratingData();
                }
              },
              child:
                  Icon(provider.isGenerating ? Icons.pause : Icons.play_arrow),
            );
          },
        ),
      ),
    );
  }
}
