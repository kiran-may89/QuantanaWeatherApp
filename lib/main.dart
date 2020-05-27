import 'dart:io';

import 'package:charts_flutter/flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quantana/climate_history.dart';
import 'package:quantana/database/app_db.dart';

import 'package:quantana/models/climate_model.dart';

import 'package:quantana/services/bloc/weather_bloc.dart';
import 'package:quantana/services/client/api_response.dart';
Future<dynamic> backgroundMessageHandler(
    Map<String, dynamic> message) async {
  if (message.containsKey('data')) {

    final dynamic data = message['data'];
    return data;
  }

  if (message.containsKey('notification')) {

    final dynamic notification = message['notification'];
    return notification;
  }

  // Or do other work.
}
void main() {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WeatherBloc _bloc;
  bool animate = true;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  _MyHomePageState() {
    _bloc = WeatherBloc.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    _bloc.fetchHourlyWeather();

    _messaging.configure(
        onMessage: (Map<String, dynamic> message) async {},
        onBackgroundMessage: backgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {},
        onResume: (Map<String, dynamic> message) async {});

    _messaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    _messaging.getToken().then((String token) async {
      assert(token != null);

      print(token);
    });

  }

  void openTimePicker() async {
    Future<void> future;
    if (Platform.isAndroid) {
      future = showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 10, minute: 47),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        },
      );
    } else {
      future = showModalBottomSheet(
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) => CupertinoTimerPicker(
          onTimerDurationChanged: (Duration duration) {},
        ),
      );
    }
    future.then((value) => () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ClimateHistory()));
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openTimePicker,
        child: Icon(Icons.add),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<ApiResponse<List<ClimateModel>>>(
          stream: _bloc.hourController.stream,
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading"),
              );
            }

            if (snapShot.data.status == ApiResponse.COMPLETED) {
              return Container(
                child: new TimeSeriesChart(
                  createdata(snapShot.data.data),
                  behaviors: [SlidingViewport(), new PanAndZoomBehavior()],
                  dateTimeFactory: const LocalDateTimeFactory(),
                  animate: animate,
                  primaryMeasureAxis: new NumericAxisSpec(
                    tickProviderSpec:
                        new BasicNumericTickProviderSpec(desiredTickCount: 24),
                  ),
                  defaultRenderer: new LineRendererConfig(
                    includeArea: false,
                    includePoints: true,
                  ),
                  domainAxis: new DateTimeAxisSpec(

                      //   viewport:DateTimeExtents(start: snapShot.data.data[0].dt,end: snapShot.data.data[snapShot.data.data.length-1].dt) ,

                      tickFormatterSpec: AutoDateTimeTickFormatterSpec(
                        day: TimeFormatterSpec(
                          format: 'hh:mm',
                          transitionFormat: 'hh:mm',
                        ),
                        hour: TimeFormatterSpec(
                          format: 'hh:mm',
                          transitionFormat: 'hh:mm',
                        ),
                      ),
                      tickProviderSpec: AutoDateTimeTickProviderSpec()),
                ),
              );
            } else {
              return Center(
                child: Text(snapShot.data.message),
              );
            }
          },
        ),
      ),
    );
  }

  List<Series<ClimateModel, DateTime>> createdata(List<ClimateModel> data) {
    return [
      Series<ClimateModel, DateTime>(
        id: 'Weather',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        measureFn: (ClimateModel val, index) => val.temp,
        domainFn: (ClimateModel val, index) => val.dt,
        data: data,
      )
    ];
  }
}
