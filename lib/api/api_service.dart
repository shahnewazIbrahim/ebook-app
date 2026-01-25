import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ebook_project/api/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService();

  Future<Map<String, dynamic>> fetchEbookData(String endpoint) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(getFullUrl(endpoint), headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw ApiException('Failed to load data: ${response.statusCode}');
    } catch (error) {
      throw ApiException('Error fetching data: $error');
    }
  }

  Future<Map<String, dynamic>?> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        getFullUrl(endpoint),
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {
        'error': 1,
        'message': 'Server Error: ${response.statusCode}'
      };
    } catch (error) {
      return {
        'error': 1,
        'message': 'Network Error: $error'
      };
    }
  }

  Future<String> fetchRawTextData(String endpoint) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(getFullUrl(endpoint), headers: headers);
      if (response.statusCode == 200) {
        return response.body.toString();
      }
      throw ApiException('Failed to fetch data');
    } catch (error) {
      throw ApiException('Error fetching data: $error');
    }
  }

  Future<void> logout(context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.post(
          getFullUrl('/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          await prefs.clear();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } else {
          print("Logout failed: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Logout error: $e");
      throw ApiException('Logout failed: $e');
    }
  }

  Future<Map<String, dynamic>> fetchSubscriptionPlans(int productId) async {
    final headers = await _authHeaders();
    final response = await http.get(getFullUrl('/v1/ebooks/$productId/plans'), headers: headers);
    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return body as Map<String, dynamic>;
    }
    throw ApiException(body['message']?.toString() ?? 'Failed to fetch plans');
  }

  Future<Map<String, dynamic>> createSubscription({
    required int productId,
    required int monthlyPlan,
    int paymentMethod = 1,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      getFullUrl('/v1/ebooks/$productId/subscriptions'),
      headers: headers,
      body: json.encode({
        'monthly_plan': monthlyPlan,
        'payment_method': paymentMethod,
      }),
    );
    final body = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return body as Map<String, dynamic>;
    }
    if (response.statusCode == 422) {
      throw ApiException(body['message']?.toString() ?? 'Validation failed');
    }
    throw ApiException(body['message']?.toString() ?? 'Subscription failed');
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
