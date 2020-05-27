import 'dart:convert';

import 'package:quantana/models/climate_model.dart';
import 'package:quantana/services/client/api_client.dart';

class WeatherProvider {
  final String ONE_CALL = "onecall";

  ApiClient _apiClient = ApiClient();

  Future<List<ClimateModel>> fetchHoursWeather() async {
    Map<String, String> params = {
      "lat": "33.441792",
      "lon": "-94.037689",
      "exclude": "daily,minutely,current",
      "units": "metric"
    };

    final response = await _apiClient.get(ONE_CALL, params);

    var hourWeather = response["hourly"] as List;
    var weatherList = hourWeather.map((e) => ClimateModel.fromJson(e)).toList();

    return weatherList;
  }
  Future<List<ClimateModel>> getClimateHisotry() async {
    Map<String, String> params = {
      "lat": "33.441792",
      "lon": "-94.037689",
      "exclude": "minutely,current",
      "units": "metric"
    };

    final response = await _apiClient.get(ONE_CALL, params);

    var hourWeather = response["daily"] as List;
    var weatherList = hourWeather.map((e) => ClimateModel.historyJson(e)).toList();

    return weatherList;
  }
}