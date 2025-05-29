import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebook_project/api/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> fetchEbookData(String endpoint) async {
    try {
      String? token = await _getToken();

      var headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.get(getFullUrl(endpoint), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<Map<String, dynamic>?> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      String? token = await _getToken();
      var headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };
      String body = json.encode(data);

      final response = await http.post(getFullUrl(endpoint), headers: headers, body: body);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'error': 1,
          'message': 'Server Error: ${response.statusCode}'
        };
      }
    } catch (error) {
      return {
        'error': 1,
        'message': 'Network Error: $error'
      };
    }
  }

  Future<String> fetchRawTextData(String endpoint) async {
    try {
      String? token = await _getToken();

      var headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.get(getFullUrl(endpoint), headers: headers);

      if (response.statusCode == 200) {
        return response.body.toString();
      } else {
        throw Exception("Failed to fetch discussion");
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }
}
