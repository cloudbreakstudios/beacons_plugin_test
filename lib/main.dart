import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './my_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MyService>(
            create: (_) => MyService(),
          ),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key }) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void deactivate() {
    print('*** MAIN.DART -> deactivate()');
    super.deactivate();
  }
  @override
  void dispose() async {
    print('*** MAIN.DART -> dispose()');
    await context.read<MyService>().stopBeaconScan();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('*** MAIN.DART -> initState()');

    ///outside of this future and calling startBeaconScan() directly was causing..
    /// 'setState() or markNeedsBuild() called during build.' error
    Future.delayed(Duration.zero, () async {
      await context.read<MyService>().startBeaconScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('BLE Test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Home Screen (BLE background has already been called)',
              )
            ],
          ),
        ),
      ),
    );
  }
}


