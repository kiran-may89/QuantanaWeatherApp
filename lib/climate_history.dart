import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:quantana/models/climate_model.dart';
import 'package:quantana/services/bloc/weather_bloc.dart';
import 'package:quantana/services/client/api_response.dart';

class ClimateHistory extends StatefulWidget {
  @override
  State<ClimateHistory> createState() => ClimateHistoryState();
}

class ClimateHistoryState extends State<ClimateHistory> {
  WeatherBloc _weatherBloc;

  static DateFormat date = new DateFormat("EEE d MMM ");

  ClimateHistoryState() {
    _weatherBloc = WeatherBloc.getInstance();
    _weatherBloc.getLocalData();



  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: StreamBuilder<ApiResponse<List<ClimateModel>>>(

        stream: _weatherBloc.climateHistoryControl.stream,

        builder: (context,snaphot) {


          if (snaphot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text("Loading"),
            );
          } else if (snaphot.data.status == ApiResponse.COMPLETED) {
            return ListView.builder(

                itemCount: snaphot.data.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var model = snaphot.data.data[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey),)
                    ),
                    margin: EdgeInsets.only(top: 5,bottom: 5),
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Text(
                                date.format(ClimateModel.getTimeFromTimeStamp(
                                    model.dateTimeStamp)),
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ),
                              Image.asset(
                                  getAssetOnWeatherType(model.weatherModel.main),
                                  width: 25,
                                  height: 25),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    child: Text(
                                      model.tempHigh.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    child: Text(
                                      model.tempLow.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 4),
                                    child: Text(
                                      model.weatherModel.description,
                                      style: TextStyle(color: Colors.black45),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Text(model.windSpeed.toString() + "ms")),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "clouds: " + model.clouds.toString() + "%",
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                  Text(
                                    model.pressure.toString() + "hpa",
                                    style: TextStyle(color: Colors.black45),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                });
          } else {
            return Center(
              child: Text("Something went wrong"),
            );
          }
        },
      ),
    );
  }

  String getAssetOnWeatherType(String main) {
    String icon;
    if (main == "Clear") {
      icon = "clear.png";
    } else if (main == 'Rain') {
      icon = "rain.png";
    } else {
      icon = "clouds.png";
    }
    return "assets/images/$icon";
  }
}
