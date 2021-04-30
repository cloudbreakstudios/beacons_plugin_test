import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyService with ChangeNotifier {
  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();

  Future stopBeaconScan() async {
    print('*** stopBeaconScan()');
    await BeaconsPlugin.stopMonitoring;

    if(beaconEventsController != null) {
      beaconEventsController.close();
    }
  }

  Future startBeaconScan() async {
    print('startBeaconScan()');
    try {
      BeaconsPlugin.setDebugLevel(9);

      if (Platform.isAndroid) {
        print('startBeaconScan() - Android!');
        //Prominent disclosure
        await BeaconsPlugin.setDisclosureDialogMessage(
            title: "Location Permission Needed",
            message: "Responder collects location data to work with beacons.");

        //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
        //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
      } else {
        print('startBeaconScan() - iOS!');
      }

      BeaconsPlugin.listenToBeacons(beaconEventsController);
      print('startBeaconScan() - listening');
      beaconEventsController.stream.listen((data) {
        print('startBeaconScan() - received something!..');
        if (data.isNotEmpty) {
          print('startBeaconScan() - data received..');

          var res = json.decode(data);
          print('startBeaconScan() - UUID: ${res['uuid']}');
        } else {
          print('startBeaconScan() - no data received during scan!');
        }
      },
      onDone: () {
        print('startBeaconScan() - Done');
      },
      onError: (error) {
        print('startBeaconScan() - Error: $error');
      });

      //Send 'true' to run in background
      print('startBeaconScan() - setting to run in background..');
      await BeaconsPlugin.runInBackground(true);
      if (Platform.isAndroid) {
        print('startBeaconScan() - Android setMethodCallHandler check');
        BeaconsPlugin.channel.setMethodCallHandler((call) async {
          print('startBeaconScan() - call.method = ${call.method}');
          if (call.method == 'scannerReady') {
            print('startBeaconScan() - Android startMonitoring');
            await BeaconsPlugin.startMonitoring;
          }
        });
      } else if (Platform.isIOS) {
        print('startBeaconScan() - iOS startMonitoring');
        await BeaconsPlugin.startMonitoring;
        return true;
      }

      print('startBeaconScan() - default startMonitoring');
      await BeaconsPlugin.startMonitoring;

      return false;
    } catch (e) {
      print('startBeaconScan() - error: ${e.toString()}');
      return false;
    }
  }
}