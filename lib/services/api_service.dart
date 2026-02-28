/**
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  // ── Auth ───────────────────────────────────────────────────────
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      }
    } catch (_) {}
    return null;
  }

  // ── User ───────────────────────────────────────────────────────
  static Future<User?> getUser(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users/$id'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  // ── Products ───────────────────────────────────────────────────
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final products = data.map((j) => Product.fromJson(j)).toList();
        if (products.isNotEmpty) return products;
      }
    } catch (_) {}
    // Always fall back to mock so screen is never blank
    return getMockProducts();
  }

  // ── Public mock data (guaranteed fallback) ─────────────────────
  static List<Product> getMockProducts() {
    return [
      // ── Electronics ──────────────────────────────────────────
      Product(
        id: 1,
        title: 'WD 2TB Elements Portable External Hard Drive - USB 3.0',
        price: 64.0,
        description: 'USB 3.0 and USB 2.0 Compatibility. Fast data transfers. Improve PC Performance.',
        category: 'electronics',
        image: 'https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_.jpg',
        rating: Rating(rate: 3.3, count: 203),
      ),
      Product(
        id: 2,
        title: 'SanDisk SSD PLUS 1TB Internal SSD - SATA III 6 Gb/s',
        price: 109.0,
        description: 'Easy upgrade for faster boot up, shutdown, and application load times.',
        category: 'electronics',
        image: 'https://fakestoreapi.com/img/61U7T1koQqL._AC_SX679_.jpg',
        rating: Rating(rate: 2.9, count: 470),
      ),
      Product(
        id: 3,
        title: 'Silicon Power 256GB SSD 3D NAND A55 SLC Cache',
        price: 109.0,
        description: '3D NAND flash are applied to deliver high transfer speeds.',
        category: 'electronics',
        image: 'https://fakestoreapi.com/img/71kWymZ+c+L._AC_SX679_.jpg',
        rating: Rating(rate: 4.8, count: 319),
      ),
      Product(
        id: 4,
        title: 'WD 4TB Gaming Drive Works with Playstation 4 Portable',
        price: 114.0,
        description: 'Expand your PS4 gaming experience, Play anywhere.',
        category: 'electronics',
        image: 'https://fakestoreapi.com/img/61mtL65D4cL._AC_SX679_.jpg',
        rating: Rating(rate: 4.8, count: 400),
      ),
      Product(
        id: 5,
        title: 'Acer SB220Q bi 21.5 inches Full HD IPS Monitor',
        price: 599.0,
        description: '21.5 inches Full HD (1920 x 1080) widescreen IPS display.',
        category: 'electronics',
        image: 'https://fakestoreapi.com/img/81QpkIctqPL._AC_SX679_.jpg',
        rating: Rating(rate: 2.9, count: 250),
      ),
      Product(
        id: 6,
        title: 'Samsung 49-Inch CHG90 144Hz Curved Gaming Monitor',
        price: 999.99,
        description: '49 INCH SUPER ULTRAWIDE 32:9 CURVED GAMING MONITOR.',
        category: 'electronics',
        image: 'https://fakestoreapi.com/img/81Zt42ioCgL._AC_SX679_.jpg',
        rating: Rating(rate: 2.2, count: 140),
      ),

      // ── Jewelery ─────────────────────────────────────────────
      Product(
        id: 7,
        title: "John Hardy Women's Legends Naga Gold & Silver Dragon Bracelet",
        price: 695.0,
        description: 'From our Legends Collection, the Naga was inspired by the mythical water dragon.',
        category: 'jewelery',
        image: 'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_FMwebp_QL65_.jpg',
        rating: Rating(rate: 4.6, count: 400),
      ),
      Product(
        id: 8,
        title: 'Solid Gold Petite Micropave',
        price: 168.0,
        description: 'Satisfaction Guaranteed. Return or exchange any order within 30 days.',
        category: 'jewelery',
        image: 'https://fakestoreapi.com/img/61sbMiUnoGL._AC_UL640_FMwebp_QL65_.jpg',
        rating: Rating(rate: 3.9, count: 70),
      ),
      Product(
        id: 9,
        title: 'White Gold Plated Princess Cut Diamond Ring',
        price: 9.99,
        description: 'Classic Created Wedding Engagement Solitaire Diamond Promise Ring.',
        category: 'jewelery',
        image: 'https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_FMwebp_QL65_.jpg',
        rating: Rating(rate: 3.0, count: 400),
      ),
      Product(
        id: 10,
        title: 'Pierced Owl Rose Gold Plated Stainless Steel Double Flared Earrings',
        price: 10.99,
        description: 'Rose Gold Plated Double Flared Tunnel Plug Earrings.',
        category: 'jewelery',
        image: 'https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_FMwebp_QL65_.jpg',
        rating: Rating(rate: 1.9, count: 100),
      ),

      // ── Men's Clothing ────────────────────────────────────────
      Product(
        id: 11,
        title: 'Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops',
        price: 109.95,
        description: 'Your perfect pack for everyday use and walks in the forest.',
        category: "men's clothing",
        image: 'https://fakestoreapi.com/img/81fAn9vfGhL._AC_UX679_.jpg',
        rating: Rating(rate: 3.9, count: 120),
      ),
      Product(
        id: 12,
        title: 'Mens Casual Premium Slim Fit T-Shirts',
        price: 22.3,
        description: 'Slim-fitting style, contrast raglan long sleeve, three-button henley placket.',
        category: "men's clothing",
        image: 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
        rating: Rating(rate: 4.1, count: 259),
      ),
      Product(
        id: 13,
        title: 'Mens Cotton Jacket',
        price: 55.99,
        description: 'Great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions.',
        category: "men's clothing",
        image: 'https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg',
        rating: Rating(rate: 4.7, count: 500),
      ),
      Product(
        id: 14,
        title: 'Mens Casual Slim Fit',
        price: 15.99,
        description: 'The color could be slightly different between on the screen and in practice.',
        category: "men's clothing",
        image: 'https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_.jpg',
        rating: Rating(rate: 2.1, count: 430),
      ),

      // ── Women's Clothing ──────────────────────────────────────
      Product(
        id: 15,
        title: "BIYLACLESEN Women's 3-in-1 Snowboard Jacket Winter Coats",
        price: 56.99,
        description: 'Note: The Jackets is US size, Run 2 sizes Smaller than US Normal Size.',
        category: "women's clothing",
        image: 'https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_.jpg',
        rating: Rating(rate: 2.6, count: 235),
      ),
      Product(
        id: 16,
        title: "Lock and Love Women's Removable Hooded Faux Leather Moto Biker Jacket",
        price: 29.95,
        description: '100% POLYURETHANE(shell) 100% POLYESTER(lining).',
        category: "women's clothing",
        image: 'https://fakestoreapi.com/img/81XH0e8fefL._AC_UY879_.jpg',
        rating: Rating(rate: 2.9, count: 340),
      ),
      Product(
        id: 17,
        title: "MBJ Women's Solid Short Sleeve Boat Neck V",
        price: 9.85,
        description: '95% RAYON 5% SPANDEX, Made in USA or Imported.',
        category: "women's clothing",
        image: 'https://fakestoreapi.com/img/71z3kpMAYsL._AC_UY879_.jpg',
        rating: Rating(rate: 4.7, count: 130),
      ),
      Product(
        id: 18,
        title: "Opna Women's Short Sleeve Moisture Tunic",
        price: 7.95,
        description: '100% Polyester, Machine wash, 100% Polyester.',
        category: "women's clothing",
        image: 'https://fakestoreapi.com/img/51eg55uWmdL._AC_UX679_.jpg',
        rating: Rating(rate: 4.5, count: 146),
      ),
      Product(
        id: 19,
        title: 'DANVOUY Womens T Shirt Casual Cotton Short',
        price: 12.99,
        description: '95% COTTON, 5% SPANDEX. Features: Casual, Short Sleeve, Letter Print.',
        category: "women's clothing",
        image: 'https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_.jpg',
        rating: Rating(rate: 3.6, count: 145),
      ),
    ];
  }
}*/










import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static const String _baseUrl    = 'https://fakestoreapi.com';
  static const Duration _timeout  = Duration(seconds: 10);

  // ── Auth ───────────────────────────────────────────────────────
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

  // ── User ───────────────────────────────────────────────────────
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

  // ── All Products ───────────────────────────────────────────────
  // Throws on failure — let the UI decide what to show.
  // No silent mock fallback here.
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

  // ── Products by category ───────────────────────────────────────
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

  // ── All categories ─────────────────────────────────────────────
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