import 'dart:async';

import 'package:quantana/database/app_db.dart';
import 'package:quantana/models/climate_model.dart';
import 'package:quantana/services/client/api_response.dart';
import 'package:quantana/services/repos/weather_repository.dart';

class WeatherBloc {
  WeatherRepository _weatherRepository;
  StreamController<ApiResponse<List<ClimateModel>>> hourController =
      StreamController<ApiResponse<List<ClimateModel>>>();
  StreamController<ApiResponse<List<ClimateModel>>> climateHistoryControl =
      StreamController<ApiResponse<List<ClimateModel>>>.broadcast();

  AppDatabase db;

  static WeatherBloc _instance;

  WeatherBloc._privateConstructor() {
    _weatherRepository = WeatherRepository();
    db = AppDatabase.getInstance();
  }

  static WeatherBloc getInstance() {
    if (_instance == null) {
      _instance = WeatherBloc._privateConstructor();
    }

    return _instance;
  }

  void getHistory() async {
    AppDatabase.getInstance();
  }

  void fetchHourlyWeather() async {
    try {
      List<ClimateModel> list = await _weatherRepository.fetchHoursWeather();
      hourController.add(ApiResponse.completed(list));
    } catch (e) {
      hourController.add(ApiResponse.error("Something Went Wrong"));
    }
  }

  void getLocalData() async{
    try{
      var list = await db.getClimateHistory();
      climateHistoryControl.add(ApiResponse.completed(list));
    }catch(e){
      print(e);

    }

    getClimateHisotryRemote();
  }

  void getClimateHisotryRemote() async {
    try {
      List<ClimateModel> list = await _weatherRepository.getClimateHisotry();
      climateHistoryControl.add(ApiResponse.completed(list));
      db.insertList(list);
    } catch (e) {
     // climateHistoryControl.add(ApiResponse.error("Something Went Wrong"));
    }
  }
}
