import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebook_project/api/routes.dart';

class ApiService {
  final String token = "Bearer 24481|pHCYJ0aZvP04Js9SM076EzrGsUmqdTpZnFRcOvWE";

  Future<Map<String, dynamic>> fetchEbookData(String endpoint) async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Authorization": token,
      };

      final response = await http.get(getFullUrl(endpoint), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  // Method to post data using POST
  Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Authorization": token,
      };

      // Convert data to JSON
      String body = json.encode(data);

      final response = await http.post(
        getFullUrl(endpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data');
      }
    } catch (error) {
      throw Exception('Error posting data: $error');
    }
  }
}
