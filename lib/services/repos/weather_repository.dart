

import 'package:quantana/models/climate_model.dart';
import 'package:quantana/services/providers/weather_provider.dart';

class WeatherRepository{
   WeatherProvider weatherProvider = new WeatherProvider();

   Future<List<ClimateModel>> fetchHoursWeather()=> weatherProvider.fetchHoursWeather();
   Future<List<ClimateModel>> getClimateHisotry()=> weatherProvider.getClimateHisotry();
}