import 'package:flutter/cupertino.dart';
import 'package:quantana/models/climate_model.dart';
import 'package:quantana/models/weather_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database _database;
  static AppDatabase _appDatabase;
  static const int DB_VERSION = 1;

  static const String _DB_NAME = "weather.db";

  AppDatabase._private() {
    createDataBase();
  }

  static AppDatabase getInstance() {
    if (_appDatabase == null) {
      _appDatabase = AppDatabase._private();
    }

    return _appDatabase;
  }

  void createDataBase() async {
    _database = await initDb();
    print(_database.path);
  }

  Future<Database> initDb() async {
    return await openDatabase(join(await getDatabasesPath(), _DB_NAME),
        version: DB_VERSION, onCreate: (db, version) async {
      db.execute("""
     CREATE TABLE 
     ${ClimateModel.CLIMATE_TABLE} 
     (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
     date INTEGER,
     feels_high NUMBER,
     feels_low NUMBER,
     temp_low NUMBER,
     temp_high NUMBER,
     wind NUMBER,
     clouds INTEGER,
     pressure INTEGER,
     weatherid INTEGER NOT NULL,
     FOREIGN KEY (weatherid) REFERENCES weather(id) )
     
     """);
      db.execute(""" 
      CREATE TABLE ${WeatherModel.WEATHER_TABLE} (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
      main TEXT,
      description TEXT)
      """);
    });
  }

  Future<int> insertIntoWeather(WeatherModel weatherModel) async {
    var result = await _database.insert(
        WeatherModel.WEATHER_TABLE, weatherModel.toMap());

    return result;
  }

  Future<int> inserIntoClimate(ClimateModel climateModel) async {
    var weatherid = await insertIntoWeather(climateModel.weatherModel);
    var climateId = await _database.rawInsert("""INSERT INTO ${ClimateModel.CLIMATE_TABLE}  (
    date,
    feels_high,
    feels_low,
    temp_low,
    temp_high,
    wind,
    clouds,
    pressure ,
    weatherid
    ) 
    values(${climateModel.dateTimeStamp},
    ${climateModel.feelsHigh},
    ${climateModel.feelsLow},
    ${climateModel.tempLow},
    ${climateModel.tempHigh},
    ${climateModel.windSpeed},
    ${climateModel.clouds},
    ${climateModel.pressure},
    $weatherid
    
    )""");
    return climateId;
  }

  void insertList(List<ClimateModel> list) async {
    await clearTables();
    list.forEach((element) {
      inserIntoClimate(element);
    });
  }

  Future<List<ClimateModel>> getClimateHistory() async {
    var result = await _database.rawQuery(
        "SELECT  date, feels_high,feels_low,temp_low, temp_high, wind,clouds, pressure,weatherid, main,description FROM CLIMATE INNER JOIN weather ON weather.id = CLIMATE.weatherid");

   List<ClimateModel> model =  result.map((e) => ClimateModel.fromDb(e)).toList();
    return model;

  }

  void clearTables() async {
    await _database.rawDelete("DELETE FROM ${ClimateModel.CLIMATE_TABLE}");
    await _database.rawDelete("DELETE FROM ${WeatherModel.WEATHER_TABLE}");

  }
}
