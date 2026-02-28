import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static const String _baseUrl    = 'https://fakestoreapi.com';
  static const Duration _timeout  = Duration(seconds: 10);

  /// --- Auth ------------------------------------------------
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String?;
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Server error. Please try again.');
    } catch (_) {}
    return null;
  }

  /// --- User ------------------------------------------------------
  static Future<User?> getUser(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users/$id'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  /// -- All Products ----------------------------------------------
  /// Throws on failure — let the UI decide what to show.
  /// No silent mock fallback here.
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) throw Exception('No products returned from API.');
        return data.map((j) => Product.fromJson(j)).toList();
      }

      throw Exception('Server returned status ${response.statusCode}.');

    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Could not reach the server. Please try again.');
    } on FormatException {
      throw Exception('Unexpected response format from server.');
    } catch (e) {
      // Re-throw anything else with a clean message
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// -- Products by category ----------------------------------------
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/category/$category'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((j) => Product.fromJson(j)).toList();
      }

      throw Exception('Server returned status ${response.statusCode}.');

    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // -- All categories -------------------------------------------
  static Future<List<String>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/categories'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }

      throw Exception('Server returned status ${response.statusCode}.');

    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}