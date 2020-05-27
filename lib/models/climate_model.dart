import 'package:quantana/main.dart';
import 'package:quantana/models/weather_model.dart';

class ClimateModel {
  static String CLIMATE_TABLE = "CLIMATE";
  DateTime dt;
  int dateTimeStamp;
  num temp;
  num tempLow;
  num tempHigh;
  num feelsLike;
  int pressure;
  int humidity;
  num dewPoint;
  int clouds;
  num windSpeed;
  int windDeg;
  WeatherModel weatherModel;
  num feelsLow;
  num feelsHigh;

  ClimateModel({
    this.dt,
    this.dateTimeStamp,
    this.temp,
    this.feelsLike,
    this.pressure,
    this.humidity,
    this.dewPoint,
    this.clouds,
    this.windSpeed,
    this.windDeg,
    this.weatherModel,
    this.feelsLow,
    this.feelsHigh,
    this.tempHigh,
    this.tempLow,
  });

  factory ClimateModel.fromJson(Map<String, dynamic> json) {
    var weather = json['weather'] as List;
    return ClimateModel(
        dt: getTimeFromTimeStamp(json["dt"]),
        feelsLike: json["feels_like"],
        temp: json["temp"],
        pressure: json["pressure"],
        humidity: json["humidity"],
        dewPoint: json["dew_point"],
        clouds: json["clouds"],
        windSpeed: json["wind_speed"],
        windDeg: json["wind_deg"],
        weatherModel: WeatherModel.fromJson(weather[0]));
  }

  static DateTime getTimeFromTimeStamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var hours = date.hour;
    var minutes = date.minute;
    return date;
  }

  factory ClimateModel.historyJson(Map<String, dynamic> json) {
    var weather = json['weather'] as List;
    var feelsLike = json['feels_like'];
    var temp = json['temp'];
    return ClimateModel(
        dateTimeStamp: json["dt"],
        feelsHigh: feelsLike["day"],
        feelsLow: feelsLike["night"],
        pressure: json["pressure"],
        humidity: json["humidity"],
        dewPoint: json["dew_point"],
        clouds: json["clouds"],
        windSpeed: json["wind_speed"],
        windDeg: json["wind_deg"],
        tempLow: temp["min"],
        tempHigh: temp["max"],
        weatherModel: WeatherModel.fromJson(weather[0]));
  }

  factory ClimateModel.fromDb(Map<String, dynamic> model){
    return ClimateModel(
        dateTimeStamp: model["date"],
      feelsHigh: model["feels_high"],
      feelsLow: model["feels_low"],
      tempLow: model["temp_low"],
      tempHigh: model["temp_high"],
      windSpeed: model["wind"],
      clouds: model["clouds"],
      pressure: model["pressure"],
      weatherModel: WeatherModel(description: model['description'],main: model['main'])
    );
  }
}
