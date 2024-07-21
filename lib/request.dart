import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> sendRequest(String token, String json,String endpoint) async {
  final response = await http.post(
    Uri.parse('${dotenv.env['SERVER_URL']}/$endpoint'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': token,
    },
    body: json
  );

  if (response.statusCode == 200) {
    print('Data sent successfully');
    return response.body;
  } else {
    throw Exception('Failed to send Data');
  }

}

Future<String> sendGetRequest(String token,String endpoint) async {
  final response = await http.get(
    Uri.parse('${dotenv.env['SERVER_URL']}/$endpoint'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': token,
    },
  );

  if (response.statusCode == 200) {
    print('Data retrieved successfully');
    return response.body;
  } else {
    throw Exception('Failed to retrieve data');
  }
}

Future<void> saveToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> removeToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}
