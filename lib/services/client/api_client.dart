import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;


 class ApiClient {
  static String BASE_URL = "api.openweathermap.org";
  static String ENCODED_PATH = "/data/2.5/";
  static String API_KEY = "eed971d489488d2a8279da30e9b7f8ce";

  Map<String, String> headers = {"Content-type": "application/json"};




Future<dynamic> get(String url,  Map<String, String> params) async {


    var responseJson;
    try {
      params["appid"] = API_KEY;
      final finalUrl = Uri.https(BASE_URL, ENCODED_PATH+url, params);
      final response = await http.get(finalUrl, headers: headers);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString()); 
        print(responseJson);
        return responseJson;

      default:
        Map<String, dynamic> map = jsonDecode(response.body);
        throw Exception(map['message']);
    }
  }


}
