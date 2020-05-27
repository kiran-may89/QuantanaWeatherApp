class WeatherModel {
  static String WEATHER_TABLE = "weather";
  int id;
  String main;
  String description;


  WeatherModel({this.id, this.main, this.description});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(main: json['main'], description: json['description']);
  }

  Map<String, dynamic> toMap() => {'main': main, 'description': description};
}
